local OutTile = require("app.common.component.sprites.OutTile")
local OutTiles = require("app.common.component.sprites.OutTiles")
--[[
    普通打牌的基础上
    增加了对鸡牌的特殊处理
]]
local ChickenOutTiles = class("ChickenOutTiles",OutTiles)

function ChickenOutTiles:ctor()
	ChickenOutTiles.super.ctor(self)
    --增加鸡排数组
    self.m_outChickens = {}
    for _,direction  in pairs(TileDirection) do
        self.m_outChickens[direction]   = {}
    end
end

--初始化牌坐标
function ChickenOutTiles:initPosition()
    ChickenOutTiles.super.initPosition(self)
    --对鸡牌的位置进行了特殊处理
    local max_lefty  = self.maxRow * TileProperty.open_height * self.out_scale[TileDirection.Direction_Left]
    local max_righty = (self.maxRow * TileProperty.open_height) * self.out_scale[TileDirection.Direction_Right]
    local max_bottomx = self.maxRow*TileProperty.width * self.out_scale[TileDirection.Direction_Bottom] 
    local max_top     = self.maxRow*TileProperty.width * self.out_scale[TileDirection.Direction_Top] 
    self.out_chicken_ccp = {
        [TileDirection.Direction_Bottom] = 
        {
            x = (display.width - max_bottomx)/2,
            y = 276
        },
        [TileDirection.Direction_Right]  = 
        {
            x = 911,
            y = (display.height - max_righty)/2 + TileProperty.open_height*self.out_scale[TileDirection.Direction_Right]*2
        },
        [TileDirection.Direction_Top]    = 
        {
            x = (display.width - max_top)/2 + max_top - TileProperty.width*self.out_scale[TileDirection.Direction_Top]*2,
            y = 370
        },
        [TileDirection.Direction_Left]   = 
        {
            x = 308,
            y = (display.height - max_lefty)/2 + max_lefty
        },  
    }
end

--打牌对鸡牌特殊处理
function ChickenOutTiles:getOutTile(eTile,direction)
	
    -- 冲锋鸡
    if eTile == TileDefine.eTile.Tile_Tiao_1 then
        --冲锋鸡特殊处理
        local tile   = self:getNoUserdTile()
        if not tile then return end
        tile:setTileTypeAndDirection(eTile,direction)
        tile:setScale(self.out_scale[direction])

        local zOrder = 100
        
        local info  = g_data.roomSys:getPlayerInfoByDirection(direction)
        if not info then return end

        local chickens = self.m_outChickens[direction]
        if not chickens then chickens = {} end
        
        local count = #chickens
        chickens[count+1] = tile
        local x = self.out_chicken_ccp[direction].x
        local y = self.out_chicken_ccp[direction].y
        local size = tile:getTileContentSize()
        --设置冲锋鸡状态（旋转放倒 与普通鸡区分）
        if info.ChargeChicken == true and count == 0  then
            tile:setChargeChicken()
            tile:setScale(self.out_scale[direction])
            size = tile:getTileContentSize()
            if direction == TileDirection.Direction_Top then
                local bg_x,bg_y = tile.m_ccbRoot.m_bg:getPosition()
                tile.m_ccbRoot.m_bg:setPosition(bg_x,bg_y + TileProperty.padding_y*2)
                x = x - (size.width - size.height)/2
            elseif direction == TileDirection.Direction_Bottom then
            elseif direction == TileDirection.Direction_Left then
                y = y - size.width/2
            elseif direction == TileDirection.Direction_Right  then
                local bg_x,bg_y = tile.m_ccbRoot.m_bg:getPosition()
                tile.m_ccbRoot.m_bg:setPosition(bg_x + TileProperty.padding_x*2, bg_y)
            end
        end
        
        if count > 0 then
            local beforeTile = chickens[count]
            zOrder = beforeTile.step.zorder
            local beforeSize = beforeTile.step.size
            x = beforeTile.step.x
            y = beforeTile.step.y

            if direction == TileDirection.Direction_Bottom then
                x = x + beforeSize.width
            elseif direction == TileDirection.Direction_Top then
                x = x  - size.width
            elseif direction == TileDirection.Direction_Left then
                y = y - size.height
            elseif direction == TileDirection.Direction_Right  then
                y = y + beforeSize.height
            end
        end

        if direction == TileDirection.Direction_Bottom then
            tile:setLocalZOrder(zOrder - 101)
        elseif direction == TileDirection.Direction_Top then
            tile:setLocalZOrder(zOrder + 1)
        elseif direction == TileDirection.Direction_Left then
        elseif direction == TileDirection.Direction_Right  then
            tile:setLocalZOrder(zOrder - 101)
        end
        tile.step.x      = x
        tile.step.y      = y
        tile.step.size   = size
        tile.step.zorder = tile:getLocalZOrder()
        tile:setPosition(x, y)
        tile:setVisible(true )
        return tile
    end

   	return ChickenOutTiles.super.getOutTile(self,eTile,direction)
end


function ChickenOutTiles:reset()
    ChickenOutTiles.super.reset(self)
    for k, v in pairs(self.m_outChickens) do
        for i, tile in pairs(v) do
            tile:setVisible(false)
            self.noUsedTiles[ #self.noUsedTiles + 1 ] = tile
        end 
    end
    for _,direction  in pairs(TileDirection) do
        self.m_outChickens[direction]   = {}
    end
end

--移除打出去的牌
function ChickenOutTiles:removeTile(removeTile)
    if removeTile == nil then return end
    removeTile:stopAllActions()
    local tiles = self.m_outs[removeTile.out_direction]

    if  removeTile.m_eTile == TileDefine.eTile.Tile_Tiao_1  then
        tiles = self.m_outChickens[removeTile.out_direction]
    end
    if not tiles then return end
    for k, v in pairs(tiles) do
        if v == removeTile  then
            v:setVisible(false)
            table.remove(tiles,k)
            self.noUsedTiles[ #self.noUsedTiles + 1 ] = v
            self.m_outTile = nil
            break
        end
    end
    self:flagHide()
end

return ChickenOutTiles