--[[
  主场景
]]
local TableDesk = require("app.game.ui.room.TableDesk")
local RoomInfoPanel = require("app.game.ui.room.RoomInfoPanel")
local ServerHandTile = require("app.game.ui.room.ServerHandTile")
local ServerOutTiles = require("app.game.ui.room.ServerOutTiles")
local Heads = require("app.common.component.sprites.Heads")


local RoomScene = class("RoomScene", function()
    return display.newScene("RoomScene")
end)
local Layer_quit = require("app.game.ui.main.LayerQuit")

function RoomScene:ctor()
    display.removeUnusedSpriteFrames()
    collectgarbage("collect")
    
    display.addSpriteFrames("card.plist","card.pvr.ccz")
    self:initUI()
    
    self:regEvent()
end

function RoomScene:onCleanup()
    self:unregEvent()
end

function RoomScene:regEvent()
    --监听定缺事件
    g_msg:reg("RoomScene", g_msgcmd.DB_DismissAskBroadcast, handler(self, self.onDismiss))
    g_msg:reg("RoomScene", g_msgcmd.UI_AskDingQueBroadcast, handler(self, self.askDingQue))
    g_msg:reg("RoomScene", g_msgcmd.DB_RoundResultBroadcast, handler(self, self.onRoundResult))
    g_msg:reg("RoomScene", g_msgcmd.DB_ReadyBroadcast, handler(self, self.onReadyBroadcast))
    g_msg:reg("RoomScene", g_msgcmd.DB_FinalReport, handler(self, self.onFinalReport))
    g_msg:reg("RoomScene", g_msgcmd.ENTER_BACKGROUND, handler(self, self.onEnterBackground))
    g_msg:reg("RoomScene", g_msgcmd.ENTER_FOREGROUND, handler(self, self.onEnterForeground))

    g_C2LuaSystem.regC2LuaFunc(g_C2LuaSystem.C2Lua_GvoiceUserStateChange ,handler(self,self.C2Lua_GvoiceUserStateChange))
end

function RoomScene:unregEvent()
    g_msg:unreg("RoomScene", g_msgcmd.DB_DismissAskBroadcast)
    g_msg:unreg("RoomScene", g_msgcmd.UI_AskDingQueBroadcast)
    g_msg:unreg("RoomScene", g_msgcmd.DB_RoundResultBroadcast)
    g_msg:unreg("RoomScene", g_msgcmd.DB_ReadyBroadcast)
    g_msg:unreg("RoomScene", g_msgcmd.DB_FinalReport)

    g_msg:unreg("RoomScene", g_msgcmd.ENTER_BACKGROUND)
    g_msg:unreg("RoomScene", g_msgcmd.ENTER_FOREGROUND)
end

function RoomScene:C2Lua_GvoiceUserStateChange( value )
    --解析出是谁的状态改变了
    local  memberid = value.memberID
    local member_status = value.status

    g_msg:post(g_msgcmd.UI_VOICE_State,{memberid = memberid,member_status =member_status})
end

function RoomScene:addTouchLayer()
    local layer = display.newLayer()      
    self:addChild(layer,-10)    
    layer:setKeypadEnabled(true)    
    layer:addNodeEventListener(cc.KEYPAD_EVENT, function (event)    
        if event.key == "back" then  --返回键  
            --弹出退出框
           local  quit = Layer_quit.new()
           local curLayer = g_SMG:getRunLayer()
           if curLayer then
                if curLayer:getName() == 'LayerResultOneRound' or "LayerResultFinal" == curLayer:getName() then
                    g_SMG:addLayer(quit,true)
                    return
                end
           end
           g_SMG:addLayer(quit)
        end       
    end)
