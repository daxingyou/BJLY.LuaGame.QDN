--
-- Author: XuJian
-- 网络等待动画
--

local WAIT_SHOW_TIME = 0.3 --等待延迟显示时间（秒）
local OVER_TIME = 30 --超时时间（秒）

local TAG_ORDER_WAIT = 1000 --网络等待层

local NetWaitNode = class("NetWaitNode", function()
		-- local node = require("lib.ui.UILockLayer").new(cc.c4b(0, 0, 0, 128))
		local node = require("app.common.ui.UILockLayer").new()
	    return node
	end)

function NetWaitNode:ctor()
	self:initUI()
	self:hide()
end

--加载ui文件
function NetWaitNode:initUI()
	-- local bgLayer = display.newColorLayer(cc.c4b(0, 0, 0, 0))
	-- bgLayer:addTo(self)
	-- bgLayer:setContentSize(cc.size(display.width*0.1, display.height*0.1))
	-- bgLayer:setPosition(display.width*0.45, display.height*0.9)
	-- self.m_bgLayer = bgLayer

	-- local sprite = display.newSprite("netwait_loading.png")
	local sprite = display.newSprite()
	sprite:addTo(self)
	sprite:setPosition(display.width*0.5, display.height*0.5)
	self.m_sprite = sprite
end

function NetWaitNode:show(_delay)
	print("NetWaitNode:show", _delay)
	if self:isVisible() then
		return
	end

	self:overHide(true)

	if self.m_aniAct then
		self:stopAction(self.m_aniAct)
		self.m_aniAct = nil
	end

	local delay = _delay or WAIT_SHOW_TIME
	local function showAni()
		-- self.m_bgLayer:setVisible(true)
		self.m_sprite:setVisible(true)
		self.m_sprite:stopAllActions()
		self.m_sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2.0, 360)))
	end
	--显示动画
	if _delay > 0 then
		self.m_aniAct = self:performWithDelay(showAni, delay)
	else
		showAni()
	end

	self:setVisible(true)
	self:lock()
end

function NetWaitNode:hide()
	print("NetWaitNode:hide")
	self:stopAllActions()
	self.m_sprite:stopAllActions()
	self.m_sprite:setVisible(false)
	-- self.m_bgLayer:setVisible(false)
	self:setVisible(false)
	self:unlock()
end

--超时检测
function NetWaitNode:overHide(_open)
	print("NetWaitNode:overHide")

	--超时处理函数
	function _overfun()
		print("_overfun")
		g_SMG:removeWaitLayer()
		--弹出提示
	  --   local dialog = require("app.scenes.DialogLayer").new({
   --              title = g_lang:getLocalString("network_error"),
   --              tip = g_lang:getLocalString("network_timeout"),
   --              type = 1,
   --              scale = 1,
   --              action = 1
			-- })
   --      dialog:setListen(function(_event, _data)
   --          if "ON_OK" == _event then
   --              -- g_SMG:toLoginScene("NetWaitNode:overHide")
   --          end
   --      end)
	end

	--超时定时器
	if self.m_autoHideAct then
		self:stopAction(self.m_autoHideAct)
		self.m_autoHideAct = nil
	end
	if _open then
		self.m_autoHideAct = self:performWithDelay(_overfun, OVER_TIME)
	end
end

return NetWaitNode
