--
-- Author: Your Name
-- Date: 2017-08-26 11:54:54
--

local ccbFile = "csb/LobbyView/LayerClubInfo.csb"
local Itemcellclub = require("app.game.ui.Club.Cell.ItemCellClubMembers")
local ClubInfo = class("ClubInfo",function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function ClubInfo:ctor(_cfg) 
    self._cfg = _cfg or {}
	self:init()
end

function ClubInfo:init()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)



    local rootBG = _UI:getChildByName("layer_bg")
    self.node_basic = rootBG:getChildByName("Node_basic")
    local ctlNameValueMap = {
    	txtClubName = "name",
    	txtClubID = "code",
    	txtPlayerNum = "userCount",
    	txtCreateTime = "createTime",
	}
    for k,v in pairs(ctlNameValueMap) do
    	local txt = self.node_basic:getChildByName(k)
    	txt:setString(self._cfg[v])
    end
    local btn = rootBG:getChildByName("btn_exit")
    g_utils.setButtonClick(btn,handler(self,self.onBtnClick))
    btn = self.node_basic:getChildByName("btnApplyQuit")
    g_utils.setButtonClick(btn,handler(self,self.onBtnClick))


    self.Button_basicinfo = rootBG:getChildByName("Button_basicinfo")
     g_utils.setButtonClick(self.Button_basicinfo,handler(self, self.onBtnClick))

    self.Button_members   = rootBG:getChildByName("Button_basicinfo_0")
     g_utils.setButtonClick(self.Button_members,handler(self, self.onBtnClick))



    self.listView = rootBG:getChildByName("ListView_members")



end

function ClubInfo:onBtnClick(_sender)

    local path_origin = "res/images/club"
    local path_basic_check = "/btn_information_club_checked.png"
    local path_basic_uncheck = "/btn_information_club.png"
    local path_member_check = "/btn_membership_club_checked.png"
    local path_member_uncheck = "/btn_membership_club.png"
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
    	g_SMG:removeLayer()
    elseif s_name == "btnApplyQuit" then
        g_SMG:addWaitLayer()
    	g_ClubCtl:quitClub(self._cfg.code)
    elseif s_name == "Button_basicinfo" then
        self.Button_basicinfo:loadTextures(path_origin..path_basic_check,path_origin..path_basic_check,path_origin..path_basic_check)
        self.Button_members:loadTextures(path_origin..path_member_uncheck,path_origin..path_member_uncheck,path_origin..path_member_uncheck)
        self.Button_basicinfo:setLocalZOrder(100)
        self.Button_members:setLocalZOrder(99)
        self.listView:setPosition(10000,10000)
        self.node_basic:setPosition(404,-6)
    elseif s_name == "Button_basicinfo_0" then
        self.Button_basicinfo:loadTextures(path_origin..path_basic_uncheck,path_origin..path_basic_uncheck,path_origin..path_basic_uncheck)
        self.Button_members:loadTextures(path_origin..path_member_check,path_origin..path_member_check,path_origin..path_member_check)
        self.Button_basicinfo:setLocalZOrder(99)
        self.Button_members:setLocalZOrder(100)
        self.listView:removeAllItems()
        --请求当前的成员列表
        local arg = {
        clubCode = self._cfg.code,
        click_hander = handler(self,self.getMemberListSuccess)
         }
        g_ClubCtl:getClubMembers(arg)
    end
end
function ClubInfo:getMemberListSuccess(_args)
    self.listView:setPosition(63.21,22.67)
    self.node_basic:setPosition(10000,10000)
       for i=1,#_args do
            local config = _args[i]
            local cell = Itemcellclub.new(config)
            local layout = ccui.Layout:create()
            layout:setTouchEnabled(true)
            layout:setContentSize(cell:getContentSize()) 
            layout:addChild(cell)
            self.listView:pushBackCustomItem(layout)
       end
end
return ClubInfo