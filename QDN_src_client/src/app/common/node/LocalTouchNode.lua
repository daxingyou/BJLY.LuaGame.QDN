--
-- Author: XuJian
-- 局部点击区域
--

local print = function() end

local LocalTouchNode = class("LocalTouchNode", function() 
		local node = display.newNode()
    	return node
	end)

function LocalTouchNode:ctor(_spr)
    --范围控制精灵
    self.m_rectSpr = _spr
    self.m_rectSpr:retain()
    -- self.m_rectSpr:setColor(cc.c3b(255, 255, 255))
    -- self.m_rectSpr:setOpacity(128)

    self:regTouch()
    self:setTouchEnabled(true)
end

function LocalTouchNode:onCleanup()
    if self.m_rectSpr then
        self.m_rectSpr:release()
        self.m_rectSpr = nil
    end
end

function LocalTouchNode:regTouch()
	-- 创建一个事件监听器类型为 OneByOne 的单点触摸
	local listenner = cc.EventListenerTouchOneByOne:create()
    -- ture 吞并触摸事件,不向下级传递事件;  
    -- fasle 不会吞并触摸事件,会向下级传递事件;  
    -- 设置是否吞没事件，在 onTouchBegan 方法返回 true 时吞没
    listenner:setSwallowTouches(false)
    -- 实现 onTouchBegan 事件回调函数
    listenner:registerScriptHandler(function(touch, event)
        local curPos = touch:getLocation()
        local prePos = touch:getPreviousLocation()
        self:touchEvent("began", curPos, prePos)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    -- 实现 onTouchMoved 事件回调函数  
    listenner:registerScriptHandler(function(touch, event)
        local curPos = touch:getLocation()
        local prePos = touch:getPreviousLocation()
        self:touchEvent("moved", curPos, prePos)
    end, cc.Handler.EVENT_TOUCH_MOVED)
    -- 实现 onTouchEnded 事件回调函数  
    listenner:registerScriptHandler(function(touch, event)
        local curPos = touch:getLocation()
        local prePos = touch:getPreviousLocation()
        self:touchEvent("ended", curPos, prePos)
    end, cc.Handler.EVENT_TOUCH_ENDED)
	-- 添加监听器
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
	self.m_touchHandle = listenner
end

--触摸事件
function LocalTouchNode:touchEvent(_event, _pos, _pre)
    print("LocalTouchNode touchevent:", _event, _pos.x, _pos.y, _pre.x, _pre.y)


    if not self:isTouchEnabled() then
        print("not touch enabled")
        return false
    end

    if not self:isRectTouch(_pos) then
        print("not rect touch")
        return false
    end
    
    print("点中啦")
    self:touchFun(_event, _pos, _pre)
    return true
end

--可触摸范围控制
function LocalTouchNode:isRectTouch(_touchPos)
    -- local pos = self.m_rectSpr:convertToNodeSpace(_touchPos)
    local pos = _touchPos
    local r = self.m_rectSpr:getBoundingBox()
    r.x,r.y = 0,0
    local rpos = self.m_rectSpr:convertToWorldSpace(cc.p(r.x, r.y))
    r.x,r.y = rpos.x,rpos.y
    print("isRectTouch", r.x, r.y, r.width, r.height, pos.x, pos.y)
    if cc.rectContainsPoint(r, pos) then
        return true
    end
    return false
end

function LocalTouchNode:setListen(_fun)
	self.m_touchFun = _fun
end

function LocalTouchNode:touchFun(_event, _pos, _pre)
	if self.m_touchFun then
		self.m_touchFun(_event, _pos, _pre)
	end
end

return LocalTouchNode