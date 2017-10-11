local OutTile = require("app.common.component.sprites.OutTile")
--[[
    打出去的牌
]]
local OutTiles = class("OutTiles",function()
    local node =  display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

function OutTiles:ctor()
    --初始化打出去的牌
    self.m_outs = {}
    for _,direction  in pairs(TileDirection) do
        self.m_outs[direction]   = {}
    end

    --指针
    local proxy = cc.CCBProxy:create()
    self.flag  = CCBReaderLoad("ccb/flag.ccbi", proxy, {})
    self.flag:setVisible(false)
    self.flag:addTo(self)
    self.flag:setLocalZOrder(1000)
    local seq = cc.Sequence:create({cc.MoveBy:create(0.5,cc.p(0,50)),cc.MoveBy:create(0.5,cc.p(0,-50))})
    local rep = cc.RepeatForever:create(seq)
    self.flag:runAction(rep)

    self.maxRow    =0
    self:initPosition()

    self.noUsedTiles = {}
    --预加载麻将牌
    self:perInitTiles()
    self:regEvent()
end

function OutTiles:onCleanup()
    self:unregEvent()
end

--注册事件
function OutTiles:regEvent()
    --发牌
    g_msg:reg("OutTiles", g_msgcmd.UI_OUT_TILE, handler(self, self.C2C_out))
    g_msg:reg("OutTiles", g_msgcmd.UI_Selected_Tile, handler(self, self.C2C_onSelectedTile))
end

--注销事件
function OutTiles:unregEvent()
    g_msg:unreg("OutTiles", g_msgcmd.UI_OUT_TILE)
    g_msg:unreg("OutTiles", g_msgcmd.UI_Selected_Tile)
end

function OutTiles:S2C_operate(_msg)
end

function OutTiles:initPosition()
    self.out_scale = 
    {
            [TileDirection.Direction_Bottom] = 0.4,
            [TileDirection.Direction_Right]  = 0.4,
            [TileDirection.Direction_Top]    = 0.4,
            [TileDirection.Direction_Left]   = 0.4   
    }
    self.out_fix = 
    {
        [TileDirection.Direction_Bottom] = {x = 38,  y = 55},
        [TileDirection.Direction_Right]  = {x = 50,  y = TileProperty.open_height},
        [TileDirection.Direction_Top]    = {x = -38, y = -55},
        [TileDirection.Direction_Left]   = {x = -50, y = -TileProperty.open_height}  
    }

    local max_lefty   = self.maxRow * TileProperty.open_height * self.out_scale[TileDirection.Direction_Left]
    local max_righty  = (self.maxRow * TileProperty.open_height) * self.out_scale[TileDirection.Direction_Right] 
    local max_bottomx = self.maxRow*TileProperty.width * self.out_scale[TileDirection.Direction_Bottom] 
    local max_top     = self.maxRow*TileProperty.width * self.out_scale[TileDirection.Direction_Top] 
    
    self.out_ccp = {
        [TileDirection.Direction_Bottom] = 
        {
            x = (display.width - max_bottomx)/2,
            y =220
        },
        [TileDirection.Direction_Right]  = 
        {
            x = 960,
            y = (display.height - max_righty)/2 + TileProperty.open_height*self.out_scale[TileDirection.Direction_Right]*2
        },

        [TileDirection.Direction_Top]    = 
        {
            x = (display.width - max_top)/2 + max_top - TileProperty.width*self.out_scale[TileDirection.Direction_Top]*2,
            y = 425
        },

        [TileDirection.Direction_Left]   = 
        {
            x = 260,
            y = (display.height - max_lefty)/2 + max_lefty
        }
    }
end

local ZOrder = 100
function OutTiles:getOutTile(eTile,direction)
    local tile   = self:getNoUserdTile()
    if not tile then return end

    tile:setTileTypeAndDirection(eTile,direction)
    tile:setScale(self.out_scale[direction])
   
    local outs = self.m_outs[direction]
    if not outs then outs = {} end
    local count = #outs
    outs[count+1] = tile

    local x = self.out_ccp[direction].x
    local y = self.out_ccp[direction].y
    local size = tile:getTileContentSize()
    if count > 0 then
        local beforeTile = outs[count]
        local beforeSize = beforeTile.step.size
        
        x = beforeTile.step.x
        y = beforeTile.step.y
        if direction == TileDirection.Direction_Bottom then
            x = x + beforeSize.width
            tile:setLocalZOrder(beforeTile.step.zorder  + 1)
        elseif direction == TileDirection.Direction_Top then
            x = x  - size.width
            tile:setLocalZOrder(beforeTile.step.zorder  - 1)
        elseif direction == TileDirection.Direction_Right then
            y = y + beforeSize.height
            tile:setLocalZOrder(beforeTile.step.zorder  - 1)
            --todo
        elseif direction == TileDirection.Direction_Left then
            y = y - beforeSize.height
        end
    end

    if count == (self.maxRow -1) then
        if direction == TileDirection.Direction_Bottom then
            x = self.out_ccp[direction].x
            y = y - self.out_fix[direction].y
        elseif direction == TileDirection.Direction_Top then
            x = self.out_ccp[direction].x
            y = y - self.out_fix[direction].y
        elseif direction == TileDirection.Direction_Right then
            x = self.out_ccp[direction].x + self.out_fix[direction].x
            y = self.out_ccp[direction].y 
        elseif direction == TileDirection.Direction_Left then
            x = self.out_ccp[direction].x + self.out_fix[direction].x
            y = self.out_ccp[direction].y 
        end
    end
    -- 保存牌原始属性,后面因播放动画属性会改变
    tile.step.x      = x
    tile.step.y      = y
    tile.step.size   = size
    tile.step.zorder = tile:getLocalZOrder()
    tile:setPosition(x, y)
    tile:setVisible(true)
    return tile
end

function OutTiles:C2C_out(_msg)
    local dt        = _msg.data
    local direction = dt.direction
    local x         = dt.x
    local y         = dt.y
    local eTile     = dt.eTile
    local tile      = self:getOutTile(eTile,direction)
    if tile then
        print("x===== y =====",x,y)
       -- tile:setPosition(x, y)
        self:runTileOutAnimation(tile)
    end
end
function OutTiles:showFlagByTile(tile)
    local x = tile.step.x
    local y = tile.step.y
    local size = tile.step.size--tile:getTileContentSize()
    local out_ccp = cc.p(x+size.width/2+2,y+size.height/2)
    local out_world_cpp = tile:getParent():convertToWorldSpace(out_ccp)
    self:flagShow(out_world_cpp)
end
--打牌动画
function OutTiles:runTileOutAnimation(tile)
    if tile == nil then return end
    if tile.animationing then return end
    local x = tile.step.x
    local y = tile.step.y
    local size = tile.step.size--tile:getTileContentSize()
    local out_ccp = cc.p(x+size.width/2+2,y+size.height/2)
    local out_world_cpp = tile:getParent():convertToWorldSpace(out_ccp)

    self.m_outTile = tile
    tile:outAnimation(function() self:flagShow(out_world_cpp) end)
end

function OutTiles:flagShow(out_world_cpp)
    self.flag:setVisible(true)
    self.flag:setPosition(out_world_cpp.x-5,out_world_cpp.y + 60)
end

function OutTiles:flagHide()
    self.flag:setVisible(false)
end

function OutTiles:reset()
    for k, v in pairs(self.m_outs) do
        for i, tile in pairs(v) do
            tile:setVisible(false)
            self.noUsedTiles[ #self.noUsedTiles + 1 ] = tile
        end 
    end
    for _,direction  in pairs(TileDirection) do
        self.m_outs[direction]   = {}
    end
    self:flagHide()
end

function OutTiles:C2C_onSelectedTile(_msg)
    local dt        = _msg.data
    local eTile     = dt.eTile
    for k, v in pairs(self.m_outs) do
        for i, tile in pairs(v) do
            if tile.m_eTile == eTile  then
                tile:setGreen()
            else
                tile:setNormal()
            end
        end 
    end
end

--预加载
function OutTiles:perInitTiles()
    for i = 1,108 do
        local tile   = OutTile.new(TileDefine.eTile.Tile_Wan_1,TileDirection.Direction_Bottom)
        tile:setVisible(false)
        tile:addTo(self)
        self.noUsedTiles[ #self.noUsedTiles + 1 ] = tile
    end
end

--获取预加载的牌组
function OutTiles:getNoUserdTile()
    if #self.noUsedTiles < 1 then return nil end
    local tile   = self.noUsedTiles[1]
    tile:stopAllActions()
    tile:setLocalZOrder(0)
    tile.isChargeChicken = false
    tile.animationing    = false
    table.remove(self.noUsedTiles,1)
    return tile
end

--移除打出去的牌
function OutTiles:removeTile(removeTile)
    if removeTile == nil then return end
    local tiles = self.m_outs[removeTile.out_direction]
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

return OutTiles