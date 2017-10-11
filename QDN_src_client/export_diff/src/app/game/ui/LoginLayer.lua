--[[
    --登陆界面
]]--
local ccbfile = "ccb/login.ccbi"

local LoginLayer = class("LoginLayer", function()
    local node = cc.Node:create()
    node:setNodeEventEnabled(true)
    return node
end)

local Layer_quit = require("app.game.ui.main.LayerQuit")
--http标识
local Http_Tag_LOGIN        = "HTTP_Tag_LOGIN" --登陆借口
local Http_Tag_WX_UserInfo  = "Http_Tag_WX_UserInfo" --请求用户信息
local Http_Tag_EnterRoom    = "Http_Tag_EnterRoom"

function LoginLayer:ctor()
   -- math.randomseed(os.time())
    self.m_WeiXinAccess = true --过滤 微信登录2次回调
    self:load_ccb()
    self:initUI()
    self:regEvent()
end

--清理
function LoginLayer:onCleanup()
    self:unregEvent()
end

--加载ccbi
function LoginLayer:load_ccb()
    self.m_ccbRoot = {
        ["onLoginClick"] = function(_sender, _event) self:onLoginClick(_sender, _event) end,
    }
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad(ccbfile, proxy, self.m_ccbRoot)
    node:addTo(self)
end

function LoginLayer:regEvent()
    --监听http
    g_http.listeners("LoginLayer",
        handler(self, self.httpSuccess),
        handler(self, self.httpFail))

    g_C2LuaSystem.regC2LuaFunc(g_C2LuaSystem.C2Lua_WeiXinAccess,handler(self,self.C2Lua_WeiXinAccess))
    g_J2LuaSystem.regJ2LuaFunc(g_J2LuaSystem.J2Lua_WeiXinAccess,handler(self,self.J2Lua_WeiXinAccess))
    g_J2LuaSystem.regJ2LuaFunc(g_J2LuaSystem.J2Lua_WXLoginErrorShow,handler(self,self.J2Lua_WXLoginErrorShow))

end

function LoginLayer:unregEvent()
    g_http.unlisteners("LoginLayer")

    g_C2LuaSystem.unregC2LuaFunc(g_C2LuaSystem.C2Lua_WeiXinAccess)
    g_J2LuaSystem.unregJ2LuaFunc(g_J2LuaSystem.J2Lua_WeiXinAccess)
    g_J2LuaSystem.unregJ2LuaFunc(g_J2LuaSystem.J2Lua_WXLoginErrorShow)
end

--点击登录
function LoginLayer:onLoginClick(_sender, _event)
    g_utils.setButtonLockTime(_sender,3)
    if g_GameConfig.isGuest then
        print("=================================")
        print("=========    游客登录   ==========")
        print("=================================")
        self:guestLogin()
    else
        print("=================================")
        print("=========    用户登录   ==========")
        print("=================================")
        self:userLogin()
    end
end

--用户登录登录
function LoginLayer:userLogin()

    if not self.m_ccbRoot.m_YesSprite:isVisible() then
        local LayerTipError = g_UILayer.Common.LayerTipError.new("请确认并同意用户协议")
        g_SMG:addLayer(LayerTipError)
        return
    end

    local token  = g_LocalDB:read("accesstoken")
    local openid = g_LocalDB:read("openid")


    local token_len = string.len(token)
    local openid_len = string.len(openid)
    if token_len < 10  or openid_len < 10 then
        self.m_ccbRoot.lbl_waitCheck:setVisible(true)
        self.m_ccbRoot.lbl_waitCheck:performWithDelay(function()self.m_ccbRoot.lbl_waitCheck:setVisible(false)end,3)
        g_ToLua:loginWeiXin() 
    else
        self:getWXUserInfo(token,openid)
    end
end

--游客登录
function LoginLayer:guestLogin()
    local name = g_GameConfig.guestID
    g_data.userSys.openid = name
    g_data.userSys.UserID = name
    g_data.userSys.nickname = name
    g_data.userSys.headimgurl = "www."
    g_data.userSys.sex = 1
    local tb = {
        version = "1.1",
        WeiChatID = name,
        WeiChatNick = name,
        WeiChatFaceAddress = "",
        Sex = 1,
        IsNetChange = false,}

    local url =  g_GameConfig.URL.."/weichat_login"
    g_data.userSys:updateWXInfo(tb)
    self:performWithDelay(function() g_http.POST(url, tb,"LoginLayer", Http_Tag_LOGIN) end,1)
end

--点击协议
function LoginLayer:onAgreementClick()
    -- g_utils.setButtonLockTime(_sender,1)
    g_SMG:addLayer(require("app.game.ui.LoginSceneLayer.LayerAgreement").new())
end

--是否同意
function LoginLayer:onYesClick( )
    print("onYesClick")
    self.m_ccbRoot.m_YesSprite:setVisible(not self.m_ccbRoot.m_YesSprite:isVisible())
