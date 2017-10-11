--[[
麻将牌
]]
local Tile = class("Tile", function()
    return display.newSprite()
end)

function Tile:ctor(eTile,eDirection)

	self.m_action      = nil -- 牌的动作
	self.m_lockType    = LockTileType.LockTileType_Normal
	
	self.m_tileState   = TileState.TileType_Stand
	self.m_hasSelected = false -- 是否被选中
	self.m_isDraw      = false -- 是否摸牌

	self.m_direction   = eDirection
	self.m_eTile       = eTile
	self.m_ccbRoot = {}
	self.m_ccbRoot.m_bg = display.newSprite("#blue_mj_bg1.png")--self:setSpriteFrame(card_bg[tablestyle])
	self.m_ccbRoot.m_bg:addTo(self)

	self.m_ccbRoot.m_Value = display.newSprite("#mj_1.png")
	self.m_ccbRoot.m_Value:addTo(self.m_ccbRoot.m_bg)

	self:initUI()

	self.step = {x = 0,y = 0}
end

function Tile:getLockTileType()
	return self.m_lockType
end

function Tile:setLockTileType(_type)
	self.m_lockType = _type
	if self.m_lockType  == LockTileType.LockTileType_Lock then
		self:setGray()
	else
		self:setNormal()
	end
end

--置灰(不可点击时置灰)
function Tile:setGray()
	self:setTileColor(cc.c3b(100,100,100))
end

--置绿(查看点击的牌)
function Tile:setGreen()
	self:setTileColor(cc.c3b(124,165,130))
end

--恢复普通
function Tile:setNormal()
	self:setTileColor(cc.c3b(255,255,255))
end

--设置颜色
function Tile:setTileColor( c3b )
	self.m_ccbRoot.m_bg:setColor(c3b)
	self.m_ccbRoot.m_Value:setColor(c3b)
end

function Tile:initUI()
	if self:isTile() then
		local pic = TileDefine.enum[self.m_eTile][2]
		if pic then
			self.m_ccbRoot.m_Value:setSpriteFrame(pic)
		end
	end
	self:setTileDirection(self.m_direction)
end


function Tile:isTile()
	return self.m_eTile >= TileDefine.eTile.Tile_Wan_1 and self.m_eTile <= TileDefine.eTile.Tile_Tong_9
end

function Tile:setTileType(eTile)
	self.m_eTile = eTile
	if self.m_eTile >= TileDefine.eTile.Tile_Wan_1 and self.m_eTile <= TileDefine.eTile.Tile_Tong_9 then
		self.m_ccbRoot.m_Value:setSpriteFrame(TileDefine.enum[self.m_eTile][2])
	end
end

function Tile:setTileDirection(eDirection)
	self.m_direction = eDirection
	self:setTileState(self.m_tileState)
	self:setScale(TileDefine.Scale[self.m_direction])
end

function Tile:setTileTypeAndDirection(eTile,eDirection)
	self:setTileType(eTile)
	self:setTileDirection(eDirection)
end

