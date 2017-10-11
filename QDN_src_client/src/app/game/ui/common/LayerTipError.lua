
local ccbFile = "csb/CommonView/TipError.csb"
local LayerTipError = class("LayerTipError",function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerTipError:ctor(errorTxt,isQuick)
    self.errorTxt = errorTxt
    self.isQuick = isQuick
    self:init()
end

function LayerTipError:init()
    self:LoadCCB()
    self:setTouchEndedFunc(function() self:onTouched() end)
end

function LayerTipError:LoadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local Text_error = _UI:getChildByName("Text_error")
    Text_error:setString(self.errorTxt)
end

function LayerTipError:onTouched()
    if self.isQuick then
        -- app:exit()
        my.TPFunction:exit()
    else 
        g_SMG:removeLayer()
    end

end


return LayerTipError