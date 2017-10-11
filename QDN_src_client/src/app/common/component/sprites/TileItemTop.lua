
local ccbfile = "ccb/cardItemTop.ccbi"
local TileItem = require("app.common.component.sprites.TileItem")
local TileItemTop = class("TileItemTop",TileItem)

function TileItemTop:ctor(_op,eTile)
    self.super.ctor(self,ccbfile,_op,eTile,TileDirection.Direction_Top)
end


function TileItemTop:initUI(op)
    self.super.initUI(self,op)

    self.child[1]:setVisible( op == OperateType.pong or
                op == OperateType.Right_pong or
                          op == OperateType.Mid_pong or
                          op == OperateType.Left_kong or
                          op == OperateType.Right_kong or
                          op == OperateType.Self_kong or 
                          op == OperateType.Mid_kong or 
                op == OperateType.Fill_kong)
    
    self.child[2]:setVisible(true)
    self.child[3]:setVisible( op == OperateType.pong or
                op == OperateType.Left_pong or
                          op == OperateType.Left_kong or
                          op == OperateType.Right_kong or
                          op == OperateType.Self_kong or
                          op == OperateType.Mid_kong or
                          op == OperateType.Fill_kong)
   
    self.child[4]:setVisible( op == OperateType.Right_pong or
                          op == OperateType.Right_kong)

    self.child[5]:setVisible( op == OperateType.Mid_kong)
    
    self.child[6]:setVisible( op == OperateType.Left_pong or
                          op == OperateType.Left_kong)

    self.child[7]:setVisible( op == OperateType.Fill_kong or 
                          op == OperateType.Self_kong)
    self.child[8]:setVisible( op == OperateType.Mid_pong)

    local _width  = 0
    local _height = 0 
    for k, v in pairs(self.child) do
        if k == 1 or k == 2 or k == 3 or k == 4 or k == 6 then
            if v:isVisible() then
              _width   = _width  + v:getContentSize().width*v:getScaleX()
              _height  = _height + v:getContentSize().height*v:getScaleY() -4.5
            end
        end
        if op == OperateType.Self_kong then
            if k == 1 or k == 2 or k == 3 then
              v:getChildByTag(30):setVisible(false)
            end
        end
    end
    _width = _width + 10
 
    self:setLayoutSize(_width, _height)

    local w3 = self.child[3]:getContentSize().width* self.child[3]:getScale()
    local w4 = self.child[4]:getContentSize().width* self.child[4]:getScale()
  
    if op == OperateType.Left_pong  then --责任鸡特殊与bottom不一样
        self:setCardOffset(w3+w4)
    end

    if  op == OperateType.pong or 
        op == OperateType.Mid_pong or
        op == OperateType.Mid_kong or
        op == OperateType.Fill_kong or 
        op == OperateType.Left_kong or
        op == OperateType.Self_kong then
          self:setCardOffset(w4)
   end
end

--设置偏移
function TileItemTop:setCardOffset(_offset)
    for k, v in pairs(self.child) do
        local x = v:getPositionX()
        v:setPositionX(x - _offset)
  end
end

return TileItemTop