local HandTile = require("app.common.component.sprites.HandTile")
--[[
麻将牌
]]
local ServerHandTile = class("ServerHandTile", HandTile)

function ServerHandTile:ctor()
	ServerHandTile.super.ctor(self)
	self:regEvent()
    --断线重连
    self:updateReconnect()
end

function ServerHandTile:onCleanup()
    self:unregEvent()
end

--注册事件
function ServerHandTile:regEvent()
	--发牌
	g_msg:reg("ServerHandTile", g_msgcmd.DB_PLAY_GAME_START, handler(self, self.S2C_dispatchTiles))    --游戏开始
	  --发牌
    g_msg:reg("ServerHandTile", g_msgcmd.DB_PLAY_ADD_CARD, handler(self, self.S2C_addTile))
    g_msg:reg("ServerHandTile", g_msgcmd.DB_PLAY_OUT_CARD, handler(self, self.S2C_throwTile))
    --操作
    g_msg:reg("ServerHandTile", g_msgcmd.DB_PLAY_OPERATE_Result, handler(self, self.S2C_operate))
    --点错
    g_msg:reg("ServerHandTile", g_msgcmd.DB_PLAY_OPERATE_Pass, handler(self, self.S2C_pass))
    --操邹询问
    g_msg:reg("ServerHandTile", g_msgcmd.DB_PLAY_OPERATE_ASK, handler(self, self.S2C_operateAction))
    --听--选择可以打的牌
    g_msg:reg("ServerHandTile", g_msgcmd.UI_MinglouAsk, handler(self, self.S2C_tingTile))
    --打出牌 报听
    g_msg:reg("ServerHandTile", g_msgcmd.UI_MinglouBroadcast, handler(self, self.S2C_tingedAction))

    g_msg:reg("ServerHandTile", g_msgcmd.UI_Rest_Card_State, handler(self, self.S2C_resetOut))

    g_msg:reg("ServerHandTile", g_msgcmd.UI_Selected_Tile, handler(self, self.C2C_onSelectedTile))
    --牌型更换
    g_msg:reg("ServerHandTile", g_msgcmd.UI_Setting_Change, handler(self, self.onTablestyle))
end

--注销事件
function ServerHandTile:unregEvent()
	g_msg:unreg("ServerHandTile", g_msgcmd.DB_PLAY_GAME_START)
	g_msg:unreg("ServerHandTile", g_msgcmd.DB_PLAY_ADD_CARD)
	g_msg:unreg("ServerHandTile", g_msgcmd.DB_PLAY_OUT_CARD)
	g_msg:unreg("ServerHandTile", g_msgcmd.DB_PLAY_OPERATE_Result)
	g_msg:unreg("ServerHandTile", g_msgcmd.DB_PLAY_OPERATE_ASK)
    g_msg:unreg("ServerHandTile", g_msgcmd.DB_PLAY_OPERATE_Pass)
    g_msg:unreg("ServerHandTile", g_msgcmd.UI_Rest_Card_State)
    g_msg:unreg("ServerHandTile", g_msgcmd.UI_Selected_Tile)
    g_msg:unreg("ServerHandTile", g_msgcmd.UI_Setting_Change)
    g_msg:unreg("ServerHandTile", g_msgcmd.UI_MinglouAsk)
    g_msg:unreg("ServerHandTile", g_msgcmd.UI_MinglouBroadcast)
end

function ServerHandTile:S2C_operateAction(_msg)
	local op= _msg.data.op
    local actions = op.actions

    if actions[1] == 0 then
        self.m_operating  = false
        self:updateM_Action(HandTileState.HandTileState_Opearte)
    else
        self.m_operating  = true
    end
end

--点击过
function ServerHandTile:S2C_pass(_msg)
    self.m_operating  = false
    if self.m_action == HandTileAction.HandTileAction_Tinged then -- 如果是听牌状态  回复自动打牌
        self:updateM_Action(HandTileState.HandTileState_AddTile)
        self:updateM_Action(HandTileState.HandTileState_Opearte)
    else
        --自己摸牌
        self:updateM_Action(HandTileState.HandTileState_Opearte)
    end
end

--重置打牌
function ServerHandTile:S2C_resetOut(_msg)
    self:updateM_Action(HandTileState.HandTileState_Opearte)
    self:updateM_Action(HandTileState.HandTileState_AddTile)
end

--玩家听牌选择
function ServerHandTile:S2C_tingTile(_msg)
    
    local cans  = _msg.data.can
    local tiles = self.m_handTiles[TileDirection.Direction_Bottom]
    if not tiles then tiles = {} end
    local canOuts = {}
    for _, eTile in pairs(cans) do 
        canOuts[eTile] = true
    end
    for k, tile in pairs(tiles) do
        if canOuts[tile.m_eTile]then
            tile:setLockTileType(LockTileType.LockTileType_Normal)
        else
            tile:setLockTileType(LockTileType.LockTileType_Lock)
        end
    end
    self:updateTilePosition()
    --设置为听牌状态
    self.m_operating  = false
    self.m_action   = HandTileAction.HandTileAction_TingTile
    self:updateM_Action(HandTileState.HandTileState_Opearte)
