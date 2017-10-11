--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/LayerJoinRoom.csb"

local LayerJoinRoom = class("LayerJoinRoom", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerJoinRoom:ctor(_cfg)
    self:initUI()
    self:__regHTTP()
end

 --初始化ui
function LayerJoinRoom:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerJoinRoom:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local btnExit = mBackground:getChildByName("btn_exit")
    local btnDel = mBackground:getChildByName("btn_del")
    local btnRewrite = mBackground:getChildByName("btn_rewrite")
    self.btnNum={}
    for i=1,10 do
       local namePath = string.format("btn_num_%d",i-1)
       self.btnNum[i] = mBackground:getChildByName(namePath)
       self.btnNum[i]:setTag(i-1) 
       g_utils.setButtonClick(self.btnNum[i],handler(self,self.onBtnClick))
    end

    self.lableNum={}
    for i=1,6 do
        local  pathName  = string.format("txtNum_%d", i)
        self.lableNum[i] = mBackground:getChildByName(pathName)
        self.lableNum[i]:setString("")
    end

    self.labelText=0
    
    g_utils.setButtonClick(btnExit,handler(self,self.onBtnClick))
    g_utils.setButtonClick(btnDel,handler(self,self.onBtnClick))
    g_utils.setButtonClick(btnRewrite,handler(self,self.onBtnClick))
end

function LayerJoinRoom:onBtnClick( _sender )
    local s_name = _sender:getName()
    local tag = _sender:getTag()
    if s_name == "btn_exit"then
        g_SMG:removeLayer()
    elseif s_name == "btn_copy"then

    elseif s_name == "btn_del"then
        print("labeltext==================",self.labelText)
        if self.labelText > 0 then
           self.lableNum[self.labelText]:setString("")
           self.labelText=self.labelText-1
        end
    elseif s_name == "btn_rewrite"then
            for i=1,6 do
                self.lableNum[i]:setString("")
            end
            self.labelText = 0
    else 
        if self.labelText < 6 then
            self.labelText =self.labelText+1
            print("tag----------------",tag)
            self.lableNum[self.labelText]:setString(tag)
            if self.labelText == 6 then
                print("=========加入房间=========")
                self:enterRoom()
            end
        end
    end
end

local Http_Join_LOGIN = "Http_Join_LOGIN"
function  LayerJoinRoom:enterRoom()
    local roomId =""
    for i = 1 ,#self.lableNum do
        roomId = roomId..self.lableNum[i]:getString()
    end

    local tb = {
        RoomID = roomId,
        accessKey = g_data.userSys.accessKey,
        DeviceID = g_data.userSys.openid,
        UserID =  g_data.userSys.UserID,
}

    local url =  g_GameConfig.URL.."/enterroom" 
    g_SMG:addWaitLayer()
    self:performWithDelay(function() g_http.POST(url, tb,"LayerJoinRoom", Http_Join_LOGIN) end, 0.1)
end

--创建http
function LayerJoinRoom:__regHTTP()
    --http失败
    local function __httpFail(_response, _tag)
        g_SMG:removeWaitLayer()
        print(Http_Join_LOGIN, "httpFail", _response, _tag)  
    end

    --http成功
    local function __httpSuccess(_response, _tag)
        print(Http_Join_LOGIN, "httpSuccess", _tag)
        -- print(_response)
        if not _response then
            print("ERROR _response 没有数据")
            return
        end

        local ok = false
        if Http_Join_LOGIN == _tag then
            local tb = json.decode(_response)
            printTable("Http_Join_LOGIN =", tb)
            if not tb then return end
            if tb.ResultCode == -1 then
                g_SMG:removeWaitLayer()
                local LayerTipError = g_UILayer.Common.LayerTipError.new(tb.ErrMsg)
                g_SMG:addLayer(LayerTipError)
                return
            end
            g_GameConfig.kServerAddr = tb.Host
            g_GameConfig.kServerPort = tb.Port
            g_data.roomSys.kTableID  = tb.TableID
            g_GameConfig.kSeatID     = tb.SeatID

            tb.roomId = g_data.roomSys.kTableID
            g_data.roomSys.Owner     = tb.Owner
            g_data.roomSys:updateGameRule(tb)
             self:performWithDelay(function()  g_netMgr:connectGameServer() end, 0.1)
            ok = true
        end

        --失败处理
        if not ok then
            __httpFail("", _tag)
        end
    end
    --监听http
    g_http.listeners("LayerJoinRoom", __httpSuccess, __httpFail)
end

--创建http
function LayerJoinRoom:__unHTTP()
    g_http.unlisteners("LayerJoinRoom")
end

function LayerJoinRoom:onCleanup()
    self:__unHTTP()
end
  

return LayerJoinRoom