--[[
    --房间信息
]]--
local _cFile = "csb/RoomView/RoomInfoNode.csb"
local RoomInfoNode = class("RoomInfoNode", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

-- _isVideo ture 为录像  flase 正常
function RoomInfoNode:ctor(_isVideo)
    self.isVideo =_isVideo
    self:initUI(_isVideo)
    self:regEvent()

    self:updateReconnect()
end

function RoomInfoNode:updateReconnect()
    local isReconnect = g_data.roomSys.isReconnect
    if not isReconnect then return end

    local reconnectInfo = g_data.roomSys.m_reconnectInfo

    local current_uid   = reconnectInfo.current_uid 
    g_msg:post(g_msgcmd.UI_UPDATE_ARROW,{uid =current_uid})

    local left_card_cnt = reconnectInfo.left_card_cnt
    local left_round    = reconnectInfo.left_round
   
    self.m_LeftCntLabel:setString(left_card_cnt)
    local str  = (g_data.roomSys.RoundLimit-g_data.roomSys.left_round).."/"..g_data.roomSys.RoundLimit
    self.m_LeftRoundLabel:setString(str)
    self.nodeWait:setVisible(false)
    self.nodeGame:setVisible(true)
    self:setDirection()
end

--获取断线重连的 玩家信息
function RoomInfoNode:getReconnectInfo(idx)
    local room_players = g_data.roomSys:getRoomPlayers()
    local temp_Player = room_players[idx]
    return temp_Player
end

local mArrowTabel =  {"Arrow_East","Arrow_North","Arrow_West","Arrow_South"}
 
--初始化页面
function RoomInfoNode:initUI(_isVideo)
     local _UI = cc.uiloader:load(_cFile)
    _UI:addTo(self)

    self.bg_sameip = _UI:getChildByName("bg_sameip")
    self.tx_sameip = self.bg_sameip:getChildByName("Text_sameip")


    local tb = { "nodeWait", "nodeBottom", "nodeGame", "nodeSpeak", "nodeSystem","VideNode"}

    for k,v in pairs(tb) do
    	self[v] = _UI:getChildByName(v)
    end
    self.nodeGame:setVisible(false)
    self.nodeWait:setVisible(true)

    if not _isVideo then
        --邀请好友
        self.btnGetFriends = self.nodeWait:getChildByName("btnGetFriends")
        g_utils.setButtonClick(self.btnGetFriends,handler(self,self.onBtnClick)) 
    end

    self.m_Direction  = self.nodeGame:getChildByName("TimerInfo")
    self.m_TimerLable = _UI:getChildByName("m_TimerLable")
    -- self.m_TimerLable:setVisible(false)

    for k,v in pairs(mArrowTabel) do
        self[v] =  self.m_Direction:getChildByName(v)
        self[v]:setVisible(false)

        local seq = cc.Sequence:create({cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)})
        local rep = cc.RepeatForever:create(seq)
        self[v]:runAction(rep)
    end
    self.currArrow = nil

    self.m_TabelShow      = self.nodeGame:getChildByName("TabelShow")
    self.m_LeftCntLabel   = self.m_TabelShow:getChildByName("left_count_Text")
    self.m_LeftRoundLabel = self.m_TabelShow:getChildByName("left_round_Text") 

    --设置
    self.Button_Setting = self.nodeBottom:getChildByName("Button_Setting")
    self.Button_Setting:setVisible(true)


    local btn = self.nodeBottom:getChildByName("Button_Chat")
    g_utils.setButtonClick(btn,handler(self,self.onBtnClick))

    g_utils.setButtonClick(self.Button_Setting,handler(self,self.onSettingClick))
    self.Button_Speak =self.nodeBottom:getChildByName("Speak_Button")


    local nodeSpeak = _UI:getChildByName("nodeSpeak")
    local sp_speak = nodeSpeak:getChildByName("Sprite_3")


    self.Button_Speak:addTouchEventListener(function(sender,event)
    print("event============",event) --event是触摸类型，0,1,2,3分别是began，moved，ended，canceled
    if event == 0 then
        --打开麦克风 放动画
        nodeSpeak:setVisible(true) 
        self:playSpeakAnim(sp_speak)
        g_gcloudvoice:openmic()
        g_audio.pauseMusic()
    elseif event == 2 or event == 3 then
        --关闭麦克风
        sp_speak:stopAllActions()
        nodeSpeak:setVisible(false)
        g_gcloudvoice:closemic()
        g_audio.resumeMusic()
    end
    end) 
    
    -- self.m_TimerSchedule = nil
    -- self.m_BerrtySchedule = nil
    self:un_m_TimerSchedule()
    self:un_m_BerrtySchedule()

    self:initBerrty()
    self.VideNode:setVisible(false)
    if _isVideo then
        self.nodeWait:setVisible(false)
        self.nodeGame:setVisible(true)
        self.Button_Setting:setVisible(false)
        self.nodeBottom:setVisible(false)
        self.VideNode:setVisible(true)
        self:initVideButton()
    end

    self.Button_close_speak = self.nodeBottom:getChildByName("closespeadk_Button")
    g_utils.setButtonClick(self.Button_close_speak,handler(self,self.onBtnClick))
    self.Button_close_speak:setTag(1)--默认扬声器是打开的
    g_gcloudvoice:openspeaker()

    if g_GameConfig.isiOSAppCheck then
        self.m_TimerLable:setVisible(false)
        if self.btnGetFriends then
            self.btnGetFriends:setVisible(false)
        end
    end
