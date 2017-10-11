local Tile = require("app.common.component.sprites.Tile")

--[[
  打出去的麻将牌
]]
local OutTile = class("OutTile",Tile)

function OutTile:ctor(eTile,eDirection)
	OutTile.super.ctor(self,eTile,eDirection)
	self.out_direction   = eDirection
	self.isChargeChicken = false
	self.animationing    = false

	self.bg = display.newSprite("#room_out_tile_bg.png")
	self.bg:setAnchorPoint(cc.p(0.5,0.5))
	self.bg:setScale(1.4)
	self.bg:setVisible(false)

	self.step = {x = 0,y = 0}
	local parent = self.m_ccbRoot.m_bg:getParent()
	local x, y   = self.m_ccbRoot.m_bg:getPosition()
	if parent then
		self.bg:addTo(parent,-1)
		if self.out_direction == TileDirection.Direction_Right then
			self.bg:setPosition(x-1, y)
		else
			self.bg:setPosition(x-14, y)
		end
	end
end

--设置冲锋鸡
function OutTile:setChargeChicken()
	OutTile.super.setChargeChicken(self)
	self.isChargeChicken = true
end

function OutTile:outAnimation(callback)
	
	self.animationing =true
	self:setTileDirection(TileDirection.Direction_Bottom)
	self:stopAllActions()
	local x = self.step.x
	local y = self.step.y

    self.bg:setVisible(true)
    
	local midx  = 0
	local midy  = 0
	if self.out_direction == TileDirection.Direction_Bottom then
		midx = display.width/2 - 32
		midy = 180
	end

	if self.out_direction == TileDirection.Direction_Top then
		midx = display.width/2 - 40
		midy = 460
	end

	if self.out_direction == TileDirection.Direction_Left then
		midx = 240
		midy = display.height/2
	end

	if self.out_direction == TileDirection.Direction_Right then
		midx = display.width - 300
		midy = display.height/2
	end
	-- print("midx=== midy====",midx,midy)
	-- print("contet=====",self:getContentSize().width)
    self:setPosition(midx,midy)
	local time = 0.5
	local scale = self:getScale()
	self:setScale(0.7)
	local moveActions = {}

	
	local move_delay = cc.DelayTime:create(0.9*time)
	moveActions[#moveActions+1] = move_delay
	local move_end   = cc.MoveTo:create(time*0.1, cc.p(x,y))
	moveActions[#moveActions+1] = move_end

	local scaleActions = {}
	
	local scale_delay = cc.DelayTime:create(0.9*time)
	scaleActions[#scaleActions+1] = scale_delay
	local scale_end   = cc.ScaleTo:create(time*0.1,scale)
	scaleActions[#scaleActions+1] = scale_end

	self.zOrder = self:getLocalZOrder()
	self:setLocalZOrder(1000)
	self:runAction(cc.Sequence:create({
	        cc.Spawn:create({
	            cc.Sequence:create(moveActions),
	            cc.Sequence:create(scaleActions),
	        }),
	    	cc.CallFunc:create(
	    		function() --结束后回调
		    		self.animationing = false
		    		self:setLocalZOrder(self.zOrder)
		    		self.bg:setVisible(false)
		    		self:setTileDirection(self.out_direction)
		    		if self.isChargeChicken then
		    			self:setChargeChicken()
		    		end
		    		if callback then
		    			callback()
		    		end
	       		 end
	       	)
   		}))
end

function OutTile:setTileDirection(eDirection)
	self.m_direction = eDirection
	self:setTileState(self.m_tileState)
end

function OutTile:setTileTypeAndDirection(eTile,eDirection)
	self:setTileType(eTile)
	self.out_direction = eDirection
	self.m_direction = eDirection
	self:setTileState(TileState.TileType_Open)
end

return OutTile