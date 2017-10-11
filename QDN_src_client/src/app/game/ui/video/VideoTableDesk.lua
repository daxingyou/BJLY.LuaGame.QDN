--[[
    --录像桌面
]]--
local TableDesk = require("app.game.ui.room.TableDesk")
local VideoTableDesk = class("VideoTableDesk",TableDesk)

function VideoTableDesk:initUI( )
  local rule  = g_data.roomSys.PlayRule
  local frame = RoomDefine.room_text[rule]
  self.m_ccbRoot.m_TextSprite:setSpriteFrame(frame)
  self.m_ccbRoot.m_TextSprite_ressgion:setVisible(false)
  self:setting()
end

return VideoTableDesk