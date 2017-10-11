--
-- Author: Your Name
-- Date: 2017-08-08 13:54:34
--
local m = class("GameSpriteUtil")

function m:addHeadIconClipping(headIconSprite,floorColor)
    local scale = headIconSprite:getScale()
    local sizeWidth = headIconSprite:getContentSize().width
    local sizeHeight = headIconSprite:getContentSize().height
    local sideWidth = 3
    -- -- 遮罩效果
    -- -- 模板 
    local stencil = cc.Node:create()
    local dogTmp = display.newSprite("res/srcRes/LobbyScene/default_head.png")
    dogTmp:setScale(scale)
    stencil:addChild(dogTmp)
    stencil:setPosition((sizeWidth+sideWidth)*0.5,(sizeHeight+sideWidth)*0.5)

    -- 初始化一个裁剪节点            
    local clippingNode = cc.ClippingNode:create(stencil)
    -- 倒置（Inverted） 如果设置为真（true），模板（stencil）会被反转，此时会绘制内容而不绘制模板（stencil）。 默认设置为假（false）    
    clippingNode:setInverted(true)
    --    alpha阈值（threshold） 只有模板（stencil）的alpha像素大于alpha阈值（alphaThreshold）时内容才会被绘制。 alpha阈值（threshold）范围应是0到1之间的浮点数。 alpha阈值（threshold）默认为1（alpha测试默认关闭）
    clippingNode:setAlphaThreshold(0)
    

    -- -- 底板
    local floor = cc.LayerColor:create(floorColor)
    floor:setContentSize(cc.size(sizeWidth+sideWidth,sizeHeight+sideWidth))
    clippingNode:addChild(floor)
    local x,y = headIconSprite:getPositionX() - (sizeWidth+sideWidth)*0.5,headIconSprite:getPositionY() - (sizeHeight+sideWidth)*0.5
    clippingNode:setPosition(cc.p(x,y))

    headIconSprite:getParent():addChild(clippingNode)
    headIconSprite:setLocalZOrder(-3)
    clippingNode:setLocalZOrder(-2)
    local res = {
            clippingNode = clippingNode,
            floorLayerColor = floorLayerColor,
        }
    return res
end


function m:addClip(headIconSprite)
	-- local headimage = Data.User.selfInfo:loadImage()
    local size = headIconSprite:getContentSize()
 --    local rect = headimage:getTextureRect()
 --    headimage:setLocalZOrder(-1)
 --    headimage:setScale((size.width)/rect.size.width)

    local stencil = display.newSprite("res/srcRes/LobbyScene/frame_head.png")
    local clipNode = CCClippingNode:create()  
    clipNode:setStencil(stencil)
    clipNode:setAlphaThreshold(0)
    clipNode:addTo(headIconSprite)
    clipNode:setPosition(cc.p(size.width/2,size.height/2))
     
    -- headimage:addTo(clipNode)
    -- headIconSprite:getParent():addChild(clip)
end

return m