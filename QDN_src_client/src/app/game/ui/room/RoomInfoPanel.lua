--[[
    --桌面
]]--

local ccbfile = "ccb/roomInfoPanel.ccbi"
local RoomInfoPanel = class("RoomInfoPanel", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

local state = 
{
  open  = 1,
  close = 2
}

function RoomInfoPanel:ctor()
  g_data.userSys.roomState = 0
  self:load_ccb()

  self:initUI()
  self:regEvent()
end
function RoomInfoPanel:onCleanup()
    self:unregEvent()
end

--加载ccbi
function RoomInfoPanel:load_ccb()
    self.m_ccbRoot = {
      ["onClick"] = function(_sender, _event) self:onClick(_sender, _event) end,
      ["onBack"]  = function(_sender, _event) self:onBack(_sender, _event) end,
    }
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad(ccbfile, proxy, self.m_ccbRoot)
    node:addTo(self)
    
    self.m_ccbRoot.m_backButton:setVisible(false)
    local code = string.len(g_data.roomSys.club_code)
    print("g_data.roomSys.club_code =",g_data.roomSys.club_code)
    print("code =",code)
    if g_data.roomSys.m_status ~= RoomDefine.Status.Doing and g_data.roomSys.Owner == g_data.userSys.UserID then
      self.m_ccbRoot.m_backButton:setVisible(true)
    end
end

--注册事件
function RoomInfoPanel:regEvent()
    g_msg:reg("RoomInfoPanel", g_msgcmd.DB_PLAY_GAME_START,handler(self, self.onGameStar))
end

function RoomInfoPanel:onGameStar()
  if self.state  == state.open then
   -- self:onClick()
  end
  self.m_ccbRoot.m_backButton:setVisible(false)
end

--注销事件
function RoomInfoPanel:unregEvent()
    g_msg:unreg("RoomInfoPanel", g_msgcmd.DB_PLAY_GAME_START)
end

function RoomInfoPanel:initUI()
  self.state  = state.open
  local ccb   = self.m_ccbRoot

  --房间号
  ccb.m_roomNumber:setString(g_data.roomSys.kTableID)
  --局数
  ccb.m_roomRound:setString(g_data.roomSys.RoundLimit.."局")
  --见光死
  local table_type = g_data.roomSys.region
  


  print("g_data.roomSys.DeathByLight",g_data.roomSys.DeathByLight)
  printTable("_title==----", g_data.roomSys)
  
  if table_type == "jinping" then
    if  g_data.roomSys.IsMenGangMulti2 ~=nil then
      ccb.m_LightLabel:setVisible(true)
      if g_data.roomSys.IsMenGangMulti2 == 1 then
        ccb.m_LightLabel:setString("闷杠x2")
        else
          ccb.m_LightLabel:setString("自杠x2")
      end
    end
  end
  if table_type == "liping" then
      local dFlag,aFlag,num = false,false,0
      if  g_data.roomSys.DeathByLight and  g_data.roomSys.DeathByLight == 1 then
         dFlag = true
         num = num + 1
      end
      if g_data.roomSys.Additional and g_data.roomSys.Additional > 0 then
          aFlag = true
          num = num + 1
      end
      if num == 1 then
          ccb.m_LightLabel:setVisible(true)
          if dFlag then
              ccb.m_LightLabel:setString("见光死")
          else
              ccb.m_LightLabel:setString("订卖+"..g_data.roomSys.Additional.."分")
          end
      elseif num == 2 then
          ccb.m_LightLabel:setVisible(true)
          ccb.m_PortionLabel:setVisible(true)
          ccb.m_LightLabel:setString("见光死")
          ccb.m_PortionLabel:setString("订卖+"..g_data.roomSys.Additional.."分")
      end
  end

  if table_type == "tianzhu" then
     if  g_data.roomSys.IsMenGangMulti2 ~=nil then
      if g_data.roomSys.IsMenGangMulti2 == 1 then
        ccb.m_LightLabel:setVisible(true)
        ccb.m_LightLabel:setString("闷杠x2")
      end
    end
    if g_data.roomSys.supplementPriceFlag ~=nil then
       if g_data.roomSys.supplementPriceFlag == 1 then
        ccb.m_PortionLabel:setVisible(true)
        ccb.m_PortionLabel:setString("补差价")
       end
    end
  end
end

function RoomInfoPanel:onClick(_sender, _event)
  -- if self.state  == state.open then
  --   self.state  = state.close
  --   self.m_ccbRoot.m_connet:stopAllActions()
  --   self.m_ccbRoot.m_connet:runAction(cc.MoveTo:create(0.3,cc.p(-135,36)))
  --   self.m_ccbRoot.m_sprite:setSpriteFrame("room_infoPanel_right.png")
  -- else
  --   self.state  = state.open
  --   self.m_ccbRoot.m_connet:stopAllActions()
  --   self.m_ccbRoot.m_connet:runAction(cc.MoveTo:create(0.3,cc.p(-15,36)))
  --   self.m_ccbRoot.m_sprite:setSpriteFrame("room_infoPanel_left.png")
  -- end
end

--返回大厅
function RoomInfoPanel:onBack(_sender, _event)
    g_utils.setButtonLockTime(_sender,0.5)
    g_netMgr:close()
    g_data.userSys.roomState = 1
    app:enterMainScene() 
end


return RoomInfoPanel