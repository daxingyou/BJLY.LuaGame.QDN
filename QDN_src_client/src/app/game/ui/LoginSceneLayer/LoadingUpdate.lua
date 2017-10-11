
local ccbFile = "csb/SubView/LayerUpdate.csb"
local LoadingUpdate = class("LoadingUpdate",function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LoadingUpdate:ctor(_url)
    self.url = _url
    self:init()
end

function LoadingUpdate:init()
    self:LoadCCB()
end

function LoadingUpdate:LoadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local btn = _UI:getChildByName("btn_ok")
    g_utils.setButtonClick(btn,handler(self,self.onBtnClick))    
end

function LoadingUpdate:onBtnClick( _sender )
    device.openURL(self.url)
    app:exit()
end

return LoadingUpdate