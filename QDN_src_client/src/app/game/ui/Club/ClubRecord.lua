--
-- Author: Your Name
-- Date: 2017-08-26 11:52:59
--我的俱乐部
local ccbFile = "csb/LobbyView/Layer_Club_Record.csb"
local ClubRecordCell = require("app.game.ui.Club.ClubCell.ItemCellClubRecord")
local ClubRecord = class("ClubRecord",function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)
function ClubRecord:ctor(_cfg)
	self.config = _cfg
    self:locadCsb()
end
function ClubRecord:locadCsb()
	local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    
     local  panalMyClub   = _UI:getChildByName("Panel_myclub")
    
 
    self.btnExit = _UI:getChildByName("Button_exit")
 
    g_utils.setButtonClick(self.btnExit,handler(self, self.onExitGame))
   
    local listview = panalMyClub:getChildByName("ListView_myclub")
    for i=1,#self.config do
        local tb = self.config[i]
        local cell = ClubRecordCell.new(tb)
        local layout = ccui.Layout:create()
        layout:setTouchEnabled(true)
        layout:setContentSize(cell:getContentSize()) 
        layout:addChild(cell)
        listview:pushBackCustomItem(layout)
    end
end

function ClubRecord:onExitGame(_sender)
    g_SMG:removeLayer()
end
return ClubRecord