end
function RoomScene:initUI()

     --暂时这样
    local isReconnect = g_data.roomSys.isReconnect
    if isReconnect then 
        local reconnectInfo = g_data.roomSys.m_reconnectInfo

        --处理缺门信息
        local user_cards    = reconnectInfo.user_cards
        if not user_cards then user_cards = {} end
        for _,v  in pairs(user_cards) do
            local info   = g_data.roomSys:getPlayerInfo(v.uid)
            if info then
                info.QueMen =  v.quemen
                if v.is_ting == 1 then
                    info.isTingPai = true
                end
            end
        end

        ----解散房间装状态
        local temp_Player  = nil 
        local isDismiss = false
        local status = reconnectInfo.dissmiss_result
        for k,v in pairs(status) do
        if v == 0 then break end  ---未发起
            temp_Player = g_data.roomSys:getPlayerInfo(v.uid)
            temp_Player.dismiss_status = v.dismiss_status
            if v.dismiss_status > 0 then
               isDismiss =true
            end
        end
        if isDismiss then
            local dismiss = require("app.game.ui.room.DismissRoomLayer")
            g_SMG:addLayerByName(dismiss.new(nil,true),self)
        end

       
    end
    self.sprite_photo = nil
    --添加监听返回键的层
    self:addTouchLayer()

    --桌面层
    self.m_TabelDesk = TableDesk.new()
    self.m_TabelDesk:addTo(self)

    --房间桌面面板
    self.m_RoomInfoPanel = RoomInfoPanel.new()
    self.m_RoomInfoPanel:addTo(self)


    self:setTouchEnabled(true)
    self.listener = self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.touchEvent))

    local _isVideo =false
  
    --手牌
    self.m_HandTile = ServerHandTile.new()
    self.m_HandTile:addTo(self,10)

    --房间信息
    self.m_roomInfoNode = require("app.game.ui.room.RoomInfoNode").new(_isVideo)
    self.m_roomInfoNode:addTo(self)

    self.m_OutTiles = ServerOutTiles.new()
    self.m_OutTiles:addTo(self,20)

    self.m_Heads = Heads.new()
    self.m_Heads:addTo(self,30)

    --操作
    self.m_operate = require("app.game.ui.room.OperateNode").new()
    self.m_operate :addTo(self,40)

    --动画
    self.m_Animation = require("app.game.ui.room.AnimationNode").new()
    self.m_Animation:addTo(self,50)

    if self.m_HeartBeatSchedule == nil then
        self.m_HeartBeatSchedule = self:schedule(function()   
                self:heartBeat() end, 6)
    end
    g_LocalDB:save( "soundstate" ,1)
end

function RoomScene:onEnter()
    -- self:performWithDelay(function() self:load() end, 0.2)--防止监听不到
    g_gcloudvoice:jointeamroom(g_data.roomSys.kTableID)--加入语音房间  
    g_gcloudvoice:openspeaker()
end

function RoomScene:onExit()
end

--定缺请求
function RoomScene:askDingQue(_msg)
    if _msg.data.DQType == "ask" then
        self:performWithDelay(  
            function()
                self.mDingQueNode = require("app.game.ui.room.DingQueNode").new()
                self.mDingQueNode:addTo(self,60)
             end, g_data.roomSys.m_float)
        
    elseif _msg.data.DQType == "broadcast" then

    elseif _msg.data.DQType == "success" then
    end
end

--一局结束
function RoomScene:onRoundResult()
    
    local roundReport = g_data.reportSys:getRoundReport()
    g_data.roomSys:updateUIState(RoomDefine.UI_State.RoundReport)--单局结算状态

    self.m_HandTile:showHu()
    --延迟1秒 显示结算
    self:performWithDelay(function() self:onRoundReport() end, 0.1)
end
function RoomScene:addScreenShoot()
    if self.sprite_photo then
        return
    end

    local size = cc.Director:getInstance():getWinSize()
    local screen = cc.RenderTexture:create(size.width,size.height,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,gl.DEPTH24_STENCIL8_OES)
    local scene = cc.Director:getInstance():getRunningScene()
    screen:begin()
    scene:visit()
    screen:endToLua()
    local texture = screen:getSprite():getTexture()

    self.sprite_photo = cc.FilteredSpriteWithOne:createWithTexture(texture)
    self.sprite_photo:setPosition(640,360)
   
    self.sprite_photo:setScaleY(-1)
    -- self.filter1 = cc.GaussianVBlurFilter:create(5)
    self.filter2 = cc.GaussianHBlurFilter:create(3)
    self.sprite_photo:setOpacity(0)
    self.sprite_photo:setFilter(self.filter2)
    self.sprite_photo:addTo(self,70)
    self.sprite_photo:runAction(cc.FadeIn:create(0.1))
