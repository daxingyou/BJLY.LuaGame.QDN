--
-- Author: Your Name
-- Date: 2017-08-28 15:06:49
--
local ccbFile = "csb/LobbyView/Layer_club_clubdetail.csb"
-- local ItemCell = g_UILayer.Club.ItemClubMain
local ClubMain = class("ClubMain", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function ClubMain:ctor(_cfg)
    self._cfg = _cfg or {}
    self._tableList = self._cfg.tableList
	self:init()

    g_msg:reg(g_msgcmd.UI_Club_Reflash, g_msgcmd.UI_Club_Reflash, handler(self, self.onReflash))
end

function ClubMain:init()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self) 
    local rootBG = _UI:getChildByName("spriteBg")

    local btnName = {"btn_exit","btnRefresh","btnClubInfo","btnInviteClub","btnCreateRoom"}
    for k,v in pairs(btnName) do
    	local btn = rootBG:getChildByName(v)
    	g_utils.setButtonClick(btn,handler(self,self.onBtnClick))
    end
    if g_data.userSys.roomState == 1 then
        local btn = rootBG:getChildByName("btnCreateRoom")
        btn:loadTextures("res/srcRes/LobbyScene/btn_fhfj.png","res/srcRes/LobbyScene/btn_fhfj.png","res/srcRes/LobbyScene/btn_fhfj.png")
    end
    self:updateValue(rootBG)
    self.rootBG = rootBG
end

function ClubMain:updateValue(rootBG)
    local lvClubRoom = rootBG:getChildByName("lvClubRoom")
    self:addClubRoom(lvClubRoom,self._tableList)

    local ctlNameValueMap = {
        txtPlayerNum = "userCount",
        txtDiamondNum = "bigGold",
        txtClubName = "name"
    }
    for k,v in pairs(ctlNameValueMap) do
        local txt = rootBG:getChildByName(k)
        txt:setString(self._cfg[v])

        if k == "txtClubName" then
            local tx_size = txt:getContentSize()
            local bg_title = rootBG:getChildByName("Image_1")
            bg_title:setContentSize(cc.size(tx_size.width+100, bg_title:getContentSize().height))
        end
    end
end

function ClubMain:onBtnClick(_sender)
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
    	g_SMG:removeLayer()
    elseif s_name == "btnRefresh" then
        g_SMG:addWaitLayer()
        g_ClubCtl:getClubTableListReflash(self._cfg.code)
    elseif s_name == "btnClubInfo" then
    	local layer = g_UILayer.Club.ClubInfo.new(self._cfg)
    	g_SMG:addLayer(layer)
    elseif s_name == "btnInviteClub" then
    	local clubID = self._cfg.code
        local ok = g_ToLua:copyTxt(clubID)
        if ok then
        	local txt = "俱乐部编号已复制，请前往微信分享。"
            local LayerTipError = g_UILayer.Common.LayerTipError.new(txt)
            g_SMG:addLayer(LayerTipError)
        end
    elseif s_name == "btnCreateRoom" then
        if g_data.userSys.roomState == 1 then
            local returnRoom = require("app.game.ui.room.ReturnRoom").new()
            returnRoom:addTo(self)
            return
        end
        self._cfg.isClub = true
        local ctrmly = g_UILayer.Main.UICreateRoom.new( self._cfg)
        g_SMG:addLayer(ctrmly)
    end
end

function ClubMain:addClubRoom(parantLv,dataList)
    parantLv:removeAllItems()
    for i,v in ipairs(dataList) do
        local cell = g_UILayer.Club.ItemClubMain.new(v)
        local layout = ccui.Layout:create()
        layout:setTouchEnabled(true)
        layout:setContentSize(cell:getContentSize()) 
        layout:addChild(cell)
        parantLv:pushBackCustomItem(layout)
    end
end
function ClubMain:cleanup()
    g_msg:unreg(g_msgcmd.UI_Club_Reflash, g_msgcmd.UI_Club_Reflash)
end

function ClubMain:onReflash(event)
    g_SMG:removeWaitLayer()
    self._cfg = event.data or {}
    self._tableList = self._cfg.tableList
    self:updateValue(self.rootBG)
end

return ClubMain