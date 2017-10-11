
local ccbfile = "ccb/cardItemLeft.ccbi"
local TileItem = require("app.common.component.sprites.TileItem")
local TileItemLeft = class("TileItemLeft",TileItem)

function TileItemLeft:ctor(_op,eTile)
  self.super.ctor(self,ccbfile,_op,eTile,TileDirection.Direction_Left)
end

function TileItemLeft:initUI(op)
	self.super.initUI(self,op)
	local h3 =  self.heights[3]
    local h4 =  self.heights[4]

    if  op == OperateType.pong then
        self:setCardOffset(h4)
    elseif  op == OperateType.Left_pong then
        self:setCardOffset(h3+h4)
    elseif op == OperateType.Mid_pong then
        self:setCardOffset(h3+h4)
    elseif op == OperateType.Left_kong then
       self:setCardOffset(h4)
    elseif op == OperateType.Right_kong then
    elseif op == OperateType.Mid_kong then
       self:setCardOffset(h4)
    elseif op == OperateType.Fill_kong then
       self:setCardOffset(h4)
    else
        self:setCardOffset(0)
    end
end

--设置偏移
function TileItemLeft:setCardOffset(_offset)
	for k, v in pairs(self.child) do
		local y = v:getPositionY()
		v:setPositionY(y - _offset)
    end
end

return TileItemLeft