--[[
	锁定底部touch
	例：
	-- 	local node = require("lib.ui.UILockLayer").new()
	--	local node = require("lib.ui.UILockLayer").new(cc.c4b(0, 0, 0, 128))
]]

local UILockLayer = class("UILockLayer", function()
		local node = display.newNode()
		node:setNodeEventEnabled(true)
		return node
	end)

--可传入锁定层颜色(c4b)
function UILockLayer:ctor(_color)
	if _color then
		self.m_colorlayer = display.newColorLayer(_color)
		self.m_colorlayer:addTo(self,1,1)
	end
	self.m_touchHandle = nil
	self:lock()
end

--锁定触摸
function UILockLayer:lock()
   	self:unlock()
    print("UILockLayer:lock")
	-- 创建一个事件监听器类型为 OneByOne 的单点触摸
	local listenner = cc.EventListenerTouchOneByOne:create()
    -- ture 吞并触摸事件,不向下级传递事件;
    -- fasle 不会吞并触摸事件,会向下级传递事件;
    -- 设置是否吞没事件，在 onTouchBegan 方法返回 true 时吞没
    listenner:setSwallowTouches(true)
    -- 实现 onTouchBegan 事件回调函数
    listenner:registerScriptHandler(function(touch, event)
        local location = touch:getLocation()
        -- printf("EVENT_TOUCH_BEGAN: %0.2f, %0.2f", location.x, location.y)
        local r = true
        if self.m_touchBeganFunc then
            r = self.m_touchBeganFunc(touch,event)
        end
        return r
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    -- 实现 onTouchMoved 事件回调函数
    listenner:registerScriptHandler(function(touch, event)
    	local location = touch:getLocation()
    	-- printf("EVENT_TOUCH_MOVED: %0.2f, %0.2f", location.x, location.y)
        if self.m_touchMoveFunc then
        	self.m_touchMoveFunc(touch,event)
        end
    end, cc.Handler.EVENT_TOUCH_MOVED)
    -- 实现 onTouchEnded 事件回调函数
    listenner:registerScriptHandler(function(touch, event)
    	local location = touch:getLocation()
    	-- printf("EVENT_TOUCH_ENDED: %0.2f, %0.2f", location.x, location.y)

    	if self.m_touchEnedFunc then
        	self.m_touchEnedFunc(touch,event)
        end

    	if self.m_closeRecct then
        	if cc.rectContainsPoint( self.m_closeRecct, location ) then
        		print("no close.......")
        	else
        		if self.m_closeFunc then
        			self.m_closeFunc()
        		end
        		print("close layer")
        	end
        end

        -- local locationInNodeX = self:convertToNodeSpace(touch:getLocation()).x
        -- print("EVENT_TOUCH_ENDED")
        -- if self:isTouchEnabled() then
        -- 	self:EventDispatcher(cc.NODE_TOUCH_EVENT, {name="ended",x=location.x,y=location.y})
        -- end
    end, cc.Handler.EVENT_TOUCH_ENDED)
	-- 添加监听器
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
	self.m_touchHandle = listenner

	if self.m_colorlayer then
		self.m_colorlayer:setVisible(true)
	end

	-- self:setTouchEnabled(true)
	-- self:setTouchSwallowEnabled(true)
	-- -- 注册触摸事件
	-- self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	--     printf("sprite: %s x,y: %0.2f, %0.2f", event.name, event.x, event.y)
	--     if event.name == "began" then
	--     	print("你妹啊")
	--         return true
	--     end
	-- end)
end

--解锁触摸
function UILockLayer:unlock()
	if self.m_touchHandle then
    	local eventDispatcher = self:getEventDispatcher()
    	eventDispatcher:removeEventListener(self.m_touchHandle)
    	self.m_touchHandle = nil
	end
	if self.m_colorlayer then
		self.m_colorlayer:setVisible(false)
	end
end

function UILockLayer:setTouchBeganFunc(_func)
	self.m_touchBeganFunc = _func
end

function UILockLayer:setTouchMovedFunc(_func)
	self.m_touchMoveFunc = _func
end

function UILockLayer:setTouchEndedFunc(_func)
	self.m_touchEnedFunc = _func
end

function UILockLayer:setCloseWithLayer(_layer,_func)
	local size = _layer:getContentSize()
	local posX,posY = _layer:getPosition()
	local wordPos = _layer:getParent():convertToWorldSpace(cc.p(posX,posY))
	local anchorPos = _layer:getAnchorPoint()
	local rect  = cc.rect(wordPos.x-size.width * anchorPos.x,wordPos.y - size.height * anchorPos.y,size.width,size.height)
	self:setCloseWithRect(rect,_func)
end

function UILockLayer:setCloseWithRect(_rect , _func)
	print("UILockLayer:setCloseRect::::",_rect.x, _rect.y,_rect.width,_rect.height)
	self.m_closeRecct = _rect
	self.m_closeFunc = _func
end

--弹出框 弹出效果
function UILockLayer:showOpen(_fun)
	local callfunc = nil
	if _fun then
		callfunc = cc.CallFunc:create(_fun)
	end
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(cc.p(display.width*0.5, display.height*0.5))
	self:setScale(0.4)
	local scaleto = cc.ScaleTo:create(0.5, 1.0)
	self:runAction(cc.Sequence:create({cc.EaseElasticOut:create(scaleto), callfunc}))
end

--弹出框 收回效果
function UILockLayer:showClose(_fun)
	local callfunc = nil
	if _fun then
		callfunc = cc.CallFunc:create(_fun)
	end
	local scaleto = cc.ScaleTo:create(0.5, 0.4)
	self:runAction(cc.Sequence:create({cc.EaseElasticIn:create(scaleto), callfunc}))
end

return UILockLayer
