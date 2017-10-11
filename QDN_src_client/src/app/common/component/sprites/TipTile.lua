local Tile = require("app.common.component.sprites.Tile")
--[[
麻将牌
]]
local TipTile = class("OutTile",Tile)

function TipTile:ctor(eTile)
  TipTile.super.ctor(self,eTile,TileDirection.Direction_Bottom)
  self:setTileState(TileState.TileType_Open)

  self.bg = display.newSprite("#room_out_tile_bg.png")
  self.bg:setAnchorPoint(cc.p(0.5,0.5))
  self.bg:setScale(1.4)
  self.bg:setVisible(false)

  self.step = {x = 0,y = 0}
  local parent = self.m_ccbRoot.m_bg:getParent()
  local x, y   = self.m_ccbRoot.m_bg:getPosition()
  if parent then
    self.bg:addTo(parent,-1)
    self.bg:setPosition(x-1.6, y)
  end
end

return TipTile