
local ccbFile = "csb/SubView/LayerLogoutConfirm.csb"

local m = class("LayerConfirmLogout", function()
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
   
    local ctlName = {"btn_ok_logout","btn_cancle_logout"}

    local mBackground = _UI:getChildByName("layer_bg")
    for k,v in ipairs(ctlName) do
        local _ctl = mBackground:getChildByName(v)
        if _ctl then
            g_utils.setButtonClick(_ctl,handler(self,self.onBtnClick))
        end
    end
end

function m:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_cancle_logout" then
        g_SMG:removeLayer()
    elseif s_name == "btn_ok_logout" then        
        g_LocalDB:save("accesstoken","")
        g_LocalDB:save("openid","")
        app:exit()
    end
end

return m