--[[--
 牌的显示状态
 eState：
 	TileState.TileType_Cover	--盖
	TileState.TileType_Stand	--站立
	TileState.TileType_Open		--展开
]]
function Tile:setTileState(eState,isShow)
	local tablestyle = g_LocalDB:read("tablestyle")

	--还原数据
	self.m_ccbRoot.m_Value:setVisible(false)
	self.m_ccbRoot.m_Value:setScale(1.0)
	self.m_ccbRoot.m_Value:setRotation(0)
	self.m_ccbRoot.m_Value:setFlippedX(false)
	self.m_ccbRoot.m_Value:setFlippedY(false)
	self.m_ccbRoot.m_bg:setFlippedX(false)
	self.m_ccbRoot.m_bg:setScale(1.0)
	self.m_ccbRoot.m_bg:setPosition(TileProperty.content_width/2, TileProperty.content_height/2)

	if eState == TileState.TileType_Stand then
		local bg       = TileDefine.Stand_bg[self.m_direction][tablestyle]
		self.m_ccbRoot.m_bg:setSpriteFrame(bg)
		if self.m_direction  == TileDirection.Direction_Bottom then
			self.m_ccbRoot.m_Value:setVisible(true)
			--因内部图片不规则 所以这暂时写死
			self.m_ccbRoot.m_Value:setPosition(49, 60)
		end

		if self.m_direction  == TileDirection.Direction_Right then
			self.m_ccbRoot.m_bg:setFlippedX(true)
			local x,y = self.m_ccbRoot.m_bg:getPosition()
			local fix = (TileProperty.content_height - TileProperty.content_width)/2
			self.m_ccbRoot.m_bg:setPosition(x-fix, y)
		end
	end

	if eState == TileState.TileType_Cover then
		local bg       = TileDefine.Cover_bg[self.m_direction][tablestyle]
		self.m_ccbRoot.m_bg:setSpriteFrame(bg)
	end

	if eState == TileState.TileType_Open then
		self.m_ccbRoot.m_Value:setVisible(true)
		self.m_ccbRoot.m_Value:setPosition(49, 88)

		local bg = TileDefine.Open_bg[self.m_direction][tablestyle]
		self.m_ccbRoot.m_bg:setSpriteFrame(bg)
		if self.m_direction  == TileDirection.Direction_Bottom then
			local x,y = self.m_ccbRoot.m_bg:getPosition()
			self.m_ccbRoot.m_bg:setPosition(x - TileProperty.padding_x, y)
		end

		if self.m_direction  == TileDirection.Direction_Top then
			local x,y = self.m_ccbRoot.m_bg:getPosition()
			self.m_ccbRoot.m_bg:setPosition(x - TileProperty.padding_x, y)
			self.m_ccbRoot.m_Value:setFlippedX(true)
			self.m_ccbRoot.m_Value:setFlippedY(true)
		end

		if self.m_direction  == TileDirection.Direction_Right then
			local x,y = self.m_ccbRoot.m_bg:getPosition()
			self.m_ccbRoot.m_bg:setPosition(x, y - TileProperty.padding_y)
			self.m_ccbRoot.m_Value:setScale(0.9)
			self.m_ccbRoot.m_Value:setRotation(-90)
			self.m_ccbRoot.m_Value:setPosition(61, 63)
		end
		--修改 牌值位置
		if self.m_direction  == TileDirection.Direction_Left then
			local x,y = self.m_ccbRoot.m_bg:getPosition()
			self.m_ccbRoot.m_bg:setPosition(x, y - TileProperty.padding_y)
			self.m_ccbRoot.m_Value:setScale(0.9)
			self.m_ccbRoot.m_Value:setRotation(90)
			self.m_ccbRoot.m_Value:setPosition(61, 63)
		end
	end
	
	if isShow then
		self:fixScale(eState)
	end
	self.m_tileState = eState
end


--因为 牌的站立  倒下  盖起  高度不一致 所以要调整
function Tile:fixScale(eState)

	if eState == TileState.TileType_Open then
		if self.m_direction  == TileDirection.Direction_Bottom  then
		end

		if self.m_direction  == TileDirection.Direction_Top then
		end

		if self.m_direction  == TileDirection.Direction_Right then
			if self.m_tileState == TileState.TileType_Stand then
				self.m_ccbRoot.m_bg:setScale(TileProperty.stand_height/TileProperty.open_height)
			end
		end

		if self.m_direction  == TileDirection.Direction_Left then
			if self.m_tileState == TileState.TileType_Stand then
				self.m_ccbRoot.m_bg:setScale(TileProperty.stand_height/TileProperty.open_height)
			end
		end
	elseif eState == TileState.TileType_Stand then
		if self.m_direction  == TileDirection.Direction_Bottom then
		end

		if self.m_direction  == TileDirection.Direction_Top then
		end

		if self.m_direction  == TileDirection.Direction_Right then
			if self.m_tileState == TileState.TileType_Open then
				self.m_ccbRoot.m_bg:setScale(TileProperty.open_height/TileProperty.stand_height)
			elseif self.m_tileState == TileState.TileType_Cover then
				self.m_ccbRoot.m_bg:setScale(TileProperty.open_height/TileProperty.cover_height)
			end
		end

		if self.m_direction  == TileDirection.Direction_Left then
			if self.m_tileState == TileState.TileType_Open then
				self.m_ccbRoot.m_bg:setScale(TileProperty.open_height/TileProperty.stand_height)
			elseif self.m_tileState == TileState.TileType_Cover then
				self.m_ccbRoot.m_bg:setScale(TileProperty.open_height/TileProperty.cover_height)
			end
		end
	end
end

