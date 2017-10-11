--
-- Author: Your Name
-- Date: 2017-08-26 11:52:59
--我的俱乐部
local ccbFile = "csb/LobbyView/Layer_club_myclub.csb"
local Itemcellclub = require("app.game.ui.Club.ClubCell.ItemCellClub")
local MyClub = class("MyClub",function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)
function MyClub:ctor(_cfg)
	self.config = _cfg
    self:locadCsb()
end
function MyClub:locadCsb()
	local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    self.panalJoinClub = _UI:getChildByName("Panel_Joinclub")
    self.panalMyClub   = _UI:getChildByName("Panel_myclub")
    self.btnJoin = _UI:getChildByName("Button_join")
    self.btnMy  = _UI:getChildByName("Button_my")
    self.btnExit = _UI:getChildByName("Button_exit")
    g_utils.setButtonClick(self.btnMy,handler(self, self.showMyClub))
    g_utils.setButtonClick(self.btnJoin,handler(self, self.showJoinClub))
    g_utils.setButtonClick(self.btnExit,handler(self, self.onExitGame))
    local ishaveClubList = 0
    for i=1,#self.config do
        if self.config[i].status == 2 then
            ishaveClubList = 1 
        end
    end
    if ishaveClubList > 0  then
    	self:showMyClub(self.btnMy)
    else
    	self:showJoinClub(self.btnJoin)
    end
    if g_GameConfig.isiOSAppCheck then
        self.panalJoinClub:getChildByName("node_tx_describe"):getChildByName("Text_decrib_join_2"):setVisible(false)
    end
end
function MyClub:onExitGame(_sender)
    g_SMG:removeLayer()
end
function MyClub:showJoinClub(_sender)

   self:rereshMyClub()
end
function MyClub:clickReput(_sender)
    self.Text_decrib_join:setString("请输入要查询的俱乐部编号")
end
function MyClub:clickDelete(_sender)
    if self.Text_decrib_join:getString() ~= "请输入要查询的俱乐部编号" and self.Text_decrib_join:getString() ~= "" then
    	self.Text_decrib_join:setString(string.sub(self.Text_decrib_join:getString(),1,string.len(self.Text_decrib_join:getString())-1))
    end
    if self.Text_decrib_join:getString() == "" then
    	self.Text_decrib_join:setString("请输入要查询的俱乐部编号")
    end
end
function MyClub:clickBtNum(_sender)
    print("_sender:getTag()",_sender:getTag())
    if self.Text_decrib_join:getString() == "请输入要查询的俱乐部编号" then
    	self.Text_decrib_join:setString("")
    end
    if string.len(self.Text_decrib_join:getString()) > 7 then
        return
    end
    self.Text_decrib_join:setString(self.Text_decrib_join:getString().._sender:getTag())
     if string.len(self.Text_decrib_join:getString()) == 8 then
        self:searchClub(self.button_serche)
    end
end
function MyClub:searchClub(_sender)
    if self.Text_decrib_join:getString() ~= "请输入要查询的俱乐部编号" and self.Text_decrib_join:getString() ~= "" then
    	--查询俱乐部
    	local tb_search = {

    	club_code = tonumber(self.Text_decrib_join:getString()),
        clickHandle = handler(self,self.handler_search),
    }
    g_ClubCtl:searchClubByClubCode(tb_search)
    end
end
function MyClub:handler_search(_args)
        --收到返回的房间信息
        printTable("_args========",_args)
        self.node_tx_describe:setVisible(false)
        self.bg_sousuo_club:setVisible(true)
        local tx_Text_name = self.bg_sousuo_club:getChildByName("Text_name")
        tx_Text_name:setString(_args.name)
        local tx_id = self.bg_sousuo_club:getChildByName("Text_id")
        tx_id:setString(_args.code)
        local tx_time = self.bg_sousuo_club:getChildByName("Text_num")
        tx_time:setString(_args.userCount)
        self.btnApllay = self.bg_sousuo_club:getChildByName("Button_joinclub")
        self.btnApllay:setTag(tonumber(_args.code))
        local tx_path = "res/images/club/btn_jionclub.png"
        local tx_path_1 = "res/images/club/btn_revocation.png"

        if _args.status == 0 then
           self.btnApllay:loadTextures(tx_path,tx_path,tx_path)
           g_utils.setButtonClick(self.btnApllay,handler(self, self.applyClub))
           self.btnApllay:setVisible(true)
           self.btnApllay:setEnabled(true)

           elseif _args.status == 1 then
           	 self.btnApllay:loadTextures(tx_path_1,tx_path_1,tx_path_1)
           	 g_utils.setButtonClick(self.btnApllay,handler(self, self.revokeClub))
           	 self.btnApllay:setVisible(true)
             self.btnApllay:setEnabled(true)
           	 else
           	 	self.btnApllay:setVisible(false)
           	 	self.btnApllay:setEnabled(false)
        end
end
function MyClub:applyClub(_sender)
    local tb_hander = {
    code = _sender:getTag(),
    click_hander = handler(self,self.applyClubSuccess),

}
	g_ClubCtl:applyClub(tb_hander)
	
