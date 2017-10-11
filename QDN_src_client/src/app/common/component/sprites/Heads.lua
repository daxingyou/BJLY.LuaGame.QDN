local PlayerIcon = require("app.game.ui.room.PlayerIcon")
--[[
 头像管理 暂时这样 以后再改
]]
local Heads = class("Heads", function()
    local node =  display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

function Heads:ctor()
	self.m_heads = {}
	for _,direction  in pairs(TileDirection) do
		local head = PlayerIcon.new()
		head:addTo(self)
		self.m_heads[direction] = head
	end
	self:regEvent()

	self:updateHeadInfo()
end

function Heads:onCleanup()
    self:unregEvent()
end

--注册事件
function Heads:regEvent()
	--发牌
	g_msg:reg("Heads", g_msgcmd.DB_UPDATE_PLAYER_INFO, handler(self, self.S2C_updateHeadInfo))    --游戏开始
end

--注销事件
function Heads:unregEvent()
	g_msg:unreg("Heads", g_msgcmd.DB_UPDATE_PLAYER_INFO)
end

--注销事件
function Heads:S2C_updateHeadInfo()
	self:updateHeadInfo()
end

--更新头像信息
function Heads:updateHeadInfo()
	for _,v  in pairs(self.m_heads) do
		v:setVisible(false)
		v:stopAllActions()
	end
	local infos = g_data.roomSys:getRoomPlayers()
	for _,info  in pairs(infos) do
		repeat
			local direction = info.direction
			if direction < 1 or direction > 4 then break end
			local head = self.m_heads[direction]
			head.m_info = info
			head:initData()
			head:setVisible(true)
			head:updateReconnect()
		until true
	end
end
return Heads