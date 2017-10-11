local GameUtils = {}
-- Date: 2017-06-11 18:23:49

--[[
    带标题的打印table
]]
function printTable(_title, _t, _n)
    if DEBUG == 0 then return end
    local traceback = string.split(debug.traceback("", 2), "\n")
    print("dump from: " .. string.trim(traceback[3]))
    dump(_t, _title, _n or 10)
end

--设置按钮点击
function GameUtils.setButtonClick(_btn,_handler,_sound)

    local __cname = tolua.type(_btn)
    print("GameUtils__cname==",__cname)
    if __cname == "ccui.Button" then
		_btn:addClickEventListener(
		function () 
			_handler(_btn) 
		end)

	elseif "ccui.Text" == __cname then
		_btn:setTouchEnabled(true)
		_btn:addTouchEventListener(
			function (sender,_event)
				if _event == 0 then
					_handler(_btn) 
				end
			end)

	elseif "ccui.CheckBox" == __cname then
		_btn:addEventListener(
		function () 
			_handler(_btn) 
		end)

    elseif "cc.Sprite" == __cname then
        local function onTouchBegan(touch, event)
            local locationInNode = _btn:convertToNodeSpace(touch:getLocation())
            local s = _btn:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)                
            if cc.rectContainsPoint(rect, locationInNode) then                
                return true
            end
            return false  
        end
        local function onTouchEnded(touch, event)
            _handler(_btn)
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = _btn:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, _btn)
    elseif "ccui.ImageView" == __cname then
        _btn:setEnabled(true)
        _btn:addClickEventListener(
            function () 
                _handler(_btn) 
            end)
    end
end

--table多条件排序 升序  tableSortAsc(tb, _key1, _key2)
function GameUtils.tableSortAsc(t,...)
    local args = {...}
    local function _sortfunc(a,b,idx)
        if args[idx+1] then
            if a[args[idx]]==b[args[idx]] then return _sortfunc(a,b,idx+1) end
        end
        return a[args[idx]]<b[args[idx]]
    end
    table.sort(t,function(a,b)
        return _sortfunc(a,b,1)
    end)
end

--指定时间内按钮不可再点(时间默认0.5)
function GameUtils.setButtonLockTime(_btn, _t)
    _btn:setEnabled(false)
    _btn:performWithDelay(function() _btn:setEnabled(true) end, _t or 0.5)
end

--[[
    收集器效果(对象，时间，目标点，结束回调)
]]
function GameUtils.showCollector(_node, _time, _pos, _callback)
    _node:runAction(cc.Sequence:create({
            cc.Spawn:create({
                cc.EaseBackInOut:create(cc.MoveTo:create(_time, _pos)), --冲
                cc.Sequence:create({    --放大到缩小
                    cc.ScaleTo:create(0.3*_time, 1.5),
                    cc.ScaleTo:create(0.7*_time, 0.5)
                    })
                }),
            cc.CallFunc:create(function() --结束后回调
                -- _node:removeSelf()
                -- _node:setVisible(false)
                _callback()
                end)
        }))
end

--[[
    添加粒子效果
    g_utils.playParticleFile("pex_love.plist",parentNode,self.cc.p(1166/2,640/2),1,true)
]]
function GameUtils.playParticleFile(_particleFile,_parentNode,_pos,_zOrder, _isAutoRemove,_playTime)
    _zOrder = _zOrder or 0
    local particleSys = cc.ParticleSystemQuad:create(_particleFile)
    print("particleSys =",particleSys)
    particleSys:addTo(_parentNode)
    particleSys:setLocalZOrder(_zOrder)
    particleSys:setPosition(_pos)
    local isAutoRemove = true
    if nil ~= _isAutoRemove then
        isAutoRemove = _isAutoRemove
    end
    particleSys:setAutoRemoveOnFinish(isAutoRemove)
    if _playTime then
        particleSys:runAction(cc.Sequence:create({
            cc.DelayTime:create(_playTime), --暂停

            cc.CallFunc:create(function() --结束
                particleSys:stopSystem()
                -- particleSys:removeSelf()
            end)
        }))
    end
    return particleSys
end

function GameUtils.setCellButtonClick(_btn,_handler)
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        target.beganP = touch:getLocation()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)                
        if cc.rectContainsPoint(rect, locationInNode) then                
            return true
        end
        return false  
    end

    local function onTouchMoved(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local dis = cc.pGetDistance(touch:getLocation(),target.beganP)
        if dis < 8 then
            if _handler then
                _handler(target)
            end
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

    local eventDispatcher = _btn:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, _btn)
end


--根据指定的时间秒数，返回时间table{minute,second}   00  02
function GameUtils.getTimeTableBySceond2(_seconds)
    if not _seconds then return end
    local timeTab={}
    local function changeNum(_num,_type)
    if _num<=0 then
            if _type~=0 then
                _num="00"
            end
        elseif _num<10 then
            if _type~=0 then
                _num="0".._num
            end
        end
        return _num
    end

    local minute = changeNum(math.floor(_seconds/ 60),2)
    local second = changeNum(_seconds % 60,3)
    timeTab["minute"]=minute
    timeTab["second"]=second
    return timeTab
end

