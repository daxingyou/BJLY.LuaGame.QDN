
local ccbFile = "csb/CommonView/LayerLoading.csb"
local LayerLoading = class("LayerLoading",function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerLoading:ctor()
    self:init()
end

function LayerLoading:init()
    self:LoadCCB()
end

function LayerLoading:LoadCCB()

    local colorLayer = display.newColorLayer(cc.c4b(0, 0, 0, 170))
    colorLayer:setCascadeOpacityEnabled(true)
    colorLayer:setOpacity(150)
    colorLayer:addTo(self)
    
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    self.m_sprite = _UI:getChildByName("icon_loading")
    -- self.m_sprite:setAnchorPoint(cc.p(0.5,0.5))
    -- self.m_sprite:setVisible(false)
    -- self.m_sprite:stopAllActions()
    -- self.m_sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2.0, 360)))
end


function LayerLoading:show(_delay)
    self:setVisible(true)
    self.m_sprite:stopAllActions()
    self.m_sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2.0, 360)))
    self:lock()
end

function LayerLoading:hide()
    self:setVisible(false)
    self.m_sprite:stopAllActions()
    self:unlock()
end

return LayerLoading