end

function LoginLayer:addTouchLayer()
    local layer = display.newLayer()
    self:addChild(layer,-10)
    layer:setKeypadEnabled(true)
    layer:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
        if event.key == "back" then  --返回键
            --弹出退出框
            local  quit = Layer_quit.new()
            g_SMG:addLayer(quit)
        end
    end)
end

--http成功
function LoginLayer:httpSuccess(response, _tag)
    print("httpSuccess", _tag)
    if not response then
        print("ERROR _response 没有数据")
        return
    end

    local ok = false
    for i=1,1 do
        if Http_Tag_LOGIN == _tag then
            --不保存本地，直接读取
            local tb = json.decode(response)
            if not tb then
                my.TPFunction:messageBox("weichat_login,数据解析错误:", response)
                g_SMG:removeWaitLayer()
                break
            end
            if tb.ResultCode == -1 then
                local LayerTipError = g_UILayer.Common.LayerTipError.new(tb.ErrMsg)
                g_SMG:addLayer(LayerTipError)
                g_SMG:removeWaitLayer()
                break
            end
            self:Login_Success(tb)
        end

        if Http_Tag_WX_UserInfo == _tag then
            --不保存本地，直接读取
            local tb = json.decode(response)

            if not tb then
                my.TPFunction:messageBox("Http_Tag_WX_UserInfo,数据解析错误:", response)
                break
            end
            --过期
            if tb.errcode ~= nil then
                g_utils.setButtonLockTime(self.m_ccbRoot.btn_wxLogin,3)
                self.m_ccbRoot.lbl_waitCheck:setVisible(true)
                self.m_ccbRoot.lbl_waitCheck:performWithDelay(function()self.m_ccbRoot.lbl_waitCheck:setVisible(false)end,3)
                g_ToLua:loginWeiXin()--请求微信授权
            else
                self:doLogin(tb)
            end
        end
        --短线重连
        if Http_Tag_EnterRoom == _tag then
            --不保存本地，直接读取
            local tb = json.decode(response)

            if not tb then
                my.TPFunction:messageBox("enterroom,数据解析错误:", response)
                break
            end

            if tb.ResultCode == -1 then
                my.TPFunction:messageBox("enterroom,返回房间失败:", response)
                break
            end

            g_GameConfig.kServerAddr = tb.Host
            g_GameConfig.kServerPort = tb.Port
            g_data.roomSys.kTableID  = tb.TableID
            g_GameConfig.kSeatID     = tb.SeatID
            g_data.roomSys.Owner     = tb.Owner
            g_data.roomSys:updateGameRule(tb)
            self:performWithDelay(function()  g_netMgr:connectGameServer() end, 0.1)
        end
        ok = true
    end
    --失败处理
    if not ok then
        self:httpFail({code="101", response=""}, _tag)
    end
end

--http失败
function LoginLayer:httpFail(response, _tag)
    if Http_Tag_WX_UserInfo == _tag then
        if self.reconnect_wx_userInfo == 1 then
            g_ToLua:loginWeiXin()
            self.reconnect_wx_userInfo = self.reconnect_wx_userInfo + 1
        else
            my.TPFunction:messageBox("获取用户信息失败","请检查你的网络连接!")
        end
    elseif Http_Tag_LOGIN == _tag then
        my.TPFunction:messageBox("微信登录失败:","请检查你的网络连接!")
    else
        my.TPFunction:messageBox("http失败:", _tag)
    end
    
    -- print("httpFail", response, _tag)
    -- printTable("response",response)
    -- local tip = _tag
    -- local fn = nil
    -- --路由
    -- if Http_Tag_LOGIN == _tag then
    --     fn = function() self:performWithDelay(handler(self, self.loginwithbreak), 1.0) end
    -- end
end

--C2LUA
function LoginLayer:C2Lua_WeiXinAccess( value )
    local token  = value.token
    local openid = value.openid
    g_LocalDB:save("accesstoken",token)
    g_LocalDB:save("openid",openid)
    self:getWXUserInfo(token,openid)
end

--J2LUA
function LoginLayer:J2Lua_WeiXinAccess( value )
    printTable("LoginLayer:J2Lua_WeiXinAccess---value:",value)

    if value.access_token then
        local data = {
            token = value.access_token,
            openid = value.openid
        }
        self:C2Lua_WeiXinAccess(data)

    else
        if self.m_WeiXinAccess then
            self.m_WeiXinAccess = false
            return
        end
        local tb = {}
        tb.ErrorCode = value.errcode
        tb.ErrorMsg  = value.errmsg
        my.TPFunction:messageBox("微信登录获取token失败，请截图给程序！",json.encode(tb))
    end
end

--请求微信用户信息
function LoginLayer:getWXUserInfo(tonken,openid)
    self.reconnect_wx_userInfo = 1
    local url ="https://api.weixin.qq.com/sns/userinfo?access_token="..tonken.."&openid="..openid
    self:performWithDelay(function() g_http.GET(url, "LoginLayer", Http_Tag_WX_UserInfo) end, 0.1)
end

--登录
function LoginLayer:doLogin(info)
    --更新微信用户信息
    local tb  = g_data.userSys:updateWXInfo(info)
    local url = g_GameConfig.URL.."/weichat_login"
    self:performWithDelay(function() g_http.POST(url, tb,"LoginLayer", Http_Tag_LOGIN) end, 0.1)
end

--初始化ui
function LoginLayer:initUI()
    local ccb = self.m_ccbRoot
    -- ccb.m_AgreementLabel:setSystemFontName("fonts/FZZZHONGHJW.TTF")
    ccb.m_AgreementLabel:enableOutline(cc.c4b(141, 120 , 66, 255),1)

    local clientVersion = g_LocalDB:read("clientversion")
    ccb.m_VersionLable:setSystemFontName("fonts/FZZZHONGHJW.TTF")
    ccb.m_VersionLable:setString("App v "..clientVersion)

    ccb.m_AgreementLabel:setTouchEnabled(true)
    ccb.m_AgreementLabel:setTouchSwallowEnabled(true)
    ccb.m_AgreementLabel:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    ccb.m_AgreementLabel:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onAgreementClick))

    ccb.m_boxSprite:setTouchEnabled(true)
    ccb.m_boxSprite:setTouchSwallowEnabled(true)
    ccb.m_boxSprite:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    ccb.m_boxSprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onYesClick))

    self:addTouchLayer()

    if g_GameConfig.isiOSAppCheck then
        g_utils.setControlButtonImage(ccb.btn_wxLogin,"login_guset_button.png")
        ccb.m_AgreementLabel:setOpacity(0)
        -- ccb.m_AgreementLabel:setTouchEnable(false)
        ccb.m_boxSprite:setOpacity(0)
        ccb.m_YesSprite:setOpacity(0)
        ccb.m_AgreementLabel:removeAllNodeEventListeners()
    end

    -- self:initGusetInput(ccb.m_input)
end

--登录成功
function LoginLayer:Login_Success(info)
    g_data.userSys:updateServerInfo(info)
    g_gcloudvoice:initGvoice()
    g_data.userSys.isdelegate = info.canReplaceTable --是否能够代开房间
    g_data.userSys.firstLogin = 0
    g_data.userSys.firstLogin = info.firstLogin  --是否是当天首次登陆
    if info.RoomID > 0 then
        local url =  g_GameConfig.URL.."/enterroom"
        local tb = {
            RoomID = info.RoomID,
            accessKey = g_data.userSys.accessKey,
            DeviceID = g_data.userSys.openid,
            UserID =  g_data.userSys.UserID,
        }

        self:performWithDelay(function() g_http.POST(url,
            tb,"LoginLayer", Http_Tag_EnterRoom) end, 0.1)
    else
        --登陆成功
        g_LocalDB:save("soundstate",1) 
        app:enterMainScene()
    end
    g_LobbyCtl:getContactInfo()
    g_LobbyCtl:getActivityPicList()
end


--输入框
function LoginLayer:initGusetInput( _layer )
   local config={
            layer = _layer,
            fontSize = 35,
            image = "login_input.png",
            maxLength = 10,
            text = "",
            defaultText = "请输入用户名",
            color = display.COLOR_BLACK,
            keyBord = cc.KEYBOARD_RETURNTYPE_DONE,
        }
    self.m_edSearch = require("app.common.ui.UIInputBox").new(config)
    self.m_edSearch:addTo(self.m_ccbRoot.m_popLayer)
end

function LoginLayer:J2Lua_WXLoginErrorShow(errorTable)
    printTable("LoginLayer:J2Lua_WXLoginErrorShow---:",errorTable)
  -- // Field descriptor #20 I
  -- public static final int ERR_OK = 0; --成功的
  -- // Field descriptor #20 I
  -- public static final int ERR_COMM = -1;
-- // 可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等。

  -- // Field descriptor #20 I
  -- public static final int ERR_USER_CANCEL = -2;
  -- // Field descriptor #20 I
  -- public static final int ERR_SENT_FAILED = -3;
  -- // Field descriptor #20 I
  -- public static final int ERR_AUTH_DENIED = -4;
  -- 认证被否决

  -- // Field descriptor #20 I
  -- public static final int ERR_UNSUPPORT = -5;
  -- // Field descriptor #20 I
  -- public static final int ERR_BAN = -6;

    if errorTable.errCode == -2 or errorTable.errCode == 0 then
        return
    end
    local str = errorTable.errCode .. " " .. (errorTable.errStr or "")
    my.TPFunction:messageBox("微信登录失败，请截图给程序！", str)
end

return LoginLayer