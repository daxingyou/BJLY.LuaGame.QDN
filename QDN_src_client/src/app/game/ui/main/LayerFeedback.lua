--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/LayerFeedback.csb"

local LayerFeedback = class("LayerFeedback", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerFeedback:ctor(_cfg)
    self._cfg = _cfg
    self:initUI() 
end

 --初始化ui
function LayerFeedback:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerFeedback:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local btnCopy = mBackground:getChildByName("btn_copy")
    local btnExit = mBackground:getChildByName("btn_exit")
    mBackground:getChildByName("txt_wxCode"):setString(self._cfg)

    g_utils.setButtonClick(btnCopy,handler(self,self.onBtnClick))
    g_utils.setButtonClick(btnExit,handler(self,self.onBtnClick))

end

function LayerFeedback:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    elseif s_name == "btn_copy" then
        print("self._cfg===",self._cfg)

        local ok = g_ToLua:copyTxt(self._cfg)
        if ok then
            local LayerTipError = g_UILayer.Common.LayerTipError.new("复制成功")
            g_SMG:addLayer(LayerTipError)
        end
    end
end


return LayerFeedback