end

---Vide 逻辑
function RoomInfoNode:setVideoCallback( fn )
    self.m_Videofun = fn
end

function RoomInfoNode:initVideButton()
    self.m_buttonBack   = self.VideNode:getChildByName("Button_back")
    self.m_buttonBefor  = self.VideNode:getChildByName("Button_befor")
    self.m_buttonNext   = self.VideNode:getChildByName("Button_next")
    self.m_buttonPause  = self.VideNode:getChildByName("Button_pause")

    g_utils.setButtonClick(self.m_buttonBack,handler(self,self.onVideoButtonClick))
    g_utils.setButtonClick(self.m_buttonBefor,handler(self,self.onVideoButtonClick))
    g_utils.setButtonClick(self.m_buttonNext,handler(self,self.onVideoButtonClick))
    g_utils.setButtonClick(self.m_buttonPause,handler(self,self.onVideoButtonClick))
end

function RoomInfoNode:onVideoButtonClick( _sender )
    if self.m_Videofun then
        self.m_Videofun(_sender)
    end
end
----------------end ---------------------------------
--电池属性
function RoomInfoNode:initBerrty()
    self.m_BerrtyBar     = self.nodeSystem:getChildByName("berrtybar")     --电池进度
    self.m_BerrtyLable   = self.nodeSystem:getChildByName("m_BerrtyLable") --电池lable
    self.m_HuorLable     = self.nodeSystem:getChildByName("m_HuorLable") 
    self.m_MinuteLable   = self.nodeSystem:getChildByName("m_MinuteLable")
    self:updateBerrty()
    if self.m_BerrtySchedule == nil then
        self.m_BerrtySchedule = self:schedule(function() self:updateBerrty() end, 60)
    end
end

--更新电池
function  RoomInfoNode:updateBerrty()
    local power = g_ToLua:getBatteryValue()
    power = string.format("%.2f", power)
    -- string.trim(traceback[3])
    self.m_BerrtyBar:setPercent(power*100) ---TODO
    local powerStr = (power*100).."%"
    self.m_BerrtyLable:setString(powerStr)    ---TODO
    self.m_HuorLable:setString(os.date("%H:%M"))
    -- local minut = string.trim(os.date("%M"))
    self.m_MinuteLable:setVisible(false)
end


--设置房间号
function RoomInfoNode:setDirectionVisible(_bool)
     for k,v in pairs(mArrowTabel) do
        self[v]:setVisible(_bool)
    end
end


function RoomInfoNode:onEnter()
end

function RoomInfoNode:onExit()
end

function RoomInfoNode:onCleanup()
    self:unregEvent()
end

