--[[
    --回馈界面
]]--
local ccbFile = "csb/SubView/LayerLogoutConfirm.csb"

local LayerTip = class("LayerTip", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerTip:ctor()
    self:initUI() 
end

 --初始化ui
function LayerTip:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerTip:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    local  mBackground = _UI:getChildByName("layer_bg")
    self.button_quit = mBackground:getChildByName("btn_ok_logout")
    self.button_cancle = mBackground:getChildByName("btn_cancle_logout")
    g_utils.setButtonClick(self.button_quit,handler(self,self.onBtnClick))
     g_utils.setButtonClick(self.button_cancle,handler(self,self.onBtnClick))
    
end

function LayerTip:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_cancle_logout" then
        g_SMG:removeLayer()
    elseif s_name == "btn_ok_logout" then
        cc.Director:getInstance():endToLua()
    end
end

return LayerTip