--[[
    --回馈界面
]]--
local CellItemMsg = require("app.game.ui.main.CellItem.CellItemMsg")
local ccbFile = "csb/LobbyView/LayerMessage.csb"

local LayerMessage = class("LayerMessage", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerMessage:ctor(_cfg)
    self._data = _cfg.Data
    self:initUI() 
end

 --初始化ui
function LayerMessage:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerMessage:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local btnExit = mBackground:getChildByName("btn_exit")
    g_utils.setButtonClick(btnExit,handler(self,self.onBtnClick))

    local lvMsg = mBackground:getChildByName("listView_msg")
    local function cellClickHandle( id )
        print("------cellClickHandle------",id)
    end
    for i=1,#self._data do
        local cell = CellItemMsg.new(self._data[i])
        cell:setClickHandle(cellClickHandle)

        local layout = ccui.Layout:create()
        layout:setTouchEnabled(true)
        layout:setContentSize(cell:getContentSize()) 
        layout:addChild(cell)
        lvMsg:pushBackCustomItem(layout)
    end
end

function LayerMessage:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    end
end



return LayerMessage