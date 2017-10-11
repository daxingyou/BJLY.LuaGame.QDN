--[[
    --服务器选择页面
]]--

local ServerSelected = class("ServerSelected", function()
    local node = cc.Node:create()
    node:setNodeEventEnabled(true)
    return node
end)

function ServerSelected:ctor()
    self:initUI()
end

--清理
function ServerSelected:onCleanup()
end

--初始化ui
function ServerSelected:initUI()


	local bgLayer = display.newColorLayer(cc.c4b(0, 0, 0, 255))
   	bgLayer:addTo(self,-1)

 --   	local listenner = cc.EventListenerTouchOneByOne:create()
 --    listenner:setSwallowTouches(true)

 --    listenner:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN)
	-- local eventDispatcher = bgLayer:getEventDispatcher()
	-- eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, bgLayer)


	local server_list = {
		"http://120.77.175.70:56492",
		"http://182.92.161.204:56492",
		"http://apiqdn.laiyagame.com:56492",
		"http://192.168.1.110:56492",
		"http://192.168.1.111:56492",
		"http://apijp.laiyagame.cn:56492",
	}

	for k,v in pairs(server_list) do
		local content
		content = cc.ui.UIPushButton.new()
			:setButtonSize(200, 40)
			:setButtonLabel(cc.ui.UILabel.new({text = v, size = 60, color = display.COLOR_WHITE}))
			:onButtonClicked(function(event)
                self:onServerSelected(v)
            end)
        content:setTouchSwallowEnabled(true)
		content:addTo(self,k)
		content:setPosition(display.cx, display.height - k*100)
	end
end

function ServerSelected:onServerSelected(url)
	print("server url = ",url)
	g_GameConfig.URL = url
	self:removeFromParent(true)
end

return ServerSelected