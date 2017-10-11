--[[
    --桌面
]]--

local ccbfile = "ccb/table.ccbi"
local TableDesk = class("Table", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

function TableDesk:ctor()
   self:load_ccb()
   self:initUI()
   self:regEvent()
end

function TableDesk:onCleanup()
    self:unregEvent()
end

--注册事件
function TableDesk:regEvent()
    g_msg:reg("TableDesk", g_msgcmd.UI_Setting_Change, handler(self, self.setting))
end

--注销事件
function TableDesk:unregEvent()
    g_msg:unreg("TableDesk", g_msgcmd.UI_Setting_Change)
end

local Desk_bg = {
  "bg_desktop_green.png",
  "bg_desktop_blue.png",
}

--加载ccbi
function TableDesk:load_ccb()
    self.m_ccbRoot = {}
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad(ccbfile, proxy, self.m_ccbRoot)
    node:addTo(self)
end

function TableDesk:initUI( )
  local rule  = g_data.roomSys.PlayRule
  local frame = RoomDefine.room_text[rule]
  self.m_ccbRoot.m_TextSprite:setSpriteFrame(frame)

  local region = g_data.roomSys.region
  local frame_region = RoomDefine.region[region]
  if g_data.roomSys.UI_State ~= RoomDefine.UI_State.Video then
     self.m_ccbRoot.m_TextSprite_ressgion:setSpriteFrame(frame_region)
  else
     self.m_ccbRoot.m_TextSprite_ressgion:setVisible(false)
  end
  self:setting()
end

function TableDesk:setting()
   local tablestyle = g_LocalDB:read("tablestylebg")
  self.m_ccbRoot.m_desk_bg:setSpriteFrame(Desk_bg[tablestyle])

end

return TableDesk