end
--单局结算
function RoomScene:onRoundReport()
    
    self:addScreenShoot()
    
    local roundReport = g_data.reportSys:getRoundReport()
    if roundReport.is_huangzhuang  == 1 then

        self:performWithDelay(function()  
          g_SMG:addLayer(require("app.game.ui.main.LayerResultOneRound").new())  end, 0.1)
    else
        local roundReport = g_data.reportSys:getRoundReport()
        local cardEnum    = roundReport.fanpaiji_cardid
        if cardEnum > 0 then  
            g_SMG:addLayer(require("app.game.ui.room.FanPaiJiLayer").new())
        else
          self:performWithDelay(function()
          g_SMG:addLayer(require("app.game.ui.main.LayerResultOneRound").new()) end, 0.1)
        end
    end
end

--总结算
function RoomScene:onFinalReport( _msg )
    
    self:performWithDelay(function()
        local report = require("app.game.ui.main.LayerResultFinal").new()
        g_SMG:addLayer(report) self:addScreenShoot() end, 0.1)

end

--准备广播
function RoomScene:onReadyBroadcast( _msg )
     local _uid  = _msg.data.uid
     if g_data.roomSys:myInfo().uid == _uid then
        if self.sprite_photo then
            self.sprite_photo:removeFromParent(true)
            self.sprite_photo=nil
        end
        self.m_HandTile:reset()
        self.m_OutTiles:reset()
       
        for i =1 ,4 do
            g_data.roomSys:onCleanRound()
        end
        self.m_roomInfoNode:setDirectionVisible(false)
        g_SMG:removeLayer()
        collectgarbage("collect")
     end
end

function RoomScene:heartBeat()
    g_data.roomSys.m_HeartBeatCount = g_data.roomSys.m_HeartBeatCount + 1
    if g_data.roomSys.m_HeartBeatCount > 3 or not g_netMgr:isConnected()  then

        self:un_heartBeat()
        g_netMgr:close()
        --退出语音房间
        g_gcloudvoice:quickteamroom(g_data.roomSys.kTableID)
    else
        g_netMgr:send(g_netcmd.MSG_PING_PONG, {} , 0)
    end
end

function RoomScene:un_heartBeat()
    if self.m_HeartBeatSchedule ~= nil then
        self:stopAction(self.m_HeartBeatSchedule)
        self.m_HeartBeatSchedule = nil
        g_data.roomSys.m_HeartBeatCount = 0
    end
end

--解散房间询问
function RoomScene:onDismiss(_msg)
    local ask_uid = _msg.data.uid
    local dismiss = require("app.game.ui.room.DismissRoomLayer")
    g_SMG:addLayerByName(dismiss.new(ask_uid),self)
end

function RoomScene:touchEvent(event)
    if event.name == "began" then
        self.m_HandTile:unTouchTile()
        return true
    elseif event.name == "moved" then
        if self.particle == nil then
            self.particle = g_utils.playParticleFile("partical/Desktop1.plist",self, cc.p(0,0), 2, false)
        end
        self.particle:setVisible(true)
        local wpos = self:convertToWorldSpace(cc.p(event.x, event.y))
        local npos = self:convertToNodeSpace(wpos)
        self.particle:setPosition(npos)
    elseif event.name == "ended" then
        if self.particle then
           self.particle:setVisible(false)
        end
    elseif event.name == "cancelled" then
        if self.particle  then
           self.particle:setVisible(false)
        end
    end
end

--退到后台执行的方法
function RoomScene:onEnterBackground()
    self:un_heartBeat()
     --*************解决Android返回黑屏问题************** --
    g_LocalDB:save( "soundstate" ,0)
end

--返回前台执行方法
function RoomScene:onEnterForeground()
    if self.m_HeartBeatSchedule == nil then
        self.m_HeartBeatSchedule = self:schedule(function()   
                self:heartBeat() end, 6)
    end

    self:performWithDelay(function() 
        if g_LocalDB then
            g_LocalDB:save( "soundstate" ,1)
        end
    end, 1)
end
return RoomScene
