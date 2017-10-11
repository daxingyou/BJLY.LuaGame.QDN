local Tile = require("app.common.component.sprites.Tile")
local TipTile = require("app.common.component.sprites.TipTile")
local TileItemGroup = require("app.common.component.sprites.TileItemGroup")
--[[
麻将牌
]]
local HandTile = class("HandTile", function()
    local node =  display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

HandTileAction =
{
	HandTileAction_Invalid         = -1,
	HandTileAction_ThrowTile       = 1,		-- 请求玩家打牌
	HandTileAction_TingTile        = 2,		-- 玩家选择听牌
	HandTileAction_Tinged          = 3,		-- 已经听牌 可随时查看听牌信息
	HandTileAction_TingThrowTile   = 4,		-- 玩家听牌后 选择打牌
}
--[[
	只有摸牌- 可操作 
	都收到才可以打牌
]]
HandTileState =
{
	HandTileState_Invalid          = -1,
	HandTileState_AddTile          = 1,
	HandTileState_Opearte		   = 2
}
function HandTile:ctor()
	self.m_action = HandTileAction.HandTileAction_Invalid -- 牌的动作
	-- 状态  当 HandTileState_AddTile HandTileState_Opearte 都收到才可以打牌
	self.m_state  = HandTileState.HandTileState_Invalid
	self.m_curTouchTile  = nil	 --当前选中的牌
	self.m_endTouchTile  = nil	 --记录玩家结束按牌时按的牌 用于快速定位到出牌
	self.m_perTiles      = {}	 --预加载手牌数组
	self.m_noUsedTiles   = {}	 
	self.m_touchTiles    = {}    --可以用手点的牌
	self.m_dispatching   = false --是否在发牌中...
	self.m_operating     = false --是否在操作
	self.zOrder  = 100

	self.m_tileItemGroup = {}    --成型牌
	self.m_handTiles     = {}	 --手牌
	self.m_Tipoving      = false --是否滑动
	--初始化成型牌
	for _,direction  in pairs(TileDirection) do
		local group                     = TileItemGroup.new(direction)
		group:addTo(self)
		self.m_tileItemGroup[direction] = group
		self.m_noUsedTiles[direction]   = {}
		self.m_handTiles[direction]     = {}
	end

	--预加载手牌
	self:perInitTiles()

	--初始化提示牌
	self.m_tileTip = TipTile.new(TileDefine.eTile.Tile_Wan_1)
	self.m_tileTip:setVisible(false)
	self.m_Tipoving = false
	self.m_tileTip:addTo(self)
	self.step = {}
	--注册触摸事件
	self:regTouch()
end

--注册打牌的触摸
function HandTile:regTouch()
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(handler(self,self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(handler(self,self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function HandTile:onTouchBegan(touch, event)
	--判断是否显示 
	local isVisible = self:isVisible()

	if  not isVisible then
		return false
	end
	if  self.m_action == HandTileAction.HandTileAction_TingThrowTile or
		self.m_action == HandTileAction.HandTileAction_Tinged then
		return false
	end
	--发牌中
	if self.m_dispatching then return false end
	--操作中
	if self.m_operating then return false end

	self.m_touchTiles   = {}
	--只判断本家的牌
	for k, v in pairs(self.m_handTiles[TileDirection.Direction_Bottom]) do
		repeat
			--打牌
			if self.m_action == HandTileAction.HandTileAction_ThrowTile then
				--锁牌不能被选
				if LockTileType.LockTileType_Lock == v:getLockTileType() then
					break
				end
			end
			--听牌
			if self.m_action == HandTileAction.HandTileAction_TingTile then
				--锁牌不能被选
				if LockTileType.LockTileType_Lock == v:getLockTileType() then
					break
				end
			end
			self.m_touchTiles[#self.m_touchTiles + 1] = v
		until true
	end

	local pt = self:convertToNodeSpace(touch:getLocation())
	for k, v in pairs(self.m_touchTiles) do
		local rect =  v:getRect(true)
		if cc.rectContainsPoint(rect, pt) then
        	self:onTouchTile(v)
            return true
        end
	end

	return false
end

function HandTile:onTouchMoved(touch, event)
	local pt = self:convertToNodeSpace(touch:getLocation())
	local oldpt = self:convertToNodeSpace(touch:getPreviousLocation())

	if self.m_curTouchTile then
		local npos = self:convertToNodeSpace(touch:getLocation())
		self.m_tileTip:setTileType(self.m_curTouchTile.m_eTile)
		local size = self.m_tileTip:getContentSize()
		
		--当牌移动到边界 矫正坐标
		if npos.x < size.width then
			npos.x = 0
		else
			npos.x = npos.x - size.width 
		end

		self.m_tileTip:setPosition(npos)
		
		if npos.y > 106 then
			self.m_tileTip:setVisible(true)
			self:setLocalZOrder(25)
			self.m_Tipoving = true
			self.m_curTouchTile:setHasSelected(true)
			return
		else
			self.m_Tipoving = false
			self.m_tileTip:setVisible(false)
			self.m_tileTip:setLocalZOrder(10)
		end

		local rect =  self.m_curTouchTile:getRect(true)
		if cc.rectContainsPoint(rect, pt) then
        	return
    	end
	end

	if self.m_endTouchTile then
		local rect = self.m_endTouchTile:getRect(true)
		rect.height = rect.height* 2 + TileHandMoveHeight
		rect.y = rect.y - TileHandMoveHeight
		if cc.rectContainsPoint(rect, pt) then
			return
		end
	end
	
	for k, v in pairs(self.m_touchTiles) do
		repeat
			if self.m_curTouchTile == v then
				break
			end
			local rect =  v:getRect(true)
			if cc.rectContainsPoint(rect, pt) then
        		self:onTouchTile(v)
            	return
        	end
		until true
	end
	self:onTouchTile(nil)
end

function HandTile:onTouchEnded()
	
	self.m_touchTiles = {}
	if 	self.m_action == HandTileAction.HandTileAction_Invalid or 
	   	self.m_action == HandTileAction.HandTileAction_TingThrowTile or
	 	self.m_action == HandTileAction.HandTileAction_Tinged then
		self.m_tileTip:setVisible(false)
		self:setLocalZOrder(10)
		return 
	end
	
	self.m_endTouchTile = self.m_curTouchTile
	self:onTouchTile(nil)
	
	if self.m_action == HandTileAction.HandTileAction_ThrowTile  then
		if self.m_endTouchTile then
			if not self.m_endTouchTile:getHasSelected() then
				self.m_endTouchTile:setHasSelected(true)
			else
				self.m_endTouchTile:setHasSelected(false)
				--发送打牌命令
				self:beDoOutTile()
				--先做出牌动画
				--self:outMid()
				return
			end
		end
	elseif self.m_action == HandTileAction.HandTileAction_TingTile then
		if self.m_endTouchTile then
			if  not self.m_endTouchTile:getHasSelected() then
				self.m_endTouchTile:setHasSelected(true)
			else
				self.m_endTouchTile:setHasSelected(false)
				--发送听牌
				self:beDoOutTile()
				return
			end
		end
	end
	self.m_tileTip:setVisible(false)
	self:setLocalZOrder(10)
end
function HandTile:outMidSuccess()
	self:onOutTile(self.m_endTouchTile)
end
function HandTile:outMid()
	self.animationing =true
	self:stopAllActions()


	local midx  = 0
	local midy  = 0
	
	midx = display.width/2 - 32
	midy = 180


	local time = 1--0.6
	local scale = self:getScale()
	
	local moveActions = {}
	local move_mid   = cc.MoveTo:create(time*0.1, cc.p(midx,midy))
	moveActions[#moveActions+1] = move_mid
	

	local scaleActions = {}
	local scale_mid   = cc.ScaleTo:create(time*0.1, 0.7)
	scaleActions[#scaleActions+1] = scale_mid
	
	self.m_tileTip:runAction(cc.Sequence:create({
	        cc.Spawn:create({
	            cc.Sequence:create(moveActions),
	            cc.Sequence:create(scaleActions),
	        }),
	    	cc.CallFunc:create(
	    		function() --结束后回调
	    			self.m_tileTip.bg:setVisible(true)
		    		self.animationing = false
		    		self:outMidSuccess()
	       		 end
	       	)
   		}))

end
function HandTile:unTouchTile()
	if self.m_curTouchTile == nil then
		if self.m_endTouchTile then
			if self.m_endTouchTile:getHasSelected() then
				self.m_endTouchTile:setPositionY(self.m_endTouchTile:getPositionY() - TileHandMoveHeight)
				self.m_endTouchTile:setHasSelected(false)
				self:onTileUnSelected(self.m_endTouchTile)
				self.m_endTouchTile = nil
			end
		end 
	end
end

function HandTile:onTouchTile(tile)

	if self.m_curTouchTile == tile then return end

		if tile then
			if tile:getHasSelected() then
			else
				tile:setPositionY(tile:getPositionY()+TileHandMoveHeight)
				self:onTileSelected(tile)
			end
		end
		if self.m_curTouchTile then
			-- 将要打出去的牌 就不做下面的动画了
			if self.m_endTouchTile ~= self.m_curTouchTile then
				self.m_curTouchTile:setPositionY(self.m_curTouchTile:getPositionY()-TileHandMoveHeight)
				self.m_curTouchTile:setHasSelected(false)
			end
		end
		
		if tile and self.m_endTouchTile then
			if tile ~= self.m_endTouchTile then
				if self.m_endTouchTile:getHasSelected() then
					self.m_endTouchTile:setPositionY(self.m_endTouchTile:getPositionY() - TileHandMoveHeight)
					self.m_endTouchTile:setHasSelected(false)
					self:onTileUnSelected(self.m_endTouchTile)
					self.m_endTouchTile = nil
				end
			end
		end
	self.m_curTouchTile = tile
end

--================== 麻将牌的创建  加入  移除  排序逻辑 =========================----

function HandTile:popTile(_direction)
	local noUsedTiles = self.m_noUsedTiles[_direction]
	if not noUsedTiles then return nil end
	if #noUsedTiles < 1 then return nil end

	local tile   = self:getPerTile()--Tile.new(noUsedTiles[1],_direction)
	if not tile then return nil end
	tile:setTileTypeAndDirection(noUsedTiles[1],_direction)
	tile:setVisible(true)
	table.remove(noUsedTiles,1)
	return tile
end

--获取预加载的牌组
function HandTile:getPerTile()
    if #self.m_perTiles < 1 then return nil end
    local tile   = self.m_perTiles[1]
    tile:setTileState(TileState.TileType_Stand)
    tile:setLockTileType(LockTileType.LockTileType_Normal)
    tile.m_isDraw = false
    tile:stopAllActions()
    tile:setLocalZOrder(0)
    table.remove(self.m_perTiles,1)
    return tile
end

function HandTile:getNoUserdTile(_direction)
	local noUsedTiles = self.m_noUsedTiles[_direction]
	if not noUsedTiles then return nil end
	if #noUsedTiles < 1 then return nil end

	local tile   = noUsedTiles[1]
	table.remove(noUsedTiles,1)
	return tile
end

--[[--
  将麻将牌加入桌面
  _direction == 方向
  _tile      == 牌 
  _delay     == 显示延迟时间
]]

--增加手牌
function HandTile:addTile(_direction,_tile,_delay)
	local tiles = self.m_handTiles[_direction]
	if not tiles then tiles = {} end
	tiles[#tiles+1] = _tile

	self:updateTilePosition()
end

--发牌用
function HandTile:dispatchAddTile(_direction,_tile)
	local tiles = self.m_handTiles[_direction]
	if not tiles then tiles = {} end
	tiles[#tiles+1] = _tile
end

--移除牌
function HandTile:removeTile(_direction,_etile)
	local tiles = self.m_handTiles[_direction]

	if not tiles then tiles = {} end

	self.m_tileTip:setVisible(false)
	self:setLocalZOrder(10)
	self.m_Tipoving = false
	self.m_touchTiles = {}
	self:onTouchTile(nil)
	
	if self.m_curTouchTile then
		self.m_curTouchTile:setHasSelected(false)
	end
	if self.m_endTouchTile then
		self.m_endTouchTile:setHasSelected(false)
	end

	local removeIndex  = -1
	local removeTile   = nil
	for k, v in pairs(tiles) do
		if v.m_eTile == _etile then
			removeTile = v
			removeIndex = k
		end
		v.m_isDraw = false
	end
	if removeTile then
		removeTile:setVisible(false)
		table.remove(tiles, removeIndex)
		self.m_perTiles[ #self.m_perTiles + 1 ] = removeTile
		removeTile = nil
	else
		for k, v in pairs(tiles) do
			if v.m_eTile == TileDefine.eTile.Tile_Invaid or v.m_eTile == -1 then
				v:setVisible(false)
				table.remove(tiles, k)
				self.m_perTiles[ #self.m_perTiles + 1 ] = v
				v = nil
				break
			end
		end
	end 
	self.m_curTouchTile  = nil
	self.m_endTouchTile  = nil
end

--获取牌
function HandTile:getTile(_direction,_etile)
	local tiles = self.m_handTiles[_direction]
	if not tiles then tiles = {} end
	local tile = nil
	for k, v in pairs(tiles) do
		if v.m_eTile == _etile then
			tile =  v
			break
		end
	end
	return tile
end

--碰牌
function HandTile:pong(uid,puid,code,eTile)
	local info   = g_data.roomSys:getPlayerInfo(uid)
	if info then
        local direction = info.direction
   		self:removeTile(direction,eTile)
   		self:removeTile(direction,eTile)
   		self.m_tileItemGroup[direction]:addItem(code, eTile)
   		self:updateTilePosition()
    end
    --碰牌后可以打牌
    if uid == g_data.userSys.UserID then
       	if self.m_action == HandTileAction.HandTileAction_Invalid then
    		self.m_action = HandTileAction.HandTileAction_ThrowTile
       	end
    end
end

--杠牌
function HandTile:kong(uid,puid,code,eTile)
	local info   = g_data.roomSys:getPlayerInfo(uid)
	if info then
        local direction = info.direction
   		if code == OperateType.Fill_kong then
   		 	self:removeTile(direction,eTile)
  		elseif code == OperateType.Self_kong then
   		 	self:removeTile(direction,eTile)
   		 	self:removeTile(direction,eTile)
   		 	self:removeTile(direction,eTile)
   		 	self:removeTile(direction,eTile)
   		else
   			self:removeTile(direction,eTile)
   		 	self:removeTile(direction,eTile)
   		 	self:removeTile(direction,eTile)
  		end
  		self.m_tileItemGroup[direction]:addItem(code, eTile)
  		self:updateTilePosition()
    end
end

--发牌
function HandTile:dispatchTiles()
	print("dispatchTiles")
	self.m_dispatching = true
	self.m_noUsedTiles[TileDirection.Direction_Bottom] =  g_data.roomSys:myInfo().cards
	if g_data.roomSys.PlayRule == RoomDefine.Rule.room_4 then
		self.m_noUsedTiles[TileDirection.Direction_Right] = {255,255,255,255,255,255,255,255,255,255,255,255,255}
		self.m_noUsedTiles[TileDirection.Direction_Top]   = {255,255,255,255,255,255,255,255,255,255,255,255,255}
		self.m_noUsedTiles[TileDirection.Direction_Left]  = {255,255,255,255,255,255,255,255,255,255,255,255,255}
	elseif g_data.roomSys.PlayRule == RoomDefine.Rule.room_2D or
		   g_data.roomSys.PlayRule == RoomDefine.Rule.room_2D2 then
		self.m_noUsedTiles[TileDirection.Direction_Top]   = {255,255,255,255,255,255,255,255,255,255,255,255,255}
	elseif g_data.roomSys.PlayRule == RoomDefine.Rule.room_3D or
		   g_data.roomSys.PlayRule == RoomDefine.Rule.room_3D2
	 then
		self.m_noUsedTiles[TileDirection.Direction_Right] = {255,255,255,255,255,255,255,255,255,255,255,255,255}
		self.m_noUsedTiles[TileDirection.Direction_Left]  = {255,255,255,255,255,255,255,255,255,255,255,255,255}
	end
	
	g_data.roomSys.m_float = 0.0
	local taketileperround = 4 --每次抓4张牌
	local roundcount = 4       --抓4轮

	for  i = 1 ,roundcount do
		--每个人轮流抓牌
		for _,direction  in pairs(TileDirection) do
	
			--本轮抓牌张数
			local taketilecount = taketileperround
			--最后一轮只抓一张（庄家多的那张牌先不抓）
			if i == roundcount then
				taketilecount = 1
			end
			--每次抓tilecountpertime张
			for  k = 1,taketilecount do
				local tile = self:popTile(direction)
				if tile then
					self:dispatchAddTile(direction, tile)
				end
			end
			-- g_data.roomSys.m_float = g_data.roomSys.m_float+0
		end
	end
	self:updateTilePosition()
	self.m_dispatching = false
	g_data.roomSys.m_float = 0
	-- self:performWithDelay(
	-- function() 
	-- 	self.m_dispatching = false
	-- 	g_data.roomSys.m_float = 0
	--  end, g_data.roomSys.m_float)
end

--[[--
 排序所有手牌
]]
function HandTile:updateTilePosition(str)
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

		for i, tile in pairs(v) do
			local size       = tile:getTileContentSize()
			local width      = size.width
			local height     = size.height
			local max_width  = width*cardNumber
			local max_height = height*cardNumber
			local index      = i - 1
			local draw       = 0
			local strat      = 1

			if tile.m_isDraw then
				draw = 15
			end

			if k == TileDirection.Direction_Bottom then
				strat = display.width - Direction_BottomX - max_width
				tile:setPosition(strat + index*width+draw,Direction_BottomY)
			elseif k == TileDirection.Direction_Top then
				strat = Direction_TopX + max_width
				tile:setPosition(strat - index*width-draw,Direction_TopY)
			elseif  k == TileDirection.Direction_Right then
				strat = display.height -  Direction_RightY - max_height
				tile:setPosition(Direction_RightX,strat + index*height+draw)
				tile:setLocalZOrder(-index)
			elseif k == TileDirection.Direction_Left  then
				strat =  Direction_LeftY + max_height
				tile:setPosition(Direction_LeftX,strat - index*height-draw)
				tile:setLocalZOrder(index)
			end
		end 
	end
end

--结算时候 胡牌翻牌显示
function HandTile:showHu()

	local players = g_data.roomSys:getRoomPlayers()
	local function _sort(a,b)
      return  a < b
  	end

	for _, info in pairs(players) do
		repeat
			local direction = info.direction
			local report    = g_data.reportSys:getRoundReportByUID(info.uid)
			local cards     = report.hand_cards
	  		table.sort(cards,_sort)

	  		local hucard        = report.hu_cardid
			local hupai_fangshi = report.hupai_fangshi
			local hupai_type    = report.hupai_type
			local isWin         = hupai_type > 1
			local titles        = self.m_handTiles[direction]
			local isOpen = false --判断是否已经展示 需求----
			for i, tile in pairs(titles) do
				--暂时这样
				if tile.m_tileState == TileState.TileType_Open then
					isOpen = true
					break
				end

				local eTile = cards[i]
				if eTile then 
					if eTile >= TileDefine.eTile.Tile_Wan_1 and eTile <= TileDefine.eTile.Tile_Tong_9 then
						tile:setTileType(eTile)
					end
					tile.m_isDraw = false
					tile:setTileState(TileState.TileType_Open,true)
				else
					self:removeTile(direction,tile.m_eTile)
				end
				
			end
			if isOpen then break end

			if isWin then
	        	local noUsedTiles = self.m_noUsedTiles[direction]
	        	noUsedTiles[ #noUsedTiles + 1 ] = hucard
	        	local tile = self:popTile(direction)
				if tile then
					tile.m_isDraw = true
					self:addTile(direction, tile,g_data.roomSys.m_float)
					tile:setTileState(TileState.TileType_Open,true)
				end
			end
		until true
	end
end

--检查定缺
function HandTile:checkQueMen()
	
	local info   = g_data.roomSys:getPlayerInfoByDirection(TileDirection.Direction_Bottom)
	if not info then return end
	local quemen = info.QueMen
	if quemen < 1 then return end

	local isHave = false
	local tiles = self.m_handTiles[TileDirection.Direction_Bottom]
	if not tiles then tiles = {} end

	--先检查是否含有缺门
	for _, v in pairs(tiles) do
		if quemen == 1 then
			if v.m_eTile >= TileDefine.eTile.Tile_Wan_1 and v.m_eTile <= TileDefine.eTile.Tile_Wan_9 then
				isHave = true
			end
		elseif quemen == 2 then
			if v.m_eTile >= TileDefine.eTile.Tile_Tiao_1 and v.m_eTile <= TileDefine.eTile.Tile_Tiao_9 then
				isHave = true
			end

		elseif quemen == 3 then
			if v.m_eTile >= TileDefine.eTile.Tile_Tong_1 and v.m_eTile <= TileDefine.eTile.Tile_Tong_9 then
				isHave = true
			end
		else
		end
		if isHave then break end
	end
	for _, v in pairs(tiles) do
		repeat
			--没有  随便打
			if not isHave then  
				v:setLockTileType(LockTileType.LockTileType_Normal)
				break
			end
			--如果有 先打缺门
			if quemen == 1 then
				if v.m_eTile >= TileDefine.eTile.Tile_Wan_1 and v.m_eTile <= TileDefine.eTile.Tile_Wan_9 then
				else
					v:setLockTileType(LockTileType.LockTileType_Lock)
				end
			elseif quemen==2 then
				if v.m_eTile >= TileDefine.eTile.Tile_Tiao_1 and v.m_eTile <= TileDefine.eTile.Tile_Tiao_9 then
				else
					v:setLockTileType(LockTileType.LockTileType_Lock)
				end

			elseif quemen==3 then
				if v.m_eTile >= TileDefine.eTile.Tile_Tong_1 and v.m_eTile <= TileDefine.eTile.Tile_Tong_9 then
				else
					v:setLockTileType(LockTileType.LockTileType_Lock)
				end
			else
			end
		until true
	end
end

function HandTile:reset()
	for k, v in pairs(self.m_handTiles) do
		for i, tile in pairs(v) do
			tile:setVisible(false)
			self.m_perTiles[ #self.m_perTiles + 1 ] = tile
		end
		v = {}
	end

	for _,direction  in pairs(TileDirection) do
		self.m_tileItemGroup[direction]:removeAllItems()
		self.m_noUsedTiles[direction]   = {}
		self.m_handTiles[direction]     = {}
	end
	self.m_action        = HandTileAction.HandTileAction_Invalid -- 牌的动作
	self.m_state         = HandTileState.HandTileState_Invalid
	
	self.m_dispatching   = false --是否在发牌中...
	self.m_operating     = false --是否在操作
	self.m_curTouchTile  = nil	--当前选中的牌
	self.m_endTouchTile  = nil	--记录玩家结束按牌时按的牌 用于快速定位到出牌
end

-- 无关乎显示，只是单纯的将应该显示的顺序排下来
function HandTile:sort(tiles,_auto)

    local function _sort(a,b)
    	if a.m_isDraw then
    		return false
    	end

    	if a.m_lockType ==  b.m_lockType then
    		return a.m_eTile < b.m_eTile
   		else
   			return a.m_lockType > b.m_lockType
    	end
    	return false
    end
    table.sort(tiles,_sort)
	return tiles
end

function HandTile:getDrawTile(direction)
	local tiles = self.m_handTiles[direction]
	if not tiles then tiles = {} end

	--先检查是否含有缺门
	for _, v in pairs(tiles) do
		if v.m_isDraw then
			return v
		end
	end
	return nil
end

--过去最后一个麻将牌
function HandTile:getLastTile( direction )
	local tiles = self.m_handTiles[direction]
	if not tiles then 
		return nil 
	end
	tile = tiles[#tiles]
	return tile
end

-- 打出牌
function HandTile:beDoOutTile()
	if self.m_operating then return end

	--如果是听牌
	if self.m_action == HandTileAction.HandTileAction_TingTile then
		self.m_action = HandTileAction.HandTileAction_TingThrowTile
	elseif self.m_action == HandTileAction.HandTileAction_Tinged then --已经听牌 自动打牌

		self.m_endTouchTile  = self:getDrawTile(TileDirection.Direction_Bottom)
	else
		self.m_action = HandTileAction.HandTileAction_Invalid
	end
	if self.m_endTouchTile then
		local x , y = self.m_endTouchTile:getPosition()
		if self.m_Tipoving then
			x,y = self.m_tileTip:getPosition()
			self.m_Tipoving = false
		end
		self.step.x = x
		self.step.y = y
		--self:onOutTile(self.m_endTouchTile)
		self:outMid()
	end
end

--更换手牌样式
function HandTile:onTablestyle()
    for _,direction  in pairs(TileDirection) do
        local tiles = self.m_handTiles[direction]
        for k, v in pairs(tiles) do
            v:onTablestyle()
        end
    end
    self.m_tileTip:onTablestyle()
end

--预加载手牌
function HandTile:perInitTiles()
	for i = 1,56 do
        local tile   = Tile.new(TileDefine.eTile.Tile_Wan_1,TileDirection.Direction_Bottom)
        tile:addTo(self)
        tile:setVisible(false)
        self.m_perTiles[ #self.m_perTiles + 1 ] = tile
    end
end

--牌值排序
function HandTile:sortTileValue()
	--发牌中
	if self.m_dispatching then
		return
	end
  	--指排手中的卡牌
	local hands = self.m_handTiles[TileDirection.Direction_Bottom]
	--缺门
	self:checkQueMen()
	--排序
	self:sort(hands)
end
-------------------out---------------------------

--当牌被选中
function HandTile:onTileSelected(tile)
end

--取消选中
function HandTile:onTileUnSelected(tile)
end

---向服务发送打牌
function HandTile:onOutTile(tile)
end

return HandTile