
local ccbFile = "csb/LobbyView/LayerSelfInfo.csb"
local m = class("LayerSelfInfo", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function m:ctor(_cfg,_uid)
    self._data = _cfg
    self.isIngame = false
    --房间内角色信息使用
    if _uid then
      self:initData(_uid)
      self.isIngame = true
    end

    self:initUI() 
end

 --初始化ui
function m:initUI()
    printTable("mydata======",self._data)
    local gameNum = self._data.JuWin + self._data.JuLose + self._data.JuDraw
    local shengLv = 0
    if gameNum ~= 0 then
        shengLv = self._data.JuWin / gameNum
    end
    self._data.GameNum = gameNum
    self._data.ShengLv = string.format("%.2f",shengLv * 100) .. "%"

    self:loadCCB()
end

--加载ui文件
function m:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local btnExit = _UI:getChildByName("btnBack")
    g_utils.setButtonClick(btnExit,handler(self,self.onBtnClick))
    
    
    local mapctlNameValue = {
        txt_gameNum = "GameNum",
        txt_sheng = "JuWin",
        txt_fu = "JuLose",
        txt_ping = "JuDraw",
        txt_shengLv = "ShengLv",

        txt_diamond_num = "BigGold",
        
        txt_id = "UserID",
        txt_ip = "IP",
        txt_name = "Nick",
        txt_code = "InviteCode",
    }
    for k,v in pairs(mapctlNameValue) do
        local ctrl = _UI:getChildByName(k)
        if ctrl then
            ctrl:setString(self._data[v])
        end
    end
    local sp_diamond = _UI:getChildByName("icon_fangka_6")
    local tx_diamond = _UI:getChildByName("txt_diamond_num")
    if self.isIngame == true then
        sp_diamond:setVisible(false)
        tx_diamond:setVisible(false)
        _UI:getChildByName("bg_add"):setVisible(false)
        _UI:getChildByName("txt_code_ctrl"):setVisible(false)
    end
    
    if self._data["headIconPath"] and string.len(self._data["headIconPath"]) > 5 then  
        local spriteIcon = _UI:getChildByName("nodeHead"):getChildByName("Sprite_icon")
        g_utils.setClip(self._data["headIconPath"],spriteIcon)     
    end

     if g_GameConfig.isiOSAppCheck then
        _UI:getChildByName("bg_add"):setVisible(false)
        _UI:getChildByName("txt_code_ctrl"):setVisible(false)
        _UI:getChildByName("txt_code"):setVisible(false)
        _UI:getChildByName("icon_fangka_6"):setVisible(false)
        _UI:getChildByName("txt_diamond_num"):setVisible(false)
    end
end

function m:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btnBack" then
        g_SMG:removeByName("LayerSelfInfo")
    end
end

-- tb.IP = g_data.userSys.IP
--           tb.InviteCode = g_data.userSys.InviteCode
--           tb.Nick = g_data.userSys.nickname
--           tb.UserID = g_data.userSys.UserID
--             tb.headIconPath = device.writablePath .. g_data.userSys.UserID .. ".png"
--           g_SMG:addLayer(g_UILayer.Main.UISelfInfo.new(tb))
   -- "ju_draw"   = 0
  --     "ju_lose"   = 47
  --     "ju_win"    = 17
function m:initData(_uid)
    local info = g_data.roomSys:getPlayerInfo(_uid)
    self._data.InviteCode   = info.InviteCode
    self._data.Nick         = info.weichat_nick
    self._data.UserID       = _uid
    self._data.headIconPath = device.writablePath .. _uid .. ".png"
    self._data.JuWin        = info.ju_win
    self._data.JuLose       = info.ju_lose
    self._data.JuDraw       = info.ju_draw
    self._data.BigGold      = info.big_gold
    self._data.IP           = info.ip
end

return m