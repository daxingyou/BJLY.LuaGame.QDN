
--[[
    --定缺
    万 ---条 ---筒  
   	玩家选择一种定缺
]]--

local _File = "csb/RoomView/DingQue.csb"
local tb = {"Button_Wan","Button_Tiao","Button_Tong"}
local DingQueNode = class("DingQueNode", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function DingQueNode:ctor()
    self:initUI() 
    self:regEvent()
end

function DingQueNode:onCleanup()
    self:unregEvent()
end

--注册事件
function DingQueNode:regEvent()
    g_msg:reg("DingQueNode", g_msgcmd.UI_DingQue_Success, handler(self, self.onDingQueStatus))    --定缺状态
    g_msg:reg("DingQueNode", g_msgcmd.UI_AskDingQueBroadcast, handler(self, self.onDingQue_ok))
    g_msg:reg("DingQueNode", g_msgcmd.DB_PLAY_ADD_CARD, handler(self, self.onCloseClick))    --发牌
end

--当系统发牌 就关闭定缺
function DingQueNode:onCloseClick()
	g_msg:post(g_msgcmd.UI_DingQue_END)
	self:removeFromParent(true)
end

--注销事件
function DingQueNode:unregEvent()
    g_msg:unreg("DingQueNode", g_msgcmd.UI_DingQue_Success)
    g_msg:unreg("DingQueNode", g_msgcmd.UI_AskDingQueBroadcast)
    g_msg:unreg("DingQueNode", g_msgcmd.DB_PLAY_ADD_CARD)    --发牌
end

function DingQueNode:initUI()
	local _UI = cc.uiloader:load(_File)
    _UI:addTo(self)

    for k,v in pairs(tb) do
		self[v] = _UI:getChildByName(v)
		self[v]:setVisible(true)
		self[v]:setTag(k)
		g_utils.setButtonClick(self[v],handler(self,self.onDQClick))
	end


	local temp = nil
	for i = 2,4 do
		temp = _UI:getChildByName("m_DingQueing_"..i)
		temp:setVisible(false)
	end 

	
	self.dingQueSprites = {} --- 定缺中  文字
	local players = g_data.roomSys:getRoomPlayers()
	for k,v in pairs(players) do
	 	temp = _UI:getChildByName("m_DingQueing_"..v.direction)
	 	if temp then
	 		self.dingQueSprites[v.uid] = temp
	 		temp:setVisible(true)
	 	end
	end
end

--定缺选择
function  DingQueNode:onDQClick( _btn )
	--点击后所有按钮锁定 3秒
	for k,v in pairs(tb) do
		g_utils.setButtonLockTime(self[v],3)
	end
	local _QueMen = _btn:getTag()
	--发送服务器
	g_netMgr:send(g_netcmd.MSG_DINGQUE_ASK_BROADCAST, { QueMen = _QueMen} , 0)
end

--定缺请求
function DingQueNode:onDingQueStatus(_msg)
	local temp = nil
    local players = g_data.roomSys:getRoomPlayers()
	for k,v in pairs(players) do
	 	if v.QueMen ~= -1 then
	 		if self.dingQueSprites[v.uid] then
	 			self.dingQueSprites[v.uid]:setVisible(false)
	 		end
	 		-- 定缺后可以点击
	 		if  v.uid == g_data.userSys.UserID then
	 			self:unlock()
	 		end
	 	end
	end
end

--定缺请求
function DingQueNode:onDingQue_ok(_msg)
    if _msg.data.DQType == "success" then
    	local tb = {"Button_Wan","Button_Tiao","Button_Tong"}
    	self.Button_Wan:setVisible(false)
    	self.Button_Tiao:setVisible(false)
    	self.Button_Tong:setVisible(false)
    end
end

return DingQueNode