function Tile:getRect(beCascade)
	local rect = cc.rect(0, 0, 0,0)
	local m_back = self.m_ccbRoot.m_bg
	if m_back then
		local pos    = m_back:convertToWorldSpace(cc.p(0, 0))
		local size   = m_back:getContentSize()
		rect.x       = pos.x
		rect.y       = pos.y 
		rect.height  = size.height
		rect.width   =  size.width
		local scalex = m_back:getScaleX()
		local scaley = m_back:getScaleY()
		if beCascade then
			local  parent = m_back:getParent()
			if parent then
				scalex = scalex * parent:getScaleX()
				scaley = scaley * parent:getScaleY()
				parent = parent:getParent()
			end

			if parent then
				scalex = scalex * parent:getScaleX()
				scaley = scaley * parent:getScaleY()
			end
		end
		rect.height = rect.height * scaley
		rect.width  = rect.width  * scalex
	end
	return rect
end

-- --加载ccbi
-- function Tile:_ccb()
--   self.m_ccbRoot = {}
--   local proxy = cc.CCBProxy:create()
--   local node  = CCBReaderLoad("ccb/Tile.ccbi", proxy, self.m_ccbRoot)
--   node:addTo(self)
--   self:setContentSize(node:getContentSize())
-- end

function Tile:delayShow(delay)
	-- self:setVisible(false)
	-- self:stopAllActions()
 -- 	local actions = {}
 --    self:setVisible(false)
 --    actions[#actions + 1] = cc.DelayTime:create(delay)
 --    actions[#actions + 1] = cc.Show:create()

 --    self:runAction(cc.Sequence:create(actions))
end


function Tile:setHasSelected( _b)
	self.m_hasSelected = _b
end

function Tile:getHasSelected()
	return self.m_hasSelected
end

function  Tile:getTileContentSize()
	local size   = self.m_ccbRoot.m_bg:getContentSize()
	local parent = self.m_ccbRoot.m_bg:getParent()
	local scalex = self.m_ccbRoot.m_bg:getScaleX()
	local scaley = self.m_ccbRoot.m_bg:getScaleY()
	if parent then
		scalex = scalex * parent:getScaleX()
		scaley = scaley * parent:getScaleY()
		parent = parent:getParent()
	end
	--减少遍历 防止卡顿
	if parent then
		scalex = scalex * parent:getScaleX()
		scaley = scaley * parent:getScaleY()
	end

	if self.m_direction  == TileDirection.Direction_Bottom or self.m_direction  == TileDirection.Direction_Top then
	else
		if self.m_tileState == TileState.TileType_Cover then
			size.height = TileProperty.cover_height
		end
		if self.m_tileState == TileState.TileType_Stand then
			size.height = TileProperty.stand_height
		end

		if self.m_tileState == TileState.TileType_Open then
			size.height = TileProperty.open_height
		end
	end
	size.width   = size.width * scalex
	size.height  = size.height * scaley
	return size
end

function Tile:setQueMen(_QueMen)
	if _QueMen < 1 then return end

	if _QueMen == 1 then
		if self.m_eTile >= TileDefine.eTile.Tile_Wan_1 and self.m_eTile <= TileDefine.eTile.Tile_Wan_9 then
			self:setLockTileType(LockTileType.LockTileType_Lock)
		end
	elseif _QueMen==2 then
		if self.m_eTile >= TileDefine.eTile.Tile_Tiao_1 and self.m_eTile <= TileDefine.eTile.Tile_Tiao_9 then
			self:setLockTileType(LockTileType.LockTileType_Lock)
		end

	elseif _QueMen==3 then
		if self.m_eTile >= TileDefine.eTile.Tile_Tong_1 and self.m_eTile <= TileDefine.eTile.Tile_Tong_9 then
			self:setLockTileType(LockTileType.LockTileType_Lock)
		end
	else
	end
end

function Tile:setChargeChicken()
	if self.m_direction  == TileDirection.Direction_Bottom or self.m_direction  == TileDirection.Direction_Top then
		self:setTileDirection(TileDirection.Direction_Right)
	else
		self:setTileDirection(TileDirection.Direction_Bottom)
	end
end

function Tile:onTablestyle()
	local tablestyle = g_LocalDB:read("tablestyle")
	if self.m_tileState  == TileState.TileType_Stand then
		local frame       = TileDefine.Stand_bg[self.m_direction][tablestyle]
		self.m_ccbRoot.m_bg:setSpriteFrame(frame)
	end
	if self.m_tileState == TileState.TileType_Cover then
		local frame       = TileDefine.Cover_bg[self.m_direction][tablestyle]
		self.m_ccbRoot.m_bg:setSpriteFrame(frame)
	end
	if self.m_tileState == TileState.TileType_Open then
		local frame       = TileDefine.Open_bg[self.m_direction][tablestyle]
		self.m_ccbRoot.m_bg:setSpriteFrame(frame)
	end
end

return Tile