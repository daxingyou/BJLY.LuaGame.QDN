--[[

]]--
local ccbFile = "csb/LobbyView/LayerShare.csb"
local weixinShare = require("app.game.ui.main.LayerWeiXinShare") 

local LayerShare = class("LayerShare", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerShare:ctor(_cfg)
    self:initUI() 
end

 --初始化ui
function LayerShare:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerShare:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local btn = mBackground:getChildByName("btn_exit")
    g_utils.setButtonClick(btn,handler(self,self.onBtnClick))
    
    btn = mBackground:getChildByName("bg_dark2"):getChildByName("btn_share")
    g_utils.setButtonClick(btn,handler(self,self.onBtnClick))
end

function LayerShare:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    elseif s_name == "btn_share" then
        g_SMG:addLayer(weixinShare.new())
    end
end


return LayerShare