--注册事件
function RoomInfoNode:regEvent()
    g_msg:reg("RoomInfoNode", g_msgcmd.DB_PLAY_GAME_START, function( )
         self.nodeWait:setVisible(false)
         self.nodeGame:setVisible(true)
         self:setDirection()
         self.m_TimerLable:setVisible(true)
         self.m_LeftCntLabel:setString(g_data.roomSys.left_cnt)
         self:onSameIpCheck()
         local str  = (g_data.roomSys.RoundLimit-g_data.roomSys.left_round).."/"..g_data.roomSys.RoundLimit
         self.m_LeftRoundLabel:setString(str)
     end)
    --发牌
    g_msg:reg("RoomInfoNode", g_msgcmd.DB_RoundResultBroadcast, handler(self, self.onRoundResult))
    g_msg:reg("RoomInfoNode", g_msgcmd.UI_UPDATE_ARROW, handler(self, self.updateArrow))
    g_msg:reg("RoomInfoNode", g_msgcmd.DB_Left_CNT, handler(self, self.setLeftcnt))
    g_msg:reg("RoomInfoNode", g_msgcmd.UI_VOICE_LOGIN, handler(self, self.onVoiceLoginBroadCast))
    g_C2LuaSystem.regC2LuaFunc(g_C2LuaSystem.C2Lua_GvoiceLoginResponse,handler(self, self.C2Lua_GvoiceLoginResponse))
    g_C2LuaSystem.regC2LuaFunc(g_C2LuaSystem.C2Lua_GvoiceLoginFailed,handler(self, self.C2Lua_GvoiceLoginFailed))
    g_C2LuaSystem.regC2LuaFunc(g_C2LuaSystem.C2Lua_OnStatusUpdateSuccess,handler(self, self.C2Lua_OnStatusUpdateSuccess))
    g_C2LuaSystem.regC2LuaFunc(g_C2LuaSystem.C2Lua_OnQuitRoom,handler(self, self.C2Lua_OnQuitRoom))

   -- self:onSameIpCheck()

end
function RoomInfoNode:onSameIpCheck()
     local tb = {
       {
         ip="1",
         weichat_nick = "我是测试1号"
      },
      {
         ip="2",
         weichat_nick = "我是测试2号"
      },
      {
         ip="1",
         weichat_nick = "我是测试3号"
      },
      {
         ip="2",
         weichat_nick = "我是测试4号"
      }
     }
     local tb_all = g_data.roomSys:checkSameIp(tb)
     printTable("tb_all",tb_all)

    self.tx_sameip:setString("警告:")
     for i=1,#tb_all do
        if #tb_all[i] >1 then
           for j=1,#tb_all[i] do
               self.tx_sameip:setString(self.tx_sameip:getString().." "..tb_all[i][j].weichat_nick)
           end
           self.tx_sameip:setString(self.tx_sameip:getString().."为同一ip".." ")
        end
     end
     if self.tx_sameip:getString() ~="警告:" then
        local my1 = cc.MoveBy:create(0.5,cc.p(0,-100))
        local delay_1 = cc.DelayTime:create(5)
        local my2 = cc.MoveBy:create(0.5,cc.p(0,100))
        local sequ = cc.Sequence:create(my1,delay_1,my2)
        self.bg_sameip:runAction(sequ)
     end



end
--注销事件
function RoomInfoNode:unregEvent()
    g_msg:unreg("RoomInfoNode", g_msgcmd.DB_PLAY_GAME_START)
    g_msg:unreg("RoomInfoNode", g_msgcmd.UI_UPDATE_ARROW)
    g_msg:unreg("RoomInfoNode", g_msgcmd.DB_PLAY_OPERATE_Result)
    g_msg:unreg("RoomInfoNode", g_msgcmd.DB_Left_CNT)
    g_msg:unreg("RoomInfoNode", g_msgcmd.UI_VOICE_LOGIN)
    g_msg:unreg("RoomInfoNode", g_msgcmd.DB_RoundResultBroadcast)
end

function RoomInfoNode:C2Lua_GvoiceLoginResponse( value )
    local memberid = value.memberID--本人的语音号
    --发送到服务器
     g_netMgr:send(g_netcmd.MSG_VOICE_LOGIN,{member_id = tostring(memberid)},0)

end
function RoomInfoNode:C2Lua_GvoiceLoginFailed(value )
    
end
function RoomInfoNode:C2Lua_OnStatusUpdateSuccess( value )
    
end
function RoomInfoNode:C2Lua_OnQuitRoom( value )
    -- body
end
function RoomInfoNode:onVoiceLoginBroadCast(_msg)
    local db_data=_msg.data
    local voicelist = db_data.voice_list
    for i=1,#voicelist do
        g_data.roomSys:updatePlyerInfo(voicelist[i])
    end
end

function RoomInfoNode:setDirection()
    local info  = g_data.roomSys:myInfo()
    local tb = { 
    [CardDefine.direction.bottom] = 90 , 
    [CardDefine.direction.right]  = 180 , 
    [CardDefine.direction.top]    = -90 ,
    [CardDefine.direction.left]   = 0 ,}
    self.m_Direction:setRotation(tb[info.seatid+1])   
end

