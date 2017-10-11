 local Tile = require("app.common.component.sprites.Tile")
local ChickenOutTiles = require("app.common.component.sprites.ChickenOutTiles")
--[[
    2人麻将 
    初始化牌坐标
]]
local ServerOutTiles = class("ServerOutTiles",ChickenOutTiles)

function ServerOutTiles:ctor()
    ServerOutTiles.super.ctor(self)
    self:updateReconnect()
    self:regEvent()
end

--注册事件
function ServerOutTiles:regEvent()
    ServerOutTiles.super.regEvent(self)
     --操作
    g_msg:reg("ServerOutTiles", g_msgcmd.DB_PLAY_OPERATE_Result, handler(self, self.S2C_operate))
     --牌型更换
    g_msg:reg("ServerOutTiles", g_msgcmd.UI_Setting_Change, handler(self, self.onTablestyle))
end

--注销事件
function ServerOutTiles:unregEvent()
    ServerOutTiles.super.unregEvent(self)
    g_msg:unreg("ServerOutTiles", g_msgcmd.DB_PLAY_OPERATE_Result)
 --牌型更换
    g_msg:unreg("ServerOutTiles", g_msgcmd.UI_Setting_Change)
end

--初始化牌坐标
function ServerOutTiles:initPosition()
    self.maxRow = 14
    if g_data.roomSys.PlayRule == RoomDefine.Rule.room_4 then
        self.maxRow = 14
    elseif g_data.roomSys.PlayRule == RoomDefine.Rule.room_2D or
           g_data.roomSys.PlayRule == RoomDefine.Rule.room_2D2 then
        self.maxRow = 21
    elseif g_data.roomSys.PlayRule == RoomDefine.Rule.room_3D or
           g_data.roomSys.PlayRule == RoomDefine.Rule.room_3D2 then
        self.maxRow = 14
    end

	ServerOutTiles.super.initPosition(self)
end


--碰牌移除
function ServerOutTiles:S2C_operate(_msg)
    if self.m_outTile == nil then return end

    local op          = _msg.data.op
    local uid         = op.operate_uid  --主碰
    local puid        = op.provide_uid  --被碰
    local code        = op.operate_code --(1碰，2左杠，3右杠，4对门杠，5补杠，6暗杠，7听，8胡，9左碰，10中碰，11右碰)
    local eTile       = op.operate_cardid
    local dutyChicken = op.is_zerenji   --碰杠中是否有责任鸡   0 不是鸡，1责任鸡，2普通鸡
    local huType      = op.hu_type      -- 胡类型(1平胡， 2大对子， 3七对， 4龙七对， 5清一色， 6清七对， 7清大对， 8青龙背)  
    local kongType    = op.gang_type    --杠类型（1杠上花， 2杠上炮， 3枪杠胡)

    if code == OperateType.pong or
       code == OperateType.Left_pong or
       code == OperateType.Mid_pong or
       code == OperateType.Right_pong or
       code == OperateType.Left_kong or
       code == OperateType.Right_kong or
       code == OperateType.Mid_kong  then

       if self.m_outTile.m_eTile == eTile then
            self:removeTile(self.m_outTile)
       end
    end
end

--断了线重连
function ServerOutTiles:updateReconnect()
    local isReconnect = g_data.roomSys.isReconnect
    if isReconnect == false then return end 

    local my_info = g_data.roomSys:myInfo()
    if not my_info then  return end
    --玩家大厅准备 或非准备 取消初始化
    if my_info.status == 5 or my_info.status == 6 then return end

    local reconnectInfo = g_data.roomSys.m_reconnectInfo
    local user_cards = reconnectInfo.user_cards
    printTable("reconnectInfo=====",reconnectInfo)
    if not user_cards then user_cards = {} end
    for _,v  in pairs(user_cards) do
        local info  = g_data.roomSys:getPlayerInfo(v.uid)
        if info then
            local direction  = info.direction
            local ji_type = v.ji_type
           	if     ji_type == 1 then 
           		info.ChargeChicken = true --冲锋鸡
        	elseif v == 2 then 
        		info.DutyChicken   = true  --责任鸡
       		else 
	            info.ChargeChicken = false 
	            info.DutyChicken   = false
    	    end
           
            local dismiss_cards =  v.dismiss_cards
            local last_out_tile = nil
            for __,eTile  in pairs(dismiss_cards) do
                last_out_tile = self:getOutTile(eTile,direction)
            end

            if info.uid == reconnectInfo.current_uid and last_out_tile then--找到当前操作用户--reconnectInfo.current_uid
               self.m_outTile = last_out_tile
              --self:showFlagByTile(self.m_outTile)
            end          
        end
    end
end

function ServerOutTiles:onTablestyle(_msg)
    for _,direction  in pairs(TileDirection) do
        local tiles = self.m_outs[direction]
        for k, v in pairs(tiles) do
            v:onTablestyle()
        end
        local chickens = self.m_outChickens[direction]
        for k, v in pairs(chickens or {}) do
            v:onTablestyle()
        end
    end
end

function ServerOutTiles:onCleanup()
    self:unregEvent()
end

return ServerOutTiles