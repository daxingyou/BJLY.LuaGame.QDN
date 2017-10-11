--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/LayerActivity.csb"

local LayerActivity = class("LayerActivity", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerActivity:ctor(_cfg)
    self._pathList = _cfg
    self._stopAutoScroll = false
    self:initUI() 
end

 --初始化ui
function LayerActivity:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerActivity:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local btnExit = mBackground:getChildByName("btn_exit")
    local pgView = mBackground:getChildByName("pageView_ad")
    self._pgView = pgView

    pgView:removeAllPages()
    for i,v in ipairs(self._pathList) do
        self:AddOnePage(pgView,v)
    end
    -- self:AddOnePage(pgView,"Load/ad_1.png")
    -- self:AddOnePage(pgView,"Load/ad_2.png")
    -- self:AddOnePage(pgView,"Load/ad_3.png")
    self._pageNum = #self._pathList
    self._dir = 2
    local lay = self:addIndicator(self._pageNum)
    lay:addTo(mBackground)
    local sizeBG = mBackground:getContentSize()
    local sizeLay = lay:getContentSize()
    lay:setPosition((sizeBG.width - sizeLay.width) * 0.5, 35)

    pgView:addTouchEventListener(function(touch,event)
        -- print("----addTouchEventListener---",event)
        if event == 0 then
            self._stopAutoScroll = true
        elseif event == 1 then
        elseif event == 2 then
            self._stopAutoScroll = false
        else
        end
    end)

    pgView:addEventListener(function(sender,event)
        print("---4444--",pgView:getCurPageIndex())
        local pgIndex = pgView:getCurPageIndex() + 1
        local  parent = sender:getParent():getChildByName("IndicatorBG")
        for i=1,self._pageNum do
            parent:getChildByName("sprite_dark" .. i):getChildByName("sprite_bright"):setVisible(false)
        end
        if self._pageNum > 0 then            
            parent:getChildByName("sprite_dark" .. pgIndex):getChildByName("sprite_bright"):setVisible(true)
        end
        if pgIndex == 1 then
            self._dir = 2 --2向右
        elseif pgIndex == self._pageNum then
            self._dir = 1 --1向左           
        end
    end)

    g_utils.setButtonClick(btnExit,handler(self,self.onBtnClick))
    pgView:setCustomScrollThreshold(80)
    self._pgView:scrollToPage(0)
    self:autoScrollPageView()
end

function LayerActivity:addIndicator(num)
    local layer = cc.Layer:create()
    local path_dark_img,path_bright_img = "res/srcRes/LobbyScene/ActivityView/spot_dark.png","res/srcRes/LobbyScene/ActivityView/spot_bright.png"
    local total_width,heigth,spaceX = 0,0,20
    for i=1,num do
        local sprite_dark = cc.Sprite:create(path_dark_img)
        local sprite_bright = cc.Sprite:create(path_bright_img)
        sprite_dark:setName("sprite_dark" .. i)
        sprite_bright:setName("sprite_bright")
        local size = sprite_dark:getContentSize()
        sprite_bright:setPosition(size.width*0.5,size.height * 0.5)
        sprite_bright:setVisible(false)
        sprite_dark:addChild(sprite_bright)
        sprite_dark:setAnchorPoint(cc.p(0.5,0.5))
        total_width = total_width + spaceX * 0.5
        sprite_dark:setPosition(total_width+size.width*0.5,size.height*.05)
        layer:addChild(sprite_dark)
        total_width = total_width + size.width + spaceX * 0.5
        height = size.height
    end
    layer:setAnchorPoint(cc.p(0.5,0.5))
    layer:setContentSize(cc.size(total_width,height))
    layer:setName("IndicatorBG")
    return layer
end

function LayerActivity:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeByName("LayerActivity")
    end
end

function LayerActivity:AddOnePage( pgViewCtl,picPath )
    local size = pgViewCtl:getContentSize()
    local layout = ccui.Layout:create()
    layout:setTouchEnabled(true)
    layout:setSwallowTouches(false)
    layout:setContentSize(size)
    local imgView = ccui.ImageView:create(picPath)
    imgView:setPosition(size.width/2,size.height/2)
    local imgSize = imgView:getContentSize()
    imgView:setScale(size.width/imgSize.width,size.height/imgSize.height)
    imgView:setScale9Enabled(true)
    layout:addChild(imgView)

    pgViewCtl:addPage(layout)
end

function LayerActivity:autoScrollPageView()
    local act1 = cc.CallFunc:create(function()
        local index = self:getScrollToIndex()
        print("--autoScrollPageView index----",index)
        if self._stopAutoScroll == false then
            self._pgView:scrollToPage(index)
        end
    end)
    local act2 = cc.DelayTime:create(5)
    local seq = cc.Sequence:create(act2, act1)
    local rep = cc.RepeatForever:create(seq)
    self._pgView:runAction(rep)
end

function LayerActivity:getScrollToIndex()
    local index = self._pgView:getCurPageIndex()
    local resIndex = index
    if self._dir == 2 then --2向右
        if index + 1 >= self._pageNum then
            self._dir = 1
            resIndex = self._pageNum
        else
            resIndex = index + 1
        end
    elseif self._dir == 1 then --1向左
        if index - 1 <= 0 then
            self._dir = 2
            resIndex = 0
        else
            resIndex = index - 1
        end
    end
    return resIndex
end


return LayerActivity