local tb = { 
    [CardDefine.direction.bottom] = "Arrow_East" , 
    [CardDefine.direction.right]  = "Arrow_South" , 
    [CardDefine.direction.top]    = "Arrow_West" ,
    [CardDefine.direction.left]   = "Arrow_North" , 
}

function RoomInfoNode:updateArrow(_msg)
    local uid    = _msg.data.uid
    local info =  g_data.roomSys:getPlayerInfo(uid)
    if info == nil  then return end

    if self.currArrow  then
        self.currArrow:setVisible(false)
    end
    self.currArrow = self[tb[info.seatid+1]]
    self.currArrow:setVisible(true)

    --非录像
    if not self.isVideo then
        self:un_m_TimerSchedule()
        self:run_m_TimerSchedule()
    end
end

function RoomInfoNode:setLeftcnt(_msg)
     local cnt        = _msg.data.left_cnt
     self.m_LeftCntLabel:setString(cnt)
end

--点击设置
function RoomInfoNode:onSettingClick( )
    local setting = require("app.game.ui.main.LayerSetting")
    print("g_data.roomSys.Owner = ",g_data.roomSys.Owner)
    if g_data.roomSys.m_status == RoomDefine.Status.Wait then
         if g_data.roomSys.Owner == g_data.userSys.UserID then
            g_SMG:addLayer(setting.new(3))
        else
            g_SMG:addLayer(setting.new(2))
        end
    else
        g_SMG:addLayer(setting.new(3))
    end
end

function RoomInfoNode:onBtnClick(_sender)
    local s_name = _sender:getName()
    if s_name == "Button_Chat" then        
        g_SMG:addLayer(g_UILayer.RoomScene.LayerChat.new(),false,true)
    elseif s_name == "closespeadk_Button" then--关闭扬声器 或者打开扬声器
        if self.Button_close_speak:getTag() == 1 then --扬声器打开了
            self.Button_close_speak:loadTextures("res/images/RoomView/wait/icon__not_trumpet.png","res/images/RoomView/wait/icon__not_trumpet.png","res/images/RoomView/wait/icon__not_trumpet.png")
            self.Button_close_speak:setTag(0)
            g_gcloudvoice:closespeaker()
        else
            self.Button_close_speak:loadTextures("res/images/RoomView/wait/icon_trumpet.png","res/images/RoomView/wait/icon_trumpet.png","res/images/RoomView/wait/icon_trumpet.png")
            self.Button_close_speak:setTag(1)
            g_gcloudvoice:openspeaker()
        end
    elseif s_name == "btnGetFriends" then
        self:invitateFriend()
    end
end

--
function RoomInfoNode:run_m_TimerSchedule()
    self.m_currentTime = 10
    if self.m_TimerSchedule == nil then
        self.m_TimerSchedule = self:schedule(function() self:timerGo() end, 1)
    end
end

function RoomInfoNode:un_m_TimerSchedule()
    if self.m_TimerSchedule then
         self:stopAction(self.m_TimerSchedule)
    end
    self.m_TimerSchedule = nil
end 

function RoomInfoNode:un_m_BerrtySchedule(  )
    if self.m_BerrtySchedule then
         self:stopAction(self.m_BerrtySchedule)
    end
    self.m_BerrtySchedule  = nil
end 

function RoomInfoNode:timerGo()
    self.m_currentTime = self.m_currentTime - 1
    if self.m_currentTime >= 0 then
        self.m_TimerLable:setString(math.floor(self.m_currentTime))
        if self.m_currentTime == 3 then 
            g_audio.playSound(g_audioConfig.sound["alarm"]["path"])
        end
    else
        self:un_m_TimerSchedule()
    end
end

function RoomInfoNode:invitateFriend()
    local rule = g_LobbyCtl:saveRoomInfo(g_data.roomSys.m_ruleInfo)
    g_ToLua:shareUrlWX(g_WeiXin.Config.shareUrl,g_WeiXin.Config.appName,rule,0)
end

--停止播放声音
function RoomInfoNode:onRoundResult()
    self:un_m_TimerSchedule()
end

function RoomInfoNode:playSpeakAnim(spriteCtl)    
    if spriteCtl:numberOfRunningActions() > 0 then
        return
    end
    local frames = {}
    for i=1,7 do
        local path = "srcRes/RoomScene/Chat/StartRecord/" .. (i-1) .. ".png"
        local sprite = display.newSprite(path)
        local frame = sprite:getSpriteFrame()
        table.insert(frames,frame)
    end
    local anim = display.newAnimation(frames,2/7)
    spriteCtl:playAnimationForever(anim)
end

return RoomInfoNode