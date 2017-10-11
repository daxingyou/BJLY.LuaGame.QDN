--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/layer_delegatesuccess.csb"

local Layer_delegatesuccess = class("Layer_delegatesuccess", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)


function Layer_delegatesuccess:ctor(_cfg)
    printTable("table ===== weew",_cfg)
    self.data=_cfg
    self:initUI() 
end

 --初始化ui
function Layer_delegatesuccess:initUI()
    self:loadCCB()
end

--加载ui文件
function Layer_delegatesuccess:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local tx_roomid = _UI:getChildByName("Text_roomid")
    tx_roomid:setString(self.data.roomId)
    local tx_kouzuan = _UI:getChildByName("Text_kouzuan")
    print("limit======",self.data.RoundLimit)
    if self.data.RoundLimit == 4 then
        tx_kouzuan:setString("2颗钻石")
    else
        tx_kouzuan:setString("3颗钻石")
    end
    self.button_share = _UI:getChildByName("Button_1") 
    self.button_confirm = _UI:getChildByName("Button_1_0")
    g_utils.setButtonClick(self.button_share,handler(self,self.onBtnClick))
    g_utils.setButtonClick(self.button_confirm,handler(self,self.onBtnClick))
end
function Layer_delegatesuccess:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "Button_1_0" then
        g_SMG:removeLayer()
    elseif s_name == "Button_1" then--分享
        local rule = g_LobbyCtl:saveRoomInfo(self.data)
        g_ToLua:shareUrlWX(g_WeiXin.Config.shareUrl,g_WeiXin.Config.appName,rule,0)
    end
end



return Layer_delegatesuccess