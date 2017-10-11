
--[[
  房间内断线重连
]]--
local ReturnRoom = class("ReturnRoom", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

local Http_Tag_LOGIN        = "HTTP_Tag_LOGIN" --登陆借口
local Http_Tag_WX_UserInfo  = "Http_Tag_WX_UserInfo" --请求用户信息
local Http_Tag_EnterRoom    = "Http_Tag_EnterRoom"

function ReturnRoom:ctor()
    g_http.listeners("ReturnRoom",handler(self, self.httpSuccess),handler(self, self.httpFail))
    -- 断线重连
    local url = g_GameConfig.URL.."/weichat_login"
    printTable("g_data.userSys.userInfo =",g_data.userSys.userInfo)
    self:performWithDelay(function() g_http.POST(url, g_data.userSys.userInfo,"ReturnRoom", Http_Tag_LOGIN) end, 0.1)
    g_SMG:addWaitLayer()
end

function ReturnRoom:onCleanup()
     g_http.unlisteners("ReturnRoom")
end

--http成功
function ReturnRoom:httpSuccess(response, _tag)
    if not response then
        g_http.unlisteners("ReturnRoom")
        app:enterLoadingScene()
        return
    end
    local ok = false
    for i=1,1 do
        if Http_Tag_LOGIN == _tag then
            --不保存本地，直接读取
            local tb = json.decode(response)
            printTable("Http_Tag_LOGIN tb =",tb)
            if not tb then
                g_http.unlisteners("ReturnRoom")
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
                g_http.unlisteners("ReturnRoom")
                app:enterLoadingScene()
                return
            end
            g_GameConfig.kServerAddr = tb.Host
            g_GameConfig.kServerPort = tb.Port
            g_data.roomSys.kTableID  = tb.TableID
            g_GameConfig.kSeatID     = tb.SeatID
            g_data.roomSys.Owner     = tb.Owner
            g_data.roomSys:updateGameRule(tb)
            g_http.unlisteners("ReturnRoom")
            -- app:transitionScene()
           -- app:enterRoomScene()
            self:performWithDelay(function()  
                    g_netMgr:connectGameServer()
                    g_SMG:removeWaitLayer()
                    self:removeFromParent(true) 
                end, 0.1)
        end
        ok = true
    end
    --失败处理
    if not ok then
        self:httpFail({code="101", response=""}, _tag)
    end
end

--登录成功
function ReturnRoom:Login_Success(info)
    g_data.userSys:updateServerInfo(info)
    
    if info.RoomID then
        if info.RoomID <1 then 
            g_http.unlisteners("ReturnRoom")
            app:enterLoadingScene()
            g_data.userSys.roomState = 0
        end
        local url =  g_GameConfig.URL.."/enterroom"
        local tb = {
            RoomID = info.RoomID,
            accessKey = g_data.userSys.accessKey,
            DeviceID = g_data.userSys.openid,
            UserID =  g_data.userSys.UserID,
        }
        print("enterroom------ReturnRoom")
        g_http.POST(url,tb,"ReturnRoom", Http_Tag_EnterRoom)
    else
        g_data.userSys.roomState = 0
        g_http.unlisteners("ReturnRoom")
        app:enterLoadingScene()
    end
end

--http失败
function ReturnRoom:httpFail(response, _tag)
    g_http.unlisteners("ReturnRoom")
    g_SMG:removeWaitLayer()
    print("httpFail", response, _tag)
   app:enterLoadingScene()
end
return ReturnRoom