--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/LayerSetting.csb"

local LayerSetting = class("LayerSetting", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)
LayerSetting.showBtnType = {
    btn_logout = 1,
    btn_backLobby = 2,
    btnDismissRoom = 3,
}

function LayerSetting:ctor(__showBtnType)
    self._showBtnType = __showBtnType or self.showBtnType.btn_logout
    self:initUI() 
end

 --初始化ui
function LayerSetting:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerSetting:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local btnName = {"btn_logout","btn_backLobby","btnDismissRoom","btn_exit"}
    local btnSet = {}
    for i,v in ipairs(btnName) do
        local btn = mBackground:getChildByName(v)
        g_utils.setButtonClick(btn,handler(self,self.onBtnClick))
        btnSet[v] = btn
    end

    self.sound_btn = mBackground:getChildByName("sound_btn")
    g_utils.setButtonClick(self.sound_btn,handler(self,self.onSoundClick))
    self.sound_btn:setSelected(true)

    
    self.table_btn = mBackground:getChildByName("table_btn")
    g_utils.setButtonClick(self.table_btn,handler(self,self.onTableDeskClick))
    self.table_btn:setSelected(false)


    self.panel_sound =  mBackground:getChildByName("Panel_1")
    self.panel_sound:setVisible(true)
    self.panel_table =  mBackground:getChildByName("Panel_2")
    self.panel_table:setVisible(false)

    self.tablebg_lan = self.panel_table:getChildByName("tablebg_lan")
    self.tablebg_lv  = self.panel_table:getChildByName("tablebg_lv")

    self:initSlider()

    self.native = self.panel_sound:getChildByName("checkbox_native")
    g_utils.setButtonClick(self.native,handler(self,self.onCheckboxClick))

    self.normal = self.panel_sound:getChildByName("checkbox_general")
    g_utils.setButtonClick(self.normal,handler(self,self.onCheckboxClick))

    local ctlName = {"txt_native","txt_general"}
    for i,v in ipairs(ctlName) do        
        local ctl = self.panel_sound:getChildByName(v)
        g_utils.setButtonClick(ctl,handler(self,self.onCheckboxClick))
    end

    self.table_lv  = self.panel_table:getChildByName("checkbox_lv")
    g_utils.setButtonClick(self.table_lv,handler(self,self.onCheckboxClick))

    self.table_lan = self.panel_table:getChildByName("checkbox_lan")
    g_utils.setButtonClick(self.table_lan,handler(self,self.onCheckboxClick))

    self.tile_lv  = self.panel_table:getChildByName("chekbox_lv_tile")
    self.tile_lan = self.panel_table:getChildByName("chekbox_lan_tile")
    g_utils.setButtonClick(self.tile_lv,handler(self,self.onCheckboxClick))
    g_utils.setButtonClick(self.tile_lan,handler(self,self.onCheckboxClick))

    local ctlName = {"txt_lv","txt_lan"}
    for i,v in ipairs(ctlName) do        
        local ctl = self.panel_table:getChildByName(v)
        g_utils.setButtonClick(ctl,handler(self,self.onCheckboxClick))
    end

    if g_LocalDB:read("language_type") == "normal"  then --普通话
        self.normal:setSelected(true)
        self.native:setSelected(false) 
    else
        self.normal:setSelected(false)
        self.native:setSelected(true)
    end

    if g_LocalDB:read("tablestyle") == 1  then --普通话
        self.tile_lv:setSelected(true)
        self.tile_lan:setSelected(false)
    else
        self.tile_lv:setSelected(false)
        self.tile_lan:setSelected(true)
    end

    if g_LocalDB:read("tablestylebg") == 1  then --普通话
        self.table_lv:setSelected(true)
      
        self.table_lan:setSelected(false)
        self.tablebg_lv:setVisible(true)
        self.tablebg_lan:setVisible(false)
    else
        self.table_lv:setSelected(false)
        self.table_lan:setSelected(true)
        self.tablebg_lan:setVisible(true)
        self.tablebg_lv:setVisible(false)
    end
 
    if self._showBtnType == self.showBtnType.btn_logout then
        btnSet["btn_logout"]:setVisible(true)
        btnSet["btn_backLobby"]:setVisible(false)
        btnSet["btnDismissRoom"]:setVisible(false)
    elseif self._showBtnType == self.showBtnType.btn_backLobby then
        btnSet["btn_logout"]:setVisible(false)
        btnSet["btn_backLobby"]:setVisible(true)
        btnSet["btnDismissRoom"]:setVisible(false)
    elseif self._showBtnType == self.showBtnType.btnDismissRoom then
        btnSet["btn_logout"]:setVisible(false)
        btnSet["btn_backLobby"]:setVisible(false)
        btnSet["btnDismissRoom"]:setVisible(true)
    end
    local version = g_LocalDB:read("clientversion")
    mBackground:getChildByName("txt_version"):setString(version)
