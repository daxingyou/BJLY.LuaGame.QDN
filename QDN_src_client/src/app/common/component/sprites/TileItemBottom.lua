

local ccbfile  = "ccb/cardItemBottom.ccbi"
local TileItem = require("app.common.component.sprites.TileItem")
local TileItemBottom = class("TileItemBottom", TileItem)

function TileItemBottom:ctor(_op,eTile)
   self.super.ctor(self,ccbfile,_op,eTile,TileDirection.Direction_Bottom)
end

function TileItemBottom:initUI(op)
	self.super.initUI(self,op)

	local w6 =  self.child[6]:getContentSize().width*self.child[6]:getScale()
  	local w1 =  self.child[1]:getContentSize().width*self.child[1]:getScale()
  	if op == OperateType.Right_pong then
 		 self:setCardOffset(w1+w6)
  	end

  	if  op == OperateType.pong or 
 	    op == OperateType.Mid_pong or
      	op == OperateType.Right_kong or 
 	    op == OperateType.Mid_kong or
 	    op == OperateType.Fill_kong or 
 	    op == OperateType.Self_kong then
	    self:setCardOffset(w6)
  end
end

--设置偏移
function TileItemBottom:setCardOffset(_offset)
	for k, v in pairs(self.child) do
		local x = v:getPositionX()
		v:setPositionX(x - _offset)
    end
end

function TileItemBottom:updatePos()

end

return TileItemBottom