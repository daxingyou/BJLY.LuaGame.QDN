--
-- Author: XuJian
-- 用九宫格图片模拟横向 timebar
--
--用法示例
-- local bar = require("lib.ui.UIProgressScale9").new({
--     image = "#ui_main_rect_2.png",
--     size  = cc.size(70, 15),
--     node  = self.m_ccbRoot.m_sprProgress
-- })
local offsetWidth = 4
local UIProgressScale9 = class("UIProgressScale9")
function UIProgressScale9:ctor(params)
	local node  = params.node
	local image = params.image
	local size  = params.size
	size.width = size.width - offsetWidth
	local capInsets = params.capInsets or cc.rect(0,0,0,0)
	local bar = display.newScale9Sprite(image,0,0,size) 
    bar:setPosition(offsetWidth/2,0) 
    bar:setAnchorPoint(cc.p(0,0))
    bar:addTo(node)

    self:setMaxW(size.width)
    self:setMaxH(size.height)

    self.m_bar = bar

    self:setPercentage(0) --默认为0
end

function UIProgressScale9:setPercentage(_percent)
	if _percent == 0 then
		self.m_bar:setVisible(false)
		return
	end
	self.m_bar:setVisible(true)
	local width = math.min((_percent/100)*self.m_maxW,self.m_maxW)
	local height = self:getMaxH()
	print("UIProgressScale9:setPercentage",width,height)
	self.m_bar:setContentSize(cc.size(width, height))
end
--设置最大宽度
function UIProgressScale9:setMaxW(_maxW)
	self.m_maxW = _maxW
end
--获取最大宽度
function UIProgressScale9:getMaxW()
	return self.m_maxW
end

--设置最大高度
function UIProgressScale9:setMaxH(_maxH)
	self.m_maxH = _maxH
end
--获取最大高度
function UIProgressScale9:getMaxH()
	return self.m_maxH
end
return UIProgressScale9
