--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/Layer_cell_club.csb"

local ItemCellClub = class("ItemCellClub", function()
    return cc.Layer:create()
end)

function ItemCellClub:ctor(_cfg)
    printTable("cfg=======",_cfg)
    self.arg_detail = _cfg.arg_detail
    self.clubcode = self.arg_detail.code
    self._clickHandle = _cfg.clickHandle
    self:initUI()
end

 --初始化ui
function ItemCellClub:initUI()
    self:loadCCB()
end

--加载ui文件
function ItemCellClub:loadCCB()
    local _UI1 = cc.uiloader:load(ccbFile)
    _UI1:addTo(self)
    self:setContentSize(_UI1:getContentSize())

    g_utils.setCellButtonClick(self,handler(self,self.onBtnClick))

    local _UI = _UI1:getChildByName("bg_club_shenqing")
    local  btn_createroom = _UI:getChildByName("Button_createroom")
    g_utils.setButtonClick(btn_createroom,handler(self,self.onCreateRoom))

    
    if g_data.userSys.roomState == 1 then
        if self.arg_detail.code == g_data.roomSys.club_code then
            btn_createroom:loadTextures("res/srcRes/LobbyScene/btn_fhfj.png","res/srcRes/LobbyScene/btn_fhfj.png","res/srcRes/LobbyScene/btn_fhfj.png")
        else
            btn_createroom:setVisible(false)
        end
    end

    local tx_name = _UI:getChildByName("Text_name")
    tx_name:setString(self.arg_detail.name)
    local tx_id = _UI:getChildByName("Text_id")
    tx_id:setString(self.arg_detail.code)
    local tx_Text_numofplayer = _UI:getChildByName("Text_numofplayer")
    tx_Text_numofplayer:setString(self.arg_detail.userCount)
end

function ItemCellClub:onBtnClick( _sender ) 
    if self._clickHandle then
        self._clickHandle(self.clubcode)
    end
end
function ItemCellClub:onCreateRoom(_sender)
    if g_data.userSys.roomState == 1 then
        local returnRoom = require("app.game.ui.room.ReturnRoom").new()
        returnRoom:addTo(self)
        return
    end
    print("createroom by club -----------------")
    printTable("self.arg_detail =",self.arg_detail)
    local args = {clubCode = self.clubcode}
    self.arg_detail.isClub = true
    local ctrmly = g_UILayer.Main.UICreateRoom.new(self.arg_detail)
    g_SMG:addLayer(ctrmly)
end


return ItemCellClub