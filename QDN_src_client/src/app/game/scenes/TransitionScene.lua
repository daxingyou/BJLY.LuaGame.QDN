--[[
  解决断线重连问题
]]

local ReturnRoom = require("app.game.ui.room.ReturnRoom")
local TransitionScene = class("TransitionScene", function()
    return display.newScene("TransitionScene")
end)

function TransitionScene:ctor(args)
	self:initUI(args)
end

function TransitionScene:onCleanup()
   
end



function TransitionScene:regEvent()
    --监听定缺事件
end

function TransitionScene:unregEvent()

end

function TransitionScene:initUI(args)
	local ccbfile = "ccb/Transition.ccbi"
    self.m_ccbRoot = {}
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad(ccbfile, proxy, self.m_ccbRoot)
    node:addTo(self)

	display.removeSpriteFrameByImageName(device.writablePath.."transitionScene.jpg") --删除缓存
	self.m_ccbRoot.m_desk_bg:setTexture(device.writablePath.."transitionScene.jpg")
end


function TransitionScene:onEnter()
    g_SMG:addWaitLayer()
    self:performWithDelay(function() g_netMgr:connectGameServer() end, 0.1)
end

function TransitionScene:onExit()
    g_SMG:removeWaitLayer()
end

return TransitionScene
