
local UIBoxLayout = require("framework.cc.ui.UIBoxLayout")
local UIGroup = require("framework.cc.ui.UIGroup")

local TileItemGroup = class("TileItemGroup", UIGroup)


function TileItemGroup:ctor(direction)
    self.super.ctor(self)

    self.direction = direction

    local tb   = {
        [CardDefine.direction.bottom] = "app.common.component.sprites.TileItemBottom",
        [CardDefine.direction.right]  = "app.common.component.sprites.TileItemRight",
        [CardDefine.direction.top]    = "app.common.component.sprites.TileItemTop",
        [CardDefine.direction.left]   = "app.common.component.sprites.TileItemLeft",
}

    self.cardItem  = require(tb[direction])
    self:setLayout(UIBoxLayout.new(CardDefine.CardItemGroupDirection[direction]))
    if  self.direction == TileDirection.Direction_Top then
         self:setLayoutSize(display.width, 200)
         self:setPosition(-310,display.height-160)
    elseif self.direction == TileDirection.Direction_Bottom then
        self:setPosition(60,45)
    elseif self.direction == TileDirection.Direction_Left then
        self:setLayoutSize(200,display.height)
        self:setPosition(140, - 50)
    elseif self.direction == TileDirection.Direction_Right then
        self:setPosition(display.width-250,160)
    end
    self.m_items = {}
    self.args_ = {direction}
end

function TileItemGroup:addItem_(item)
    self:addChild(item)
    self.m_items[#self.m_items + 1] = item
    self:getLayout():addWidget(item):apply(self)
    return self
end

--增加牌组
function TileItemGroup:addItem(op,eTile)
    local isContain,value = self:isContain(eTile)
    if isContain then
        value:initUI(op)
        self:getLayout():apply(self)
        return
    end
    local item = self.cardItem.new(op,eTile)
    self:addItem_(item)
end

function TileItemGroup:setLayoutSize(width, height)
    self:getComponent("components.ui.LayoutProtocol"):setLayoutSize(width, height)
    return self
end

function TileItemGroup:getLayoutSize()
   return self:getComponent("components.ui.LayoutProtocol"):getLayoutSize()
end

--是否已经包含
function TileItemGroup:isContain(eTile)
    for _, item in ipairs(self.m_items) do
       if item.m_eTile == eTile then
            return true,item
       end
    end
    return false,nil 
end

function TileItemGroup:setItemsLayoutMargin(top, right, bottom, left)
    for _, item in ipairs(self.m_items) do
        item:setLayoutMargin(top, right, bottom, left)
    end
    self:getLayout():apply(self)
    return self
end

function TileItemGroup:removeAllItems()
    local layout = self:getLayout()
    for _, item in ipairs(self.m_items) do
       layout:removeWidget(item)
       item:removeFromParent(true)
    end
    self.m_items = {}
    layout:apply(self)
end

function TileItemGroup:onSelectedTile(eTile)
    for _, item in ipairs(self.m_items) do
        if item.m_eTile == eTile then
            item:setTileColor(cc.c3b(124,165,130))
        else
            item:setTileColor(cc.c3b(255,255,255))
        end
    end
end

return TileItemGroup