end
function MyClub:applyClubSuccess(_args)
	printTable("_args____",_args)
	local tx_path_1 = "res/images/club/btn_revocation.png"
	self.btnApllay:loadTextures(tx_path_1,tx_path_1,tx_path_1)
	g_utils.setButtonClick(self.btnApllay,handler(self, self.revokeClub))
    local LayerTipError = g_UILayer.Common.LayerTipError.new(_args.Msg,false)
    g_SMG:addLayer(LayerTipError)

end
function MyClub:revokeClub(_sender)
local tb_hander = {
    code = _sender:getTag(),
    click_hander = handler(self,self.revokeClubSuccess),

}
	g_ClubCtl:revokeClub(tb_hander)
end
function MyClub:revokeClubSuccess(_args)
	printTable("_args____",_args)
	local tx_path_1 = "res/images/club/btn_jionclub.png"
	self.btnApllay:loadTextures(tx_path_1,tx_path_1,tx_path_1)
	g_utils.setButtonClick(self.btnApllay,handler(self, self.applyClub))
	local LayerTipError = g_UILayer.Common.LayerTipError.new(_args.Msg,false)
    g_SMG:addLayer(LayerTipError)
end
function MyClub:showMyClub(_sender)
    local tx_join = "res/images/club/title_joinclub.png"
    self.btnJoin:loadTextures(tx_join,tx_join,tx_join)
    self:refreshZorder(1)
    local tx_my = "res/images/club/title_myclub_checked.png"
    self.btnMy:loadTextures(tx_my,tx_my,tx_my)
    self.panalJoinClub:setPosition(10000,10000)
    self.panalMyClub:setPosition(0,0)
    local listView  = self.panalMyClub:getChildByName("ListView_myclub")
    listView:removeAllItems()
    local btn_record = self.panalMyClub:getChildByName("Button_record")
    g_utils.setButtonClick(btn_record,handler(self, self.onBtnRecord))
      for i=1,#self.config  do
        if self.config[i].status == 2 then
            local arg = {
                arg_detail  = self.config[i],
                clickHandle = handler(self,self.ClickHandleCL)
            }
            local cell = Itemcellclub.new(arg)
            local layout = ccui.Layout:create()
            layout:setTouchEnabled(true)
            layout:setContentSize(cell:getContentSize()) 
            layout:addChild(cell)
            listView:pushBackCustomItem(layout)
        end
    end

end

function MyClub:rereshMyClub()
	local args = {
     click_hander = handler(self, self.refreshMyClubSuccess)
    }
	g_ClubCtl:rereshMyClub(args)
end
function MyClub:refreshZorder(_arg)
    if _arg == 0 then
        self.btnJoin:setLocalZOrder(11)
        self.btnMy:setLocalZOrder(10)
    elseif _arg == 1 then
        self.btnJoin:setLocalZOrder(10)
        self.btnMy:setLocalZOrder(11)
    end
end
function MyClub:refreshMyClubSuccess(_args)
	self.config= _args
	local tx_join = "res/images/club/title_joinclub_checked.png"
    self.btnJoin:loadTextures(tx_join,tx_join,tx_join)
    self:refreshZorder(0)
    local tx_my = "res/images/club/title_myclub.png"
    self.btnMy:loadTextures(tx_my,tx_my,tx_my)
    self.panalJoinClub:setPosition(0,0)
    self.panalMyClub:setPosition(10000,10000)
    self.node_tx_describe = self.panalJoinClub:getChildByName("node_tx_describe")
    local tx_1 = self.node_tx_describe:getChildByName("Text_decrib_join_1")
    local tx_2 = self.node_tx_describe:getChildByName("Text_decrib_join_2")
    self.bg_sousuo_club = self.panalJoinClub:getChildByName("bg_sousuo_club")
    self.bg_sousuo_club:setVisible(false)
    self.node_tx_describe:setVisible(true)
    if #self.config > 0 then
    	tx_1:setString("加入俱乐部后，组桌更方便哦！")
    	tx_2:setString("加入俱乐部之后，创建房间仅消耗俱乐部钻石，不消耗个人钻石")
    else
    	tx_1:setString("您还没有加入任何俱乐部，请联系群主！")
    	tx_2:setString("加入俱乐部之后，创建房间仅消耗俱乐部钻石，不消耗个人钻石")
    end

    local node_join_main = self.panalJoinClub:getChildByName("node_join_main")
    self.Text_decrib_join = node_join_main:getChildByName("Text_decrib_join")
  --  self.Text_decrib_join:setUnifySizeEnabled(false)
    self.button_serche = node_join_main:getChildByName("Button_search")
    g_utils.setButtonClick(self.button_serche,handler(self,self.searchClub))
    for i=1,10 do
    	local name_num = "Button_num_"..i-1
    	print("name_num",name_num)
    	local bt_num = node_join_main:getChildByName(name_num)
    	bt_num:setTag(i-1)
    	g_utils.setButtonClick(bt_num,handler(self,self.clickBtNum))
    end

    local Button_num_reput = node_join_main:getChildByName("Button_num_reput")
    local Button_num_delete = node_join_main:getChildByName("Button_num_delete")
    g_utils.setButtonClick(Button_num_reput,handler(self,self.clickReput))
    g_utils.setButtonClick(Button_num_delete,handler(self,self.clickDelete))
end
function MyClub:onBtnRecord(_sender)
	g_ClubCtl:getRecord()
end
function MyClub:ClickHandleCL(_clubcode)
	print("_clubcode",_clubcode)
   g_ClubCtl:getClubTableList(_clubcode)

end

return MyClub