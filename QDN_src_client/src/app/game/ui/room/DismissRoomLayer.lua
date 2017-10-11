--[[
    --房间信息
]]--
local _file = "csb/RoomView/DismissRoom.csb"
local DismissRoomLayer = class("DismissRoomLayer", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)


function DismissRoomLayer:ctor(_uid,isReconnect)
    self.isReconnect = isReconnect
    -- 每个用户的回答解散房间状态 (0未提出解散，1表示未响应，2表示同意，3不同意 4 发起者)      
    if self.isReconnect then
       local room_players =  g_data.roomSys:getRoomPlayers()
       for k,v in pairs(room_players) do
            if v.dismiss_status == 4 then 
                _uid = v.uid
                break
            end 
        end
    end

    self.uid = _uid
    self:initUI()
    self:regEvent()
end


local  _Color = {
    cc.c3b(49,173,4),
    cc.c3b(175,119,0),
    cc.c3b(238,52,11),
}
--初始化页面
function DismissRoomLayer:initUI()
     local _UI = cc.uiloader:load(_file)
    _UI:addTo(self)

    local tb =  {"m_AskNameLabel","m_ok","m_cancel","m_StateLable_1","m_StateLable_2","m_StateLable_3","m_MinuteLable","m_SecondLable"
    ,"m_NameLable_1","m_NameLable_2","m_NameLable_3"
    }
    for k,v in pairs(tb) do
        self[v] = _UI:getChildByName(v)
    end

    local player = g_data.roomSys:getPlayerInfo(self.uid)
    self.m_AskNameLabel:setString(player.weichat_nick)

    self.m_StateLable_1:setVisible(false)
    self.m_StateLable_2:setVisible(false)
    self.m_StateLable_3:setVisible(false)

    self.m_NameLable_1:setVisible(false)
    self.m_NameLable_2:setVisible(false)
    self.m_NameLable_3:setVisible(false)

    self.tb = {}
    local players = g_data.roomSys:getRoomPlayers()
    local i = 1
    for k,v in pairs(players) do
        if i >3 then break end

        if v.uid ~= self.uid then
            local _child = {}
            _child[1] = self["m_StateLable_"..i]
            _child[2] = self["m_NameLable_"..i]
            self["m_StateLable_"..i]:setVisible(true)
            self["m_StateLable_"..i]:setString("正在选择")
            self["m_StateLable_"..i]:setColor(_Color[1])
            self["m_NameLable_"..i]:setString(v.weichat_nick)
            self["m_NameLable_"..i]:setVisible(true)
            self.tb[v.uid] = _child
            i = i +1 
        end
    end

    if g_data.userSys.UserID == self.uid then
        self.m_ok:setVisible(false)
        self.m_cancel:setVisible(false)
    else
        g_utils.setButtonClick(self.m_ok,handler(self,self.onOkClick))
        g_utils.setButtonClick(self.m_cancel,handler(self,self.onCancelClick))
    end

    self.m_tickSchedule = nil
    self.m_tickTime = 300
    self:run_m_tickSchedule()
    -- getTimeTableBySceond2

-- - 每个用户的回答解散房间状态 (0未提出解散，1表示未响应，2表示同意，3不同意 4 发起者)    
    if self.isReconnect then
       local room_players =  g_data.roomSys:getRoomPlayers()
       for k,v in pairs(room_players) do

            if v.dismiss_status == 2 then 
                self:setDismssRoomStatus(v.uid,true)
            end
            if v.dismiss_status == 3 then 
               self:setDismssRoomStatus(v.uid,false)
            end 
        end
    end
end

function DismissRoomLayer:run_m_tickSchedule()
    if self.m_tickSchedule == nil then
        self.m_tickSchedule = self:schedule( function() self:tick() end, 1)
    end
end

function DismissRoomLayer:un_m_tickSchedule()
    if self.m_tickSchedule then
        self:stopAction(self.m_tickSchedule)
        self.m_tickSchedule = nil
    end   
end

function DismissRoomLayer:tick( )
    self.m_tickTime = self.m_tickTime - 1
    local tb  = g_utils.getTimeTableBySceond2(self.m_tickTime)
    self.m_MinuteLable:setString(tb.minute)
    self.m_SecondLable:setString(tb.second)
    
end

function DismissRoomLayer:onCleanup()
    self:unregEvent()
end

function DismissRoomLayer:onExit()
    -- self:unregEvent()
end

--注册事件
function DismissRoomLayer:regEvent()
    g_msg:reg("DismissRoomLayer", g_msgcmd.UI_DismissAnswerBroadcast, handler(self, self.onAnswer))
    g_msg:reg("DismissRoomLayer", g_msgcmd.UI_DismissBroadcast, handler(self, self.onDismissBroadcast))
end

--注销事件
function DismissRoomLayer:unregEvent()
    g_msg:unreg("DismissRoomLayer", g_msgcmd.UI_DismissAnswerBroadcast)
    g_msg:unreg("DismissRoomLayer", g_msgcmd.UI_DismissBroadcast)
end

function DismissRoomLayer:onOkClick()
     g_netMgr:send(g_netcmd.MSG_DISMISS_ANSWER, { is_agree = 1 } , 0)
end

function DismissRoomLayer:onCancelClick()
    g_netMgr:send(g_netcmd.MSG_DISMISS_ANSWER, { is_agree = 0 } , 0)
end

function DismissRoomLayer:onAnswer(_msg)
    local dt       = _msg.data
    local uid      = dt.uid
    local is_agree = dt.is_agree
    self:setDismssRoomStatus(uid,is_agree == 1)
end

function DismissRoomLayer:setDismssRoomStatus(uid, _bool )
    local str   = _bool  and  "已经同意" or "已经拒绝"
    local color = _bool  and  _Color[3] or _Color[2]
    self.tb[uid][1]:setString(str)
    self.tb[uid][1]:setColor(color)
end

function DismissRoomLayer:onDismissBroadcast(_msg)
    print("DismissRoomLayer -onDismissBroadcast ----->")
    self:un_m_tickSchedule()
    local dt          = _msg.data
    local is_dismiss  = dt.is_dismiss
    if is_dismiss == 0 then
        g_SMG:removeByName("DismissRoomLayer")
    else
        g_data.reportSys.isPopfinalReport = true
        g_SMG:removeByName("DismissRoomLayer") -- 是否结算  TODO
    end
end

return DismissRoomLayer