end

--设置滑动条
function LayerSetting:initSlider()
    local musicValume  = g_LocalDB:read("bgvalume")
    local soundValume  = g_LocalDB:read("soundvalume")

    self.m_MusicSlider = self.panel_sound:getChildByName("slider_bg_music")
    self.m_MusicSlider:addEventListener(function (sender, eventType)
        g_LocalDB:save("bgvalume",sender:getPercent())
        g_audio.setMusicVolume(sender:getPercent()/100)
    end)

    self.m_SoundSlider = self.panel_sound:getChildByName("slider_soundEffect")
    self.m_SoundSlider:addEventListener(function (sender, eventType)
        g_LocalDB:save("soundvalume",sender:getPercent())
        g_audio.setSoundVolume(sender:getPercent()/100)
    end)

    self.m_MusicSlider:setPercent(musicValume)
    self.m_SoundSlider:setPercent(soundValume)
end

function LayerSetting:onCheckboxClick(_sender)
     local _name = _sender:getName()
     if _name == "checkbox_native" or _name == "txt_native" then
        self.normal:setSelected(false)
        self.native:setSelected(true)
        g_LocalDB:save("language_type","native")
     end
     if _name == "checkbox_general" or _name == "txt_general" then
        self.normal:setSelected(true)
        self.native:setSelected(false)
        g_LocalDB:save("language_type","normal")
     end

     if _name == "checkbox_lv" or _name == "txt_lv" then
        self.table_lv:setSelected(true)
        
        self.table_lan:setSelected(false)
        self.tablebg_lv:setVisible(true)
        self.tablebg_lan:setVisible(false)
        g_LocalDB:save("tablestylebg",1)
     end

     if _name == "checkbox_lan" or _name == "txt_lan" then
        self.table_lv:setSelected(false)
        self.table_lan:setSelected(true)
        self.tablebg_lan:setVisible(true)
        self.tablebg_lv:setVisible(false)
        g_LocalDB:save("tablestylebg",2)
     end

     if _name == "chekbox_lv_tile" then
        self.tile_lv:setSelected(true)
        self.tile_lan:setSelected(false)
        g_LocalDB:save("tablestyle",1)
     end

     if _name == "chekbox_lan_tile" then
        self.tile_lv:setSelected(false)
        self.tile_lan:setSelected(true)
        g_LocalDB:save("tablestyle",2)
     end
end

function LayerSetting:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    elseif s_name == "btn_logout" then
        g_SMG:addLayer(g_UILayer.SecondLevel.LayerConfirmLogout.new())
    elseif s_name == "btnDismissRoom" then
        g_SMG:removeLayer()
        g_netMgr:send(g_netcmd.MSG_LEAVE_TABLE, { leave_reason = 1} , 0)
    elseif s_name == "btn_backLobby" then
        g_SMG:removeLayer()
        g_netMgr:send(g_netcmd.MSG_LEAVE_TABLE, { leave_reason = 1} , 0)
    end
    g_msg:post(g_msgcmd.UI_Setting_Change)    
end

function LayerSetting:onDismissClick()
   
end

function LayerSetting:onSoundClick()
    self.panel_sound:setVisible(true)
    self.panel_table:setVisible(false)
    self.sound_btn:setSelected(true)
    self.table_btn:setSelected(false)
   
end
function LayerSetting:onTableDeskClick()
    self.panel_sound:setVisible(false)
    self.panel_table:setVisible(true)
    self.sound_btn:setSelected(false)
    self.table_btn:setSelected(true)
   
end

return LayerSetting