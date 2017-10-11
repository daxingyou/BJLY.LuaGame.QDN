
local ccbFile = "csb/SubView/LayerBindConfirm.csb"

local m = class("LayerBindConfirm", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function m:ctor(_cfg)
    self._cfg = _cfg
    self:initUI() 
end

 --初始化ui
function m:initUI()
    self:loadCCB()
end

--加载ui文件
function m:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
   
    self._mapCtlNameValue = {
        txt_name = "nickName",
        txt_ID = "userId",
    }

    local mBackground = _UI:getChildByName("layer_bg")
    for k,v in pairs(self._mapCtlNameValue) do
        print(k,v)
        local _ctl = mBackground:getChildByName(k)
        if _ctl then
            _ctl:setString(self._cfg[v])
        end
    end
    g_utils.setButtonClick(mBackground:getChildByName("btn_confirm_banding"),handler(self,self.onBtnClick))
    g_utils.setButtonClick(mBackground:getChildByName("btn_exit"),handler(self,self.onBtnClick))
end

function m:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    elseif s_name == "btn_confirm_banding" then
        if self._cfg.confirmHandle then
            self._cfg.confirmHandle()
        end
    end
end

return m