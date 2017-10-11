--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/LayerRule.csb"

local LayerRule = class("LayerRule", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

local ruleType = {
    TianZhu = 1,
    LiPing = 2,
    JinPing = 3,
}
local ruleImg = {
    [ruleType.TianZhu] = {"srcRes/LobbyScene/RuleView/txt_tz_guize1.png","srcRes/LobbyScene/RuleView/txt_tz_guize2.png"},
    [ruleType.LiPing] = {"srcRes/LobbyScene/RuleView/txt_lp_guize1.png","srcRes/LobbyScene/RuleView/txt_lp_guize2.png"},
    [ruleType.JinPing] = {"srcRes/LobbyScene/RuleView/txt_jp_guize1.png","srcRes/LobbyScene/RuleView/txt_jp_guize2.png"},
}
function LayerRule:ctor(_cfg)
    self:initUI() 
end

 --初始化ui
function LayerRule:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerRule:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local btnExit = mBackground:getChildByName("btn_exit")

    g_utils.setButtonClick(btnExit,handler(self,self.onBtnClick))

    local checkBoxName = {"cb_tz","cb_lp","cb_jp"}
    self._switchBtn = {}
    for i,v in ipairs(checkBoxName) do
        local ctl = _UI:getChildByName(v)
        g_utils.setButtonClick(ctl,handler(self,self.onBtnClick))
        table.insert(self._switchBtn,ctl)
    end

    self._sv_rule = _UI:getChildByName("sv_rule")
    self._rule1 = self._sv_rule:getChildByName("rule1")
    self._rule2 = self._sv_rule:getChildByName("rule2")

    -- self:switchBtn(self._switchBtn[2])
    -- self:switchRule(ruleType.LiPing)
    self:onBtnClick(self._switchBtn[2])
end

function LayerRule:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    elseif s_name == "cb_tz" then
        self:switchBtn(_sender)
        self:switchRule(ruleType.TianZhu)
    elseif s_name == "cb_lp" then
        self:switchBtn(_sender)
        self:switchRule(ruleType.LiPing)
    elseif s_name == "cb_jp" then
        self:switchBtn(_sender)
        self:switchRule(ruleType.JinPing)
    end
end

function LayerRule:switchBtn(btn)
    for i,v in ipairs(self._switchBtn) do
        v:setSelected(false)
    end
    btn:setSelected(true)
end

function LayerRule:switchRule(ruleType)
    local bottomSpace = 30
    local img1 = ruleImg[ruleType][1]
    local img2 = ruleImg[ruleType][2]

    local sprite2 = display.newSprite(img2)
    local size2 = sprite2:getContentSize()
    sprite2:setAnchorPoint(cc.p(0.5,1))
    sprite2:setPosition(cc.p(size2.width/2,size2.height + bottomSpace))

    local sprite1 = display.newSprite(img1)
    sprite1:setAnchorPoint(cc.p(0.5,1))
    local size1 = sprite1:getContentSize()
    sprite1:setPosition(cc.p(size1.width/2,size1.height + size2.height + bottomSpace))

    self._sv_rule:removeAllChildren()
    self._sv_rule:setInnerContainerSize(cc.size(size1.width,size1.height + size2.height + bottomSpace))
    self._sv_rule:addChild(sprite1)
    self._sv_rule:addChild(sprite2)
    self._sv_rule:jumpToTop()   

    -- local pTexture = display.getImage(ruleImg[ruleType][1]) 
    -- self._rule1:setTexture(pTexture)

    -- local pTexture2 = display.loadImage(ruleImg[ruleType][2]) 
    -- self._rule2:setTexture(pTexture2)
end

return LayerRule