--[[
    --回馈界面
]]--
local ccbFile_NoRecord = "csb/SubView/Layer_NoRecord.csb"

local LayerSubView = class("LayerSubView", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerSubView:ctor()
    self:setTouchEndedFunc(function() self:onTouched() end)
end

function LayerSubView:showNoRecordView()
    self._UI = cc.uiloader:load(ccbFile_NoRecord)
    self._UI:addTo(self)
end
function LayerSubView:onTouched()
	g_SMG:removeLayer()
end
return LayerSubView