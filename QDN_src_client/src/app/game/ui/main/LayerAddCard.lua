--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/LayerAddCard.csb"

local LayerAddCard = class("LayerAddCard", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerAddCard:ctor(_cfg)
    self:initUI() 
end

 --初始化ui
function LayerAddCard:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerAddCard:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local ctrlName = {
        "btn_exit","btn_copy_service1","btn_copy_service2",
        "btn_copy_agent1","btn_copy_agent2","btn_copy_buy1","btn_copy_buy2",
    }
    for k,v in pairs(ctrlName) do
        local btn = mBackground:getChildByName(v)
        if btn then
            g_utils.setButtonClick(btn,handler(self,self.onBtnClick))
        end
    end

    local  mapCtlNameValue = {
        txt_service = "support",txt_agent = "joinAgent",txt_buy = "buyCard",
    }
    self._txtCtrl = {}
    for k,v in pairs(mapCtlNameValue) do
        for i=1,2 do
            local temp = mBackground:getChildByName(k .. i)
            self._txtCtrl[k .. i] = temp
            if g_data.userSys[v] then
                temp:setString(g_data.userSys[v][i])            
                if not g_data.userSys[v][i] then
                    local n = string.gsub(k,"txt","btn_copy",1)
                    local btn = mBackground:getChildByName(n .. i)
                    if btn then
                        btn:setVisible(false)
                    end
                end
            else
                temp:setString('') 
                local n = string.gsub(k,"txt","btn_copy",1)
                local btn = mBackground:getChildByName(n .. i)
                if btn then
                    btn:setVisible(false)
                end
            end
        end
    end
end

function LayerAddCard:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    else
        local n = string.gsub(s_name,"btn_copy","txt",1)
        if self._txtCtrl[n] then
            local str = self._txtCtrl[n]:getString()
            print(str)
            local ok = g_ToLua:copyTxt(str)
            if ok then
                local LayerTipError = g_UILayer.Common.LayerTipError.new("复制成功")
                g_SMG:addLayer(LayerTipError)
            end
        end

    end
end

return LayerAddCard