end

--听请求成功后 设置听牌状态
--听牌状态 自动打牌
function ServerHandTile:S2C_tingedAction(_msg)
    local uid  = _msg.data.uid
    if uid == g_data.userSys.UserID then
        self.m_action = HandTileAction.HandTileAction_Tinged
        local tiles = self.m_handTiles[TileDirection.Direction_Bottom]
        if not tiles then tiles = {} end
        for k, tile in pairs(tiles) do
            tile:setLockTileType(LockTileType.LockTileType_Lock)
        end
    end
end

--系统发牌
function ServerHandTile:S2C_dispatchTiles(_msg)
	self.super.dispatchTiles(self)
end

--系统摸牌
function ServerHandTile:S2C_addTile(_msg)
	
	local uid    = _msg.data.uid
    local info   = g_data.roomSys:getPlayerInfo(uid)
    local _eTile = _msg.data.card
    if info then
        local direction = info.direction
        local noUsedTiles = self.m_noUsedTiles[direction]
        noUsedTiles[ #noUsedTiles + 1 ] = _eTile
        if #noUsedTiles == 1 then
        	local tile = self:popTile(direction)
			if tile then
				tile.m_isDraw = true
				self:addTile(direction, tile,g_data.roomSys.m_float)
			end
        end
    end
    if uid == g_data.userSys.UserID then
        --更新摸牌状态
        self:updateM_Action(HandTileState.HandTileState_AddTile)
    end
end

--系统打牌成功
function ServerHandTile:S2C_throwTile(_msg)
	local dt                = _msg.data
    local uid               = dt.uid
    local eTile             = dt.eTile
    local chargeChickenType = dt.chargeChickenType
    local info   = g_data.roomSys:getPlayerInfo(uid)
    if info then
        g_msg:post(g_msgcmd.UI_Selected_Tile,{eTile = -2})
        local direction = info.direction
        if chargeChickenType == 1 then
             g_data.roomSys:setChargeChicken(info,true)
        end
        --派发打牌消息
        local x , y = 0,0
        if self.m_endTouchTile then
            self:setLocalZOrder(10)
            self.m_tileTip:setVisible(false)
            self.m_tileTip.bg:setVisible(false)
            g_msg:post(g_msgcmd.UI_OUT_TILE,{eTile = eTile,direction = direction, x = self.step.x,y= self.step.y})
        else
            local tile = self:getLastTile(direction)
            if tile then
                 x,y   = tile:getPosition()
                 g_msg:post(g_msgcmd.UI_OUT_TILE,{chargeChickenType = chargeChickenType,eTile = eTile,direction = direction, x = x,y= y})
            end
        end
        if chargeChickenType == 1 then
        else
            g_audio.playTileSound(eTile,info.sex)
        end

        self:removeTile(direction,eTile)
        self:updateTilePosition()
        self.m_endTouchTile  = nil

          --发送命听请求
        if self.m_action == HandTileAction.HandTileAction_TingThrowTile then
            self.m_action = HandTileAction.HandTileAction_TingTile
            g_netMgr:send(g_netcmd.MSG_MINGLOU, {} , 0)
            info.isTingPai = true
        end
    end
end

function ServerHandTile:S2C_operate(_msg)
	local op          = _msg.data.op
    local uid         = op.operate_uid  --主碰
    local puid        = op.provide_uid  --被碰
    local code        = op.operate_code --(1碰，2左杠，3右杠，4对门杠，5补杠，6暗杠，7听，8胡，9左碰，10中碰，11右碰)
    local eTile       = op.operate_cardid
    local dutyChicken = op.is_zerenji   --碰杠中是否有责任鸡   0 不是鸡，1责任鸡，2普通鸡
    local huType      = op.hu_type      -- 胡类型(1平胡， 2大对子， 3七对， 4龙七对， 5清一色， 6清七对， 7清大对， 8青龙背)  
    local kongType    = op.gang_type    --杠类型（1杠上花， 2杠上炮， 3枪杠胡)
    local isZimo      = false

    if uid == g_data.userSys.UserID then
        self.m_operating  = false
    end

    if code == OperateType.pong or
       code == OperateType.Left_pong or
       code == OperateType.Mid_pong or
       code == OperateType.Right_pong then

        self:pong(uid,puid,code,eTile)
        --处理责任鸡
        if dutyChicken == 1 then
            local info   = g_data.roomSys:getPlayerInfo(puid)
            if info then
                g_data.roomSys:setDutyChicken(info,true)
            end
        end
    end

    if code == OperateType.Left_kong or
       code == OperateType.Right_kong or
       code == OperateType.Mid_kong or
       code == OperateType.Fill_kong or
       code == OperateType.Self_kong then
       
       self:kong(uid,puid,code,eTile)
       -- 被杠走 则取消冲锋鸡
       if dutyChicken == 2 then
            local info   = g_data.roomSys:getPlayerInfo(puid)
            if info then
                g_data.roomSys:setChargeChicken(info,false)
            end
        end
    end

    if code == OperateType.Hu then
        local cards  = op.hand_cards

        local info   = g_data.roomSys:getPlayerInfo(uid)
        if info then
            local direction = info.direction
            local titles        = self.m_handTiles[direction]
            if not cards then return end
            if #cards < #titles then return end
           
            for i, tile in pairs(titles) do
                local e = cards[i]
                if e then 
                    if e >= TileDefine.eTile.Tile_Wan_1 and e <= TileDefine.eTile.Tile_Tong_9 then
                        tile:setTileType(e)
                    end
                end
                tile.m_isDraw = false
                tile:setTileState(TileState.TileType_Open,true)
            end

            local noUsedTiles = self.m_noUsedTiles[direction]
            noUsedTiles[ #noUsedTiles + 1 ] = eTile
            local tile = self:popTile(direction)
            if tile then
                tile.m_isDraw = true
                self:addTile(direction, tile,g_data.roomSys.m_float)
                tile:setTileState(TileState.TileType_Open,true)
            end
            self:updateTilePosition()
        end
    end
end

--断了线重连
function ServerHandTile:updateReconnect()
    local isReconnect = g_data.roomSys.isReconnect
    if isReconnect == false then return end 

    local my_info = g_data.roomSys:myInfo()
    if not my_info then  return end
    --玩家大厅准备 或非准备 取消初始化
    if my_info.status == 5 or my_info.status == 6 then return end

    local reconnectInfo = g_data.roomSys.m_reconnectInfo
    local user_cards    = reconnectInfo.user_cards
    if not user_cards then user_cards = {} end
    for _,v  in pairs(user_cards) do
        local info   = g_data.roomSys:getPlayerInfo(v.uid)
        if info then
            local direction = info.direction
            self.m_noUsedTiles[direction] =  v.hand_cards

            --牌组
            local weaves = v.weaves
            if not weaves then weaves = {} end
            for __,weave  in pairs(weaves) do
                self.m_tileItemGroup[direction]:addItem(weave.weave_kind, weave.card_id)
            end
        end
    end

    for _,direction  in pairs(TileDirection) do
        local tile = self:popTile(direction)
        while tile do
            self:addTile(direction, tile,0)
            tile = self:popTile(direction)
        end
    end
    --打牌
    if reconnectInfo.current_uid == g_data.userSys.UserID then
        self.m_action = HandTileAction.HandTileAction_ThrowTile
    end

    local info   = g_data.roomSys:getPlayerInfo(g_data.userSys.UserID)
    if info.isTingPai then
        self.m_action = HandTileAction.HandTileAction_Tinged
    end
end

function ServerHandTile:C2C_onSelectedTile(_msg)
    local dt        = _msg.data
    local eTile     = dt.eTile
    for _,direction  in pairs(TileDirection) do
        self.m_tileItemGroup[direction]:onSelectedTile(eTile)
    end
end

--更新打牌状态
function ServerHandTile:updateM_Action(eState)
    print("self.m_action = ",self.m_action,"eState = ",eState)
    print("self.m_state = ",self.m_state)
    if self.m_action == HandTileAction.HandTileAction_Invalid or 
       self.m_action == HandTileAction.HandTileAction_Tinged
     then

        if self.m_state == HandTileState.HandTileState_Invalid then
            self.m_state = eState
        else
            if (self.m_state == HandTileState.HandTileState_AddTile and eState == HandTileState.HandTileState_Opearte) or 
               (self.m_state == HandTileState.HandTileState_Opearte and eState == HandTileState.HandTileState_AddTile) then
                
                self.m_state  = HandTileState.HandTileState_Invalid

                if self.m_action == HandTileAction.HandTileAction_Invalid then
                    self.m_action = HandTileAction.HandTileAction_ThrowTile
                elseif self.m_action == HandTileAction.HandTileAction_Tinged then
                    if not self.m_operating then
                        self:performWithDelay(function() self:beDoOutTile() end, 0.3)
                    end
                end
            end
        end
    end
end

--当牌被选中
function ServerHandTile:onTileSelected(tile)
    --通知其他页面选中了哪张牌
    g_msg:post(g_msgcmd.UI_Selected_Tile,{eTile = tile.m_eTile})
    --选中时播放声音
    g_audio.playSound(g_audioConfig.sound["tiletouch"]["path"])
end

---向服务发送打牌
function ServerHandTile:onTileUnSelected(tile)
    g_msg:post(g_msgcmd.UI_Selected_Tile,{eTile = -2})
end

---向服务发送打牌
function ServerHandTile:onOutTile(tile)
    g_netMgr:send(g_netcmd.MSG_OUT, { card = tile.m_eTile } , 0)
end

function ServerHandTile:onTablestyle()
    ServerHandTile.super.onTablestyle(self)
end

return ServerHandTile