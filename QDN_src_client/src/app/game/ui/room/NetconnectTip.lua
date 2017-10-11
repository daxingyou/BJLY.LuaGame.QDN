
--[[
  房间内断线重连
]]--

local ccbfile = "ccb/netconnectTip.ccbi"
local ReturnRoom = require("app.game.ui.room.ReturnRoom")
local NetconnectTip = class("NetconnectTip", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

local Http_Tag_LOGIN        = "HTTP_Tag_LOGIN" --登陆借口
local Http_Tag_WX_UserInfo  = "Http_Tag_WX_UserInfo" --请求用户信息
local Http_Tag_EnterRoom    = "Http_Tag_EnterRoom"

function NetconnectTip:ctor()
	self:load_ccb()
end

function NetconnectTip:onCleanup() 
end

function NetconnectTip:onEnter()
    
end

function NetconnectTip:onExit()
    g_http.unlisteners("NetconnectTip")
end

function NetconnectTip:load_ccb()
    self.m_ccbRoot = {
    	["onSureClick"] = function(_sender, _event) self:onSureClick(_sender, _event) end,
	}
    local proxy = cc.CCBProxy:create()
    local node  =  CCBReaderLoad(ccbfile, proxy, self.m_ccbRoot)
    node:addTo(self)
end

--重新连接
function NetconnectTip:onSureClick()
    self:setVisible(false)
    g_ToLua:printScreen("transitionScene.jpg")
    self:performWithDelay(function()
        g_http.listeners("NetconnectTip",handler(self, self.httpSuccess),handler(self, self.httpFail))
        -- 断线重连
        local url = g_GameConfig.URL.."/weichat_login"
        g_http.POST(url, g_data.userSys.userInfo,"NetconnectTip", Http_Tag_LOGIN) 
    end, 0.1)
end

--http成功
function NetconnectTip:httpSuccess(response, _tag)
    -- g_http.unlisteners("NetconnectTip")
    if not response then
        g_http.unlisteners("NetconnectTip")
        g_SMG:removeNetConnectLayer()
        app:enterLoadingScene()
        return
    end
    local ok = false
    for i=1,1 do
        if Http_Tag_LOGIN == _tag then
            --不保存本地，直接读取
            local tb = json.decode(response)

            if not tb then
                g_http.unlisteners("NetconnectTip")
                app:enterLoadingScene()
                break
            end
            self:Login_Success(tb)
        end
        --短线重连
        if Http_Tag_EnterRoom == _tag then
            --不保存本地，直接读取
            local tb = json.decode(response)
            if tb.ResultCode == -1 then
                g_http.unlisteners("NetconnectTip")
                app:enterLoadingScene()
                return
            end
            g_GameConfig.kServerAddr = tb.Host
            g_GameConfig.kServerPort = tb.Port
            g_data.roomSys.kTableID  = tb.TableID
            g_GameConfig.kSeatID     = tb.SeatID
            g_data.roomSys.Owner     = tb.Owner
            g_data.roomSys:updateGameRule(tb)
            g_http.unlisteners("NetconnectTip")
            g_SMG:removeNetConnectLayer()
            app:transitionScene()            
        end
        ok = true
    end
    --失败处理
    if not ok then
        self:httpFail({code="101", response=""}, _tag)
    end
end

--登录成功
function NetconnectTip:Login_Success(info)
    g_data.userSys:updateServerInfo(info)
    
    if info.RoomID then
        if info.RoomID <1 then 
            g_http.unlisteners("NetconnectTip")
            app:enterLoadingScene()  
        end
        local url =  g_GameConfig.URL.."/enterroom"
        local tb = {
            RoomID = info.RoomID,
            accessKey = g_data.userSys.accessKey,
            DeviceID = g_data.userSys.openid,
            UserID =  g_data.userSys.UserID,
        }
        g_http.POST(url,tb,"NetconnectTip", Http_Tag_EnterRoom)
    else
        g_http.unlisteners("NetconnectTip")
        app:enterLoadingScene()
    end
end

--http失败
function NetconnectTip:httpFail(response, _tag)
    g_http.unlisteners("NetconnectTip")
    g_SMG:removeWaitLayer()
    print("httpFail", response, _tag)
    g_SMG:removeNetConnectLayer()
    app:enterLoadingScene()
end
return NetconnectTip