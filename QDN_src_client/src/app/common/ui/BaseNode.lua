--[[
	注册onEnter onexit
]]

local BaseNode = class("BaseNode", function()
	return cc.Node:create()
end)

function BaseNode:ctor(_color)
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end
return BaseNode
