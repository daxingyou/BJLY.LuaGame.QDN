local Heads = require("app.common.component.sprites.Heads")
--[[
 	录像头像管理
]]
local VideoHeads = class("VideoHeads", Heads)


--更新头像信息
function VideoHeads:updateHeadInfo()
	for _,v  in pairs(self.m_heads) do
		v:setVisible(false)
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
			head.m_score_bg:setVisible(false)
			head:updateReconnect()
		until true
	end
end
return VideoHeads