--[[
    可点击的图片，可以设置响应的优先级。
    比如ScrollView上的按钮，可以用UITouchSprite实现。将UITouchSprite设置为不吞噬消息即可。
    
    ~~~lua

	local tv = self:getTableView()
	local DISTANCE = 10
	
	-- 点击点击事件
    local function equip_touch_began_listener(sender, touch, event)
    end

    -- 点击结束事件
    local function equip_touch_ended_listener(sender, touch, event)
        -- if tv:isTouchMoved() then
        --     return
        -- end
        local start_pt = touch:getStartLocation()
        local end_pt = touch:getLocation()
        -- move过10像素则视为滑动
        local dis = cc.pGetDistance(start_pt, end_pt)
        if math.abs(dis) <= DISTANCE then
            print(_idx, sender.m_id)
            if self.m_listener then
            	self.m_listener(sender.m_idx, sender.m_id)
            end
        end
    end

    -- 添加到ScrollView上可点击的图片
    local sp = require("lib.ui.UITouchSprite").new("#pet_i101.png", 
    	equip_touch_began_listener, 
    	equip_touch_ended_listener, 
    	false)

    sp.m_idx = _idx
    sp.m_id = i
    self:addChild(sp)
    sp:setPosition(cellSize.width*0.5, cellSize.height*0.5)

    ~~~lua

]]
local UITouchSprite = class("UITouchSprite", function(pic_path)
        return display.newSprite(pic_path)
    end)

UITouchSprite.__index = UITouchSprite
UITouchSprite.listener_ = nil
UITouchSprite.swallowTouch_ = true
UITouchSprite.fixedPriority_ = 0
UITouchSprite.useNodePriority_ = false
UITouchSprite.removeListenerOnTouchEnded_ = false
UITouchSprite.touch_began_listener_ = nil
UITouchSprite.touch_ended_listener_ = nil

--[[
构造一个可响应点击事件的UITouchSprite。

~~~lua
    
    -- 监听器有三个参数,第一个参数是自己
    local function touch_began_listener(sender, touch, event)
    end

    local function touch_ended_listener(sender, touch, event)
        local start_pt = touch:getStartLocation()
        local end_pt = touch:getLocation()
        if checkint(start_pt.x) == checkint(end_pt.x) and checkint(start_pt.y) == checkint(end_pt.y) then
            print(sender.id_)
            print("Ready to equip......")
        end
    end

    local sp = UITouchSprite.new("data/equip.png", 
            equip_touch_began_listener,
            equip_touch_ended_listener)

    sp:setTexture("data/equip1.png")
    sp:setPriority(1)
    parent:addChild(sp)
    
~~~lua

@param string pic_path 传入图片路径.可为空，后通过:setTexture("pic_path")重新设置
@param touch_began_listener 点击开始事件的监听器。为空时不响应。 监听器有三个参数,第一个参数是可点击图片自己
@param touch_ended_listener 点击结束时事件监听器。为空时不响应。 监听器有三个参数,第一个参数是可点击图片自己
@param swallow_touch 是否吞噬事件 true 事件不再向下传递 false 响应完事件后，继续向下传递
]]
function UITouchSprite:ctor(pic_path, touch_began_listener, touch_ended_listener, swallow_touch)
    self.touch_began_listener_ = touch_began_listener
    self.touch_ended_listener_ = touch_ended_listener
    self.swallowTouch_ = swallow_touch

     local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end
    
    self:registerScriptHandler(onNodeEvent)
end

function UITouchSprite:setTouchBeganListener(touch_began_listener)
    self.touch_began_listener_ = touch_began_listener
end

function UITouchSprite:setTouchEndedListener(touch_ended_listener)
    self.touch_ended_listener_ = touch_ended_listener
end

function UITouchSprite:onEnter()
    local eventDispatcher = self:getEventDispatcher()

    local function onTouchBegan(touch, event)
        local locationInNode = self:convertToNodeSpace(touch:getLocation())
        local s = self:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
            
        if cc.rectContainsPoint(rect, locationInNode) then
            if self.touch_began_listener_ then
                self.touch_began_listener_(self, touch, event)
            end
            return true
        end

        return false    
    end

    local function onTouchMoved(touch, event)
        
    end

    local function onTouchEnded(touch, event)
        print("onTouchEnded.......")
        if self.touch_ended_listener_ then
            self.touch_ended_listener_(self, touch, event)
        end

        if self.removeListenerOnTouchEnded_ then
            eventDispatcher:removeEventListener(self.listener_)
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    self.listener_ = listener
    listener:setSwallowTouches(self.swallowTouch_)
    
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )

    if 0 == self.fixedPriority_ then
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    else
        eventDispatcher:addEventListenerWithFixedPriority(listener,self.fixedPriority_)
    end
end

function UITouchSprite:setSwalllowTouch(swallow)
    self.swallowTouch_ = swallow
end

function UITouchSprite:onExit()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self.listener_)
end

function UITouchSprite:setPriority(fixedPriority)
    self.fixedPriority_ = fixedPriority
    self.useNodePriority_ = false
end

function UITouchSprite:removeListenerOnTouchEnded(toRemove)
    self.removeListenerOnTouchEnded_ = toRemove
end

function UITouchSprite:setPriorityWithNode(useNodePriority)
    self.fixedPriority_ = 0
    self.useNodePriority_ = useNodePriority
end

return UITouchSprite