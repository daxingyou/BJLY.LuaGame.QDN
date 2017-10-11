
local ccbFile = "csb/LobbyView/PlayAgreement.csb"
local m = class("PlayAgreement",function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function m:ctor()
    self:init()
end

function m:init()
    self:LoadCCB()
end

function m:LoadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local btn = _UI:getChildByName("btnBack")
    g_utils.setButtonClick(btn,handler(self,self.onBtnClick))    
end

function m:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btnBack" then
        g_SMG:removeLayer()
    end
end

return m