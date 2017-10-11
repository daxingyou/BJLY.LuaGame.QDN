
--[[
--翻牌鸡
]]--

local _File = "csb/RoomView/Layer_fanpaiji.csb"
local FanPaiJiLayer = class("FanPaiJiLayer", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function FanPaiJiLayer:ctor()
    self:initUI() 
end

local card_bg = {
  "green_mj_bg1.png",
  "blue_mj_bg1.png"
}

function FanPaiJiLayer:initUI()
	local _UI = cc.uiloader:load(_File)
    _UI:addTo(self)
    local mCardBody = _UI:getChildByName("mCardBody")
    local tablestyle = g_LocalDB:read("tablestyle")
    mCardBody:setSpriteFrame(card_bg[tablestyle])
    self.mValueSprite = mCardBody:getChildByName("mValueSprite")

    local roundReport = g_data.reportSys:getRoundReport()
    local cardEnum    = roundReport.fanpaiji_cardid
    if cardEnum == 1 then
        cardEnum = 9
    elseif cardEnum == 17  then
        cardEnum = 25
    elseif cardEnum == 33  then
        cardEnum = 41
    else
        cardEnum = cardEnum -1
    end

    self.mValueSprite:setSpriteFrame(CardDefine.enum[cardEnum][2])
    mCardBody:setScale(0)
    mCardBody:runAction(cc.ScaleTo:create(0.3, 1))
    self:toRound()
end

function FanPaiJiLayer:toRound( ... )
    self:performWithDelay(
    function()
        g_SMG:removeLayer()
        g_SMG:addLayer(require("app.game.ui.main.LayerResultOneRound").new())
    end, 1.2)
end

return FanPaiJiLayer