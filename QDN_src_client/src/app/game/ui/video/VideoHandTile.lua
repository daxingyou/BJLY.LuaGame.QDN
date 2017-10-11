local HandTile = require("app.common.component.sprites.HandTile")
--[[
 录像专用麻将手牌
]]
local VideoHandTile = class("VideoHandTile", HandTile)

function VideoHandTile:ctor()
	VideoHandTile.super.ctor(self)
end

--发牌
function VideoHandTile:dispatchTiles(uid,tiles)
    local info = g_data.roomSys:getPlayerInfo(uid)
    
    if info then
        local direction = info.direction
        self.m_noUsedTiles[direction] =  tiles
        local tile = self:popTile(direction)
        while tile do
            if direction ~=  TileDirection.Direction_Bottom then
                if direction ~=  TileDirection.Direction_Top then
                    tile:setScale(0.35)
                end
                tile:setTileState(TileState.TileType_Open)
            end
            self:addTile(direction, tile,0)
            tile = self:popTile(direction)
        end
    end
end

--摸牌
function VideoHandTile:C2C_addTile(uid,etile)
	
    local info   = g_data.roomSys:getPlayerInfo(uid)
    if info then
        local direction = info.direction
        local noUsedTiles = self.m_noUsedTiles[direction]
        noUsedTiles[ #noUsedTiles + 1 ] = etile
        if #noUsedTiles == 1 then
        	local tile = self:popTile(direction)
			if tile then
                if direction ~=  TileDirection.Direction_Bottom then
                    if direction ~=  TileDirection.Direction_Top then
                        tile:setScale(0.35)
                    end
                    
                    tile:setTileState(TileState.TileType_Open)
                end
				tile.m_isDraw = true
				self:addTile(direction, tile,g_data.roomSys.m_float)
			end
        end
    end
end

--系统打牌成功
function VideoHandTile:throwTile(uid,etile)
    local info   = g_data.roomSys:getPlayerInfo(uid)
    if info then
        local direction = info.direction
        local tile      = self:getTile(direction,etile)
        --派发打牌消息
        local x , y = 0,0
        if tile then
            x,y   = tile:getPosition()
            g_msg:post(g_msgcmd.UI_OUT_TILE,{eTile = etile,direction = direction, x = x,y= y})

        end
        g_audio.playTileSound(etile,info.sex)
        
        self:removeTile(direction,etile)
    end
end

--录像全部排序
function VideoHandTile:sortTileValue()
    for _, v in pairs(self.m_handTiles) do
        self:sort(v)
    end
end

function VideoHandTile:updateTilePosition()

    self:sortTileValue()
    
    for k, v in pairs(self.m_handTiles) do
        local cardNumber =  #v
        -- 空出摸牌位置
        local isDraw = false
        for i, tile in pairs(v) do
            if tile.m_isDraw then
                isDraw = true
                break
            end
        end
        if not isDraw then
            cardNumber = cardNumber + 1
        end

        local beforeTile = nil
        for i, tile in pairs(v) do
            local size       = tile:getTileContentSize()
            local width      = size.width
            local height     = size.height
            local max_width  = width*cardNumber
            local max_height = height*cardNumber
            local index      = i - 1
            local draw       = 0

            if tile.m_isDraw then
                draw = 15
            end


            if k == TileDirection.Direction_Bottom then
                local startx = display.width - Direction_BottomX - max_width
                tile:setPosition(startx + index*width+draw,Direction_BottomY)
            end

            if k == TileDirection.Direction_Top then
                local startx = Direction_TopX + max_width
                tile:setPosition(startx - index*width-draw,Direction_TopY)
            end

            if k == TileDirection.Direction_Right then
                local starty = display.height -  Direction_RightY - max_height
                local y = starty + index*height+draw
                tile:setPosition(Direction_RightX,y)
                tile:setLocalZOrder(-y)
            end

            if k == TileDirection.Direction_Left then
                local starty =  Direction_LeftY + max_height
                local y = starty - index*height-draw
                tile:setPosition(Direction_LeftX,y)
                tile:setLocalZOrder(-y)
            end
        end 
    end
end

return VideoHandTile