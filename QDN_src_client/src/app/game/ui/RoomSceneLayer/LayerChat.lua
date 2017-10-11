--[[

]]--
local ccbFile = "csb/RoomView/LayerChat.csb"
local ItemCell = require("app.game.ui.RoomSceneLayer.ItemCell.ItemCellChat")

local m = class("LayerChat", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)


function m:ctor(_cfg)
    self:initUI() 
end

 --初始化ui
function m:initUI()
    self:loadCCB() 
    self:setTouchEndedFunc(function()
        g_SMG:removeLayer()
    end)
end

--加载ui文件
function m:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local btnSend = _UI:getChildByName("btnSend")
    self._txtField = _UI:getChildByName("txtField")
    local bg_chat = _UI:getChildByName("bg_chat")
    local lv_CL = _UI:getChildByName("lv_CommonLanguage")

    local nodeEmoji = _UI:getChildByName("nodeEmoji")
    for i=1,12 do
        local temp = nodeEmoji:getChildByName("emoji_" .. i)
        temp:setTag(g_enumKey.Chat.Emoji_Tag_Start + i)
        g_utils.setButtonClick(temp,handler(self,self.onBtnClick))
    end

    self:addCommonLanguage(lv_CL)
    lv_CL:setTouchEnabled(true)

    g_utils.setButtonClick(bg_chat,handler(self,self.onBtnClick))
    g_utils.setButtonClick(btnSend,handler(self,self.onBtnClick))
end

function m:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btnSend" then
        local str = self._txtField:getString()
        if str ~= nil and str ~= "" then
            self:sendChatMsg(2,str)
        end
    elseif s_name == "bg_chat" then
    else
        local tag = _sender:getTag()
        self:sendChatMsg(1,tag)
    end
end

function m:addCommonLanguage(parantLv)
    for i,v in ipairs(g_enumKey.Chat.comLanguage) do
        local arg = {
            txt = v,
            index = g_enumKey.Chat.CommonLanguage_Tag_Start + i,
            clickHandle = handler(self,self.ClickHandleCL)
        }
        local cell = ItemCell.new(arg)
        local layout = ccui.Layout:create()
        layout:setTouchEnabled(true)
        layout:setContentSize(cell:getContentSize()) 
        layout:addChild(cell)
        parantLv:pushBackCustomItem(layout)
    end
end

function m:addEmoji()

end
function m:ClickHandleCL(index)
    self:sendChatMsg(1,index)
end

function m:sendChatMsg(_type,msg)
    if _type == 1 then
        g_netMgr:send(g_netcmd.MSG_CHAT,{chat_index = msg},0)
    else
        g_netMgr:send(g_netcmd.MSG_CHAT_CUSTOM,{chat_content = msg},0)
    end
    self:performWithDelay(function() g_SMG:removeLayer() end, 0.1)
end

return m