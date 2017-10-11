--
-- Author: Your Name
-- Date: 2017-08-28 19:16:13
--


local ccbFile = "csb/LobbyView/LayerClubHelp.csb"
local ClubHelp = class("ClubHelp",function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function ClubHelp:ctor() 
	self:init()
end

function ClubHelp:init()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local rootBG = _UI:getChildByName("layer_bg") 
    local btn = rootBG:getChildByName("btn_exit")
    g_utils.setButtonClick(btn,handler(self,self.onBtnClick))
end

function ClubHelp:onBtnClick(_sender)
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
    	g_SMG:removeLayer()
    	
    end
end

return ClubHelp