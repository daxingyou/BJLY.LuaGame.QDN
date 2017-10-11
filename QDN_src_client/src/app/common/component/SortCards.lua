local CardDefine = require("app.common.component.CardDefine")
local SortCards = class("SortCards")


-- 手牌 排序相关
local ccb_width_fix 	= 42
local ccb_height_fix 	= 30
local mopai_fix 		= 10

--起始位置X
local DirectionBottomX 	= 300 --TODO 记得优化适配
--起始位置Y
local DirectionBottomY 	= 45

local shoupai_rightx 	= display.width-(180)
local shoupai_rightx2	= 100
local shoupai_righty	= 150

local shoupai_topx 		= display.width-400
local shoupai_topx2 	= 850
local shoupai_topy 		= display.height-(720-573)

local shoupai_leftx 	= 135
local shoupai_leftx2 	= 550
local shoupai_lefty 	= 550

local shoupai_auto_center = false
local shoupai_auto_right  = true  --居右显示
local display_width 	  = display.width
local display_height 	  = display.height

-- 已经出牌的 4个坐标定点
------(x1,y2)---------(x2,y2)-----
---------|				 |
---------|				 |
---------|				 |
---------|				 |
---------|				 |
---------|				 |
------(x1,y1)---------(x2,y1)------

local g_x1 = 300/960*display.width
local g_y1 = 242/640*display.height
local g_x2 = 612/960*display.width
local g_y2 = 420/640*display.height

-- 已经出牌换行的牌数
local trapNum = 8

function SortCards:ctor()
end

-- 无关乎显示，只是单纯的将应该显示的顺序排下来
function SortCards:sort(cards,_auto)

	local sort  = cards
	local mopai = nil
  	for k,v in pairs(sort) do
        if v.isMoPai then
        	mopai = v
        	table.remove(sort, k)
        end
    end
    
    local function mSort(a,b)
        return  a.cardEnum < b.cardEnum
    end
    table.sort(sort,mSort)

    if _auto then 
    	if mopai ~= nil then
			table.insert(sort,mopai)
		end
    	return sort
    end

    local sort2 = {}
    local ppos = 1
	for k,v in pairs(sort) do
        if v.canOperate == false then
        	table.insert(sort2,v)
        end
    end
    for k,v in pairs(sort) do
        if v.canOperate then
        	table.insert(sort2,v)
        end
    end

    if mopai ~= nil then
		table.insert(sort2,mopai)
	end
	return sort2
end

-- 玩家手牌的设置
function SortCards:sortBottom(cards)
	local startx = DirectionBottomX
	local starty = DirectionBottomY
	local x = startx
	local y = starty
	local fixWidth 	= 49*0.7
	local fixWidth2 = 98*0.7
	local fixHeight = 30
	local gangNum  	= 1
	local pengNum  	= 1
	local fixWidth3 = 8

	local width_without_mopai = nil

	for i=1,#cards do
		if cards[i].cardType == CardDefine.type.shoupai then
			-- 手牌的排序
			local rect = cards[i].cardNode:getBoundingBox()
			if cards[i].isMoPai then
				width_without_mopai = x - startx
				-- 这里最后一张，并且要一个间隔
				x = x+mopai_fix
				y = starty 
			
				cards[i].cardNode:setPosition(cc.p(x,y))

				x = x+fixWidth2
			else
				cards[i].cardNode:setPosition(cc.p(x,y))

				x = x+fixWidth2
			end

		end
		cards[i].cardNode:setLocalZOrder(500)
	end


	if shoupai_auto_right then
		if width_without_mopai == nil then width_without_mopai = x - startx end
		local wwidth = (display_width - width_without_mopai - 200)
		local fix = wwidth - startx
		for i=1,#cards do
			local xx = cards[i].cardNode:getPositionX()
			xx = xx + fix
			cards[i].cardNode:setPositionX(xx)
		end
	end
end

-- 玩家手牌的设置，这里不应该叫这名，以后再想
-- 为了方便以后看，分开函数处理吧
function SortCards:sortRight(cards)
	local startx = shoupai_rightx
	local starty = shoupai_righty
	local x = startx
	local y = starty
	local gangNum  	= 1
	local pengNum  	= 1
	local fixHeight = 45 * 0.5
	local fixHeight2 = 45  * 0.5
	local fixHeight3 = (45  * 0.5)/2

	if g_data.roomSys.UI_State == RoomDefine.UI_State.Video then
		 fixHeight = 65 * 0.5
	 	 fixHeight2 = 65  * 0.5
	 	 fixHeight3 = (65  * 0.5)/2
	end

	-- 这里ZOrder要递增
	local ZOrder = 400
	local height_without_mopai = nil
	-- 如果有碰，扛牌，起始点不同
	-- if cards[1].cardType ~= CardDefine.type.shoupai then
	-- 	y = shoupai_rightx2
	-- end

	for i=1,#cards do
		local needResetZOrder = true
		if cards[i].cardType == CardDefine.type.shoupai then
			-- 手牌的排序
			local x2 = x + 16
			local rect = cards[i].cardNode:getBoundingBox()
			if cards[i].isMoPai then
				-- 这里最后一张，并且要一个间隔
				height_without_mopai = y - shoupai_righty
				y = y + mopai_fix
				cards[i].cardNode:setPosition(cc.p(x2,y))
				y = y + fixHeight2
			else
				cards[i].cardNode:setPosition(cc.p(x2,y))
				y = y + fixHeight2
			end
		elseif cards[i].cardType == CardDefine.type.chupai then
			-- 这里不应该碰到这种类型，如果有，那么出错了
		elseif cards[i].cardType == CardDefine.type.shoupai2 then
			-- 最后的翻牌
			--local rect = cards[i].cardNode:getBoundingBox()
			cards[i].cardNode:setPosition(cc.p(x,y))
			y = y + fixHeight
		end
		ZOrder = ZOrder -1
		if needResetZOrder then
			cards[i].cardNode:setLocalZOrder(ZOrder)
		end
	end
	if shoupai_auto_center then
		if height_without_mopai == nil then height_without_mopai = y - starty end
		local hheight = (display_height - height_without_mopai)/2
		local fix = hheight - starty
		for i=1,#cards do
			local yy = cards[i].cardNode:getPositionY()
			yy = yy + fix
			cards[i].cardNode:setPositionY(yy)
		end
	end

	if shoupai_auto_right then
		if height_without_mopai == nil then height_without_mopai = y - starty end
		local hheight = display_height - height_without_mopai
		local fix = hheight - starty-100
		for i=1,#cards do
			local yy = cards[i].cardNode:getPositionY()
			yy = yy + fix
			cards[i].cardNode:setPositionY(yy)
		end
	end
end
-- 左 <========== 右
-- 玩家手牌的设置
function SortCards:sortTop(cards)
	local startx = shoupai_topx
	local starty = shoupai_topy
	local x = startx
	local y = starty
	local gangNum  	= 1
	local pengNum  	= 1
	local fixWidth   = 49*0.35
	local fixWidth2  = 98*0.35
	local fixWidth3  = 5
	local width_without_mopai = nil

	for i=1,#cards do
		--print("=================>", i, cards[i], CardDefine.type.shoupai)
		if cards[i].cardType == CardDefine.type.shoupai then
			-- 手牌的排序
			local rect = cards[i].cardNode:getBoundingBox()
			if cards[i].isMoPai then
				width_without_mopai = startx - x
				-- 这里最后一张，并且要一个间隔
				x = x-mopai_fix
				cards[i].cardNode:setPosition(cc.p(x,y))
				x = x-fixWidth2
			else
				cards[i].cardNode:setPosition(cc.p(x,y))
				x = x-fixWidth2
			end
		elseif cards[i].cardType == CardDefine.type.chupai then
			-- 这里不应该碰到这种类型，如果有，那么出错了
		elseif cards[i].cardType == CardDefine.type.shoupai2 then
			-- 最后的翻牌
			cards[i].cardNode:setPosition(cc.p(x,y))
			x = x-fixWidth		
		end
	end
	--自动居中
	if shoupai_auto_center then
		if width_without_mopai == nil then width_without_mopai = startx - x end
		local wwidth = (display_width - width_without_mopai)/2
		local fix = width_without_mopai + wwidth - startx - fixWidth2
		for i=1,#cards do
			local xx = cards[i].cardNode:getPositionX()
			xx = xx + fix
			cards[i].cardNode:setPositionX(xx)
		end
	end

	if shoupai_auto_right then
		if width_without_mopai == nil then width_without_mopai = startx - x  end
		local wwidth = display_width - startx
		local fix =  startx-width_without_mopai -wwidth + fixWidth2
		for i=1,#cards do
			local xx = cards[i].cardNode:getPositionX()
			xx = xx - fix
			cards[i].cardNode:setPositionX(xx)
		end
	end
end

-- 玩家手牌的设置，这里不应该叫这名，以后再想
-- 为了方便以后看，分开函数处理吧
function SortCards:sortLeft(cards)
	local startx = shoupai_leftx
	local starty = shoupai_lefty
	local x = startx
	local y = starty
	local gangNum  	= 1
	local pengNum  	= 1
	local fixHeight = 45 * 0.5
	local fixHeight2 = 45  * 0.5
	local fixHeight3 = (45  * 0.5)/2

	if g_data.roomSys.UI_State == RoomDefine.UI_State.Video then
		 fixHeight = 65 * 0.5
	 	 fixHeight2 = 65  * 0.5
	 	 fixHeight3 = (65  * 0.5)/2
	end

	local height_without_mopai = nil
	-- 这里ZOrder要递增
	local ZOrder = 400
	for i=1,#cards do
		local needResetZOrder = true
		if cards[i].cardType == CardDefine.type.shoupai then
			-- 手牌的排序
			local x2 = x + 16
			local rect = cards[i].cardNode:getBoundingBox()
			if cards[i].isMoPai then
				height_without_mopai = starty - y
				-- 这里最后一张，并且要一个间隔
				y = y - mopai_fix
				cards[i].cardNode:setPosition(cc.p(x2,y))
				y = y - fixHeight2
			else
				cards[i].cardNode:setPosition(cc.p(x2,y))
				y = y - fixHeight2
			end
		elseif cards[i].cardType == CardDefine.type.chupai then
			-- 这里不应该碰到这种类型，如果有，那么出错了
		elseif cards[i].cardType == CardDefine.type.shoupai2 then
			-- 最后的翻牌
			--local rect = cards[i].cardNode:getBoundingBox()
			cards[i].cardNode:setPosition(cc.p(x,y))
			y = y - fixHeight
		end
		ZOrder = ZOrder +1
		if needResetZOrder then
			cards[i].cardNode:setLocalZOrder(ZOrder)
		end
	end
	if shoupai_auto_center then
		if height_without_mopai == nil then height_without_mopai = starty - y end
		local hheight = (display_height - height_without_mopai)/2
		local fix = height_without_mopai + hheight - starty - fixHeight2
		for i=1,#cards do
			local yy = cards[i].cardNode:getPositionY()
			yy = yy + fix
			cards[i].cardNode:setPositionY(yy)
		end
	end

	if shoupai_auto_right then
		if height_without_mopai == nil then height_without_mopai = starty - y end
		local hheight = display_height - height_without_mopai

		-- local fix = starty-height_without_mopai -hheight + fixHeight2
		local fix = height_without_mopai - starty + 165
		for i=1,#cards do
			local yy = cards[i].cardNode:getPositionY()
			yy = yy + fix
			cards[i].cardNode:setPositionY(yy)
		end
	end
end

return SortCards