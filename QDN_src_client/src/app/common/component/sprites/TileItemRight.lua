
local ccbfile = "ccb/cardItemRight.ccbi"
local TileItem = require("app.common.component.sprites.TileItem")
local TileItemRight = class("TileItemRight", TileItem)

function TileItemRight:ctor(_op,eTile)
   self.super.ctor(self,ccbfile,_op,eTile,TileDirection.Direction_Right)
end

function TileItemRight:initUI(op)
	self.super.initUI(self,op)

	local h1 =  self.heights[1]
    local h6 =  self.heights[6]

    if op == OperateType.Right_pong then
       self:setCardOffset(h1+h6)
    end

    if  op == OperateType.pong or 
        op == OperateType.Mid_pong or 
        op == OperateType.Mid_kong or
        op == OperateType.Fill_kong or 
        op == OperateType.Right_kong or
        op == OperateType.Self_kong then

        self:setCardOffset(h6)
    end
end

--设置偏移
function TileItemRight:setCardOffset(_offset)
	for k, v in pairs(self.child) do
		local y = v:getPositionY()
		v:setPositionY(y - _offset)
    end
end
return TileItemRight