--设置ControlButton显示图片
function GameUtils.setControlButtonImage(_button,_frameName)
    --cc.CONTROL_STATE_NORMAL
    --cc.CONTROL_STATE_HIGH_LIGHTED
    --cc.CONTROL_STATE_DISABLED
    -- local f1 = display.newScale9Sprite(_frameName)
    -- local f2 = display.newScale9Sprite(_frameName)
    -- local f3 = display.newScale9Sprite(_frameName)

    local f1 = display.newSpriteFrame(_frameName)
    local f2 = display.newSpriteFrame(_frameName)
    local f3 = display.newSpriteFrame(_frameName)

    _button:setBackgroundSpriteFrameForState(f1,cc.CONTROL_STATE_NORMAL)
    _button:setBackgroundSpriteFrameForState(f2,cc.CONTROL_STATE_HIGH_LIGHTED)
    _button:setBackgroundSpriteFrameForState(f3,cc.CONTROL_STATE_DISABLED)
end

--设置ControlButton显示图片
function GameUtils.setControlButtonState(_button)
    local f1 = _button:getBackgroundSpriteForState(cc.CONTROL_STATE_HIGH_LIGHTED)
    local f2 = _button:getBackgroundSpriteForState(cc.CONTROL_STATE_DISABLED)
    f1:setColor(cc.c3b(100,100,100))
    f2:setColor(cc.c3b(100,100,100))

end

function GameUtils.setClip(_path,_parent)
        --头像
    local headSprite  = display.newSprite(_path)
    local stencil = display.newSprite("RoomView/play/ingame_default_head.png")
    local size =stencil:getContentSize()
    local rect = headSprite:getTextureRect()
    headSprite:setLocalZOrder(-1)
    headSprite:setScale(size.width/rect.width)
    

    local clipNode = CCClippingNode:create()  
    clipNode:setStencil(stencil)  
    clipNode:setAlphaThreshold(0)
    headSprite:addTo(clipNode)

    local psize  = _parent:getContentSize()
    local pscale = _parent:getScale()
    
    -- headSprite:setPosition(cc.p(psize.width/2,psize.height/2))
    clipNode:setPosition(cc.p(psize.width/2,psize.height/2))
    clipNode:setScale(pscale)
    clipNode:setTag(2017)
    _parent:removeChildByTag(2017, true)
    clipNode:addTo(_parent)
end

function GameUtils.showTipLabel(_value)

    local label = display.newTTFLabel({
            text = _value,
            font = "Arial-BlodMT",
            size = 60,
            color = cc.c3b(100,54,30),
        })
    
    label:setPosition(display.cx, display.cy-50)
    label:setOpacity(0)
    label:addTo(display.getRunningScene())
    label:runAction(cc.Sequence:create({
                cc.Spawn:create(
                    { 
                        cc.MoveTo:create(0.5, cc.p(display.cx,display.cy+50)),
                        cc.FadeIn:create(0.25)
                    }),
                cc.DelayTime:create(0.8),
                cc.FadeOut:create(0.25),
                cc.CallFunc:create(function() label:removeFromParent(true) end)
            }))
end

--显示不完整，进行滚动显示label
function GameUtils.setLabelScrollTextWx(_label, _value)
    local parent = _label:getParent()
    local label
    if not parent._clipLabel then
        _label:setVisible(false)
        local c4 = _label:getTextColor()
        label = display.newTTFLabel({
            text = _value,
            font = _label:getSystemFontName(),
            size = _label:getSystemFontSize(),
            color = cc.c3b(c4.r, c4.g, c4.b),
            dimensions = _label:getDimensions(),
        })
        label:setScale(_label:getScale())
        label:setPosition(cc.p(_label:getPositionX(),_label:getPositionY()))
        label:setAnchorPoint(_label:getAnchorPoint())

        label._maxWidth = _label:getContentSize().width
        label._maxHeight = _label:getContentSize().height
        label._maxScale = _label:getScale()
        label._maxPosition = cc.p(_label:getPositionX(),_label:getPositionY())
        label._maxAnchohorPoint = _label:getAnchorPoint()

        local drawNode = display.newRect(cc.rect(0, 0, label._maxWidth, label._maxHeight),
        {fillColor = cc.c4f(1,1,1,1), borderColor = cc.c4f(1,1,1,1), borderWidth = 1})
        local clip = cc.ClippingNode:create()
        clip:setStencil(drawNode)
        clip:setPosition(label._maxPosition.x-label._maxWidth*label._maxAnchohorPoint.x,label._maxPosition.y-label._maxHeight*label._maxAnchohorPoint.y)
        clip:addChild(label, 1, 1)

        parent:addChild(clip)
        parent._clipLabel = clip

        label:setPosition(label._maxWidth*label._maxAnchohorPoint.x, label._maxHeight*label._maxAnchohorPoint.y)
        label._maxPosition = cc.p(label:getPositionX(), label:getPositionY())
    else
        label = parent._clipLabel:getChildByTag(1)
        if not label then
            return
        end
    end

    label:setString(_value)

    local maxWidth = label._maxWidth

    local currentWidth = label:getContentSize().width

    label:setAnchorPoint(label._maxAnchohorPoint)
    label:setPosition(label._maxPosition)

    label:stopAllActions()
    if currentWidth > maxWidth then
        local spcX = currentWidth - maxWidth
        local anchX = label._maxAnchohorPoint.x
        label:setAnchorPoint(0,label:getAnchorPoint().y)
        label:setPositionX(label._maxPosition.x - maxWidth * anchX)

        local t = spcX*0.08
        if t < 2 then
            t = 2
        end

        local seq = cc.Sequence:create({
                        cc.DelayTime:create(1),
                        cc.MoveBy:create(t,cc.p(-spcX,0)),
                        cc.DelayTime:create(1),
                        cc.MoveBy:create(t,cc.p(spcX,0)),
                    })
        label:runAction(cc.RepeatForever:create(seq))
    end
end

return GameUtils
