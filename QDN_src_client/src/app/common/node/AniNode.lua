--
-- Author: dhd
-- Date: 2015-05-29 15:42:04
--
--[[
    local aniNode = require("app.node.AniNode").new("F1.csb")
    aniNode:play("win", true)
    aniNode:setPosition(0, 0)
    --设置帧动画触发
    aniNode:setFrameEvent({
    		["onStart"] = function(_frame) print("onStart") end,
    		["onContent"] = function(_frame) print("onContent") end,
    		["onEnd"] = function(_frame) print("onEnd") end,
    	})
    --结束动画调用，并删除自己
    aniNode:setPlayEndEvent(function() print("play end event") end, true)
    self:addChild(aniNode, 1, 1)
]]

local AniNode = class("AniNode", function(_file)
		--加载Cocos Studio编辑好的资源
		local node = cc.CSLoader:createNode(_file)
		-- local node = display.newNode()
		return node
	end)

--初始化（文件名）
function AniNode:ctor(_file)
	self.m_events = nil
	--加载动画线
	local action = cc.CSLoader:createTimeline(_file)
	self:runAction(action)
	self.m_action = action
end

--播放动作（动作名）
function AniNode:play(_name, _loop)
	local loop = true
	if nil~=_loop then loop = _loop end
	if self.m_action:IsAnimationInfoExists(_name) then
		self.m_action:play(_name, loop)
	end
end

--播放指定帧
function AniNode:playFrame(_start, _end, _loop)
	local loop = true
	if nil~=_loop then loop = _loop end
    self.m_action:gotoFrameAndPlay(_start, _end, loop)
end

--播放结束事件
function AniNode:setPlayEndEvent(_fn, _removeSelf)
	local function _onLastFrameEvent()
		if _fn then
			_fn()
		end
		self.m_action:clearLastFrameCallFunc()
		if _removeSelf then
			self:removeSelf()
		end
	end
	self.m_action:clearLastFrameCallFunc()
	self.m_action:setLastFrameCallFunc(_onLastFrameEvent)
end

--帧事件(绑定列表)
function AniNode:setFrameEvent(_events)
	self.m_events = _events
	--帧事件
	local function _onFrameEvent(frame)
	    if nil == frame then return end
	    local event = frame:getEvent()
	    print("onFrameEvent:::::::", event)
	    if self.m_events then
	    	for k,v in pairs(self.m_events) do
	    		if event == k then
	    			if v then v(frame) end
	    		end
	    	end
	    end
	end
	self.m_action:clearFrameEventCallFunc()
	self.m_action:setFrameEventCallFunc(_onFrameEvent)
end

--获取指定名称的子结点精灵
function AniNode:getChildSprite(_name)
	return self:getChildByName(_name)
end

return AniNode
