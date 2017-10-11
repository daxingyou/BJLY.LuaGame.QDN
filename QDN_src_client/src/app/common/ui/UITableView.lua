--[[--
	Lua版 tableview 1.0

	使用方法: (配合cellFile中的cell工作)

	目前只需要这2个参数
	local config={
	    viewSize  = CCSizeMake(w, h*7),    -- w,h:格子size,eg:*7表示viewsize为7个格子高
	    cellFile  = "tvs.billBoardCell",   -- 格子所在的lua文件
	    --以下3项,可以不带;不带的话设置为以下的默认值
	    fillOrder = kCCTableViewFillTopDown,
	    priority  = kCCMenuHandlerPriority + 1,

	    --格子所需要的数据
	    listener  = nil or function() end, -- 格子事件回调
	}
	self.tableview = require("lib.ui.tableView").new(config)    -- anchor point 0,0
	self.tableview:setPosition(ccp(size.width*0.25, size.height*0.3))
	self:addChild(self.tableview)

	如果有数据则更新table cell
	self.tableview:reloadData(10)
]]
local UITableView = class("UITableView", function()
		local node = display.newNode()
		-- local node = display.newColorLayer(cc.c4b(0,0,0,128))
		cc.GameObject.extend(node):addComponent("components.behavior.EventProtocol"):exportMethods()
    	node:setNodeEventEnabled(true)
    	return node
	end)

function UITableView:ctor(_config)
	-- self.m_cellTmp = require(_config.cellFile).new(_config)
	-- self.m_cellTmp:setVisible(false)
	-- self.m_cellTmp:addTo(self)

	self.m_config = _config
    self.m_count = 0

    --ccb cell判定
    if not self.m_config.cellSize and self.m_config.cellCCB then
        self.m_config.cellSize = self:getCCBCellSize()
    end

    self:init()
end

function UITableView:onCleanup()
	-- 通知cell进行一些清理工作,尤其是一些静态table数据
	self:dispatchEvent({name = "CALL_CELL_CLEAN"})
end

--初始化操作
function UITableView:init()
	local w = display.width
	local h = display.height
	local viewSize  = self.m_config.viewSize
    local direction = self.m_config.direction or cc.SCROLLVIEW_DIRECTION_VERTICAL
    local fillOrder = self.m_config.fillOrder or cc.TABLEVIEW_FILL_TOPDOWN

    local tv = cc.TableView:create(viewSize)
    --效果相当于把tableview窗体的anchorpoint转移到ccp(0,1)
    -- tv:setPosition(cc.p(0, -viewSize.height))
    tv:setDirection(direction)
    tv:setVerticalFillOrder(fillOrder)
    tv:setDelegate()
    --
    self:addChild(tv, 2, 2)
    self:setContentSize(viewSize)
    --
    self.m_tv = tv
    --registerScriptHandler functions must be before the reloadData function
    tv:registerScriptHandler(function(view) self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tv:registerScriptHandler(function(view) self:scrollViewDidZoom(view) end, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tv:registerScriptHandler(function(table,cell) self:tableCellTouched(table,cell) end, cc.TABLECELL_TOUCHED)
    tv:registerScriptHandler(function(table,idx) return self:cellSizeForTable(table,idx) end, cc.TABLECELL_SIZE_FOR_INDEX)
    tv:registerScriptHandler(function(table,idx) return self:tableCellAtIndex(table,idx) end, cc.TABLECELL_SIZE_AT_INDEX)
    tv:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function UITableView:scrollViewDidScroll(_view)
	-- print("UITableView:scrollViewDidScroll")
end

function UITableView:scrollViewDidZoom(_view)
	-- print("UITableView:scrollViewDidZoom")
end

function UITableView:tableCellTouched(_table, _cell)
	-- print("UITableView:tableCellTouched", _cell)
    if _cell then
        _cell:touchedCell()
    end
end

function UITableView:cellSizeForTable(_table, _idx)
	-- print("UITableView:cellSizeForTable", _idx)
    local size = self.m_config.cellSize
    local cell = self.m_tv:cellAtIndex(_idx+1)
    if cell then
        size = cell:getCellSize(_idx+1)
    end
    return size.height,size.width
end

function UITableView:numberOfCellsInTableView(_table)
	-- print("UITableView:numberOfCellsInTableView")
    return self.m_count
end

function UITableView:tableCellAtIndex(_table, _idx)--idx start from 0
    local cell = _table:dequeueCell()
    if not cell or not cell.class then
        -- print("create cell")
        cell = self:cellInit(_table,_idx)
    else
        -- print("update cell")
        cell:updateCell(_idx+1)
    end
    return cell
end

function UITableView:cellInit(_table,_idx)

    local  cell = require(self.m_config.cellFile).new(self.m_config)
    --添加获取父table
    cell["getTableView"] = function() return self.m_tv end
    --添加清理函数
    if cell.cleanupCell then
        self:addEventListener("CALL_CELL_CLEAN", handler(cell, cell.cleanupCell))
    end
    cell:initCell(_idx+1, _table)
    return cell
end
--[[--
	重写CCTableview的方法
	说明:重置tableview的data
	_count cell数量，也可以传数组表自动算长度
	_op: "STOP" or "BOTTOM" or nil
	STOP 表示不滑动 停止
	MOVE 移动到第几个格子 _moveIndex 索引
    BOTTOM 移动到最底部
]]
function UITableView:reloadData(_count, _op, _animate, _moveIndex)
    --[[
		1.insertCellAtIndex的参数是c++里的数组下标,从0开始
		2.调用顺序:insertCellAtIndex,numberOfCellsIntv,tableCellAtIndex,cellSizeForTable
		3.reloadData会自动排序,当添加新cell时调用
	]]
	-- print("UITableView:reloadData", _count, _op)
    local offset = self.m_tv:getContentOffset() --reload之前保存数据
    local offsetX, offsetY = 0, 0
    self.m_count = _count
    local count = self.m_count
    self.m_tv:reloadData()

    if not _op then --什么也不做

    elseif "STOP" == string.upper(_op) then --更新时位置停止不动
        local viewSizeW = self.m_config.viewSize.width
        local cellSizeW = self.m_config.cellSize.width
        local viewSizeH = self.m_config.viewSize.height
        local cellSizeH = self.m_config.cellSize.height
        local direction = self.m_tv:getDirection()
        local maxCountInViewSize = direction == cc.SCROLLVIEW_DIRECTION_VERTICAL and math.ceil(viewSizeH/cellSizeH) or math.ceil(viewSizeW/cellSizeW)
        print("maxCountInViewSize",maxCountInViewSize)
        print("self.m_count",self.m_count)
        printTable("offset",offset)
        if  maxCountInViewSize <= self.m_count then
            self.m_tv:setBounceable( false )
            self.m_tv:setContentOffset(offset ,false)
            self.m_tv:setBounceable( true )
        end

    elseif "MOVE" == string.upper(_op) and _moveIndex then --移动到指定格子(移动的格子保持第一位)
        -- 纵向没处理
        local viewSizeW = self.m_config.viewSize.width
        local cellSizeW = self.m_config.cellSize.width
        local viewSizeH = self.m_config.viewSize.height
        local cellSizeH = self.m_config.cellSize.height
        local direction = self.m_tv:getDirection()
        local maxCountInViewSize = direction == cc.SCROLLVIEW_DIRECTION_VERTICAL and math.ceil(viewSizeH/cellSizeH) or math.ceil(viewSizeW/cellSizeW)
        local restSize = direction == cc.SCROLLVIEW_DIRECTION_VERTICAL  and (maxCountInViewSize - viewSizeH/cellSizeH)*cellSizeH or (maxCountInViewSize - viewSizeW/cellSizeW)*cellSizeW
        -- print("格子个数:", maxCountInViewSize, viewSizeW/cellSizeW)
        local moveCnts  = _moveIndex > self.m_count and self.m_count or _moveIndex
        -- 格子个数少时不移位
        if  maxCountInViewSize <= self.m_count  then
            self.m_tv:setBounceable( false )

            if cc.SCROLLVIEW_DIRECTION_VERTICAL == direction then
                --偏移 = -table总高 + 可视高 + 移动格子数
                offsetY = -self.m_tv:getContentSize().height + viewSizeH + (cellSizeH * (moveCnts-1))
                -- print("offset", offset.x, offset.y, "OFF", offsetX, offsetY)
                -- >0 移动到最后，已经超过可移动范围
                offset.y = offsetY >= 0 and 0 or offsetY
            else
                offsetX = - self.m_tv:getContentSize().width  + self.m_config.cellSize.width*( self.m_count - ( moveCnts - maxCountInViewSize )  ) - restSize
                if  ( moveCnts >= maxCountInViewSize and offset.x >= offsetX ) or ( moveCnts < maxCountInViewSize and offset.x < offsetX ) then
                    offset.x = offsetX >= 0 and 0 or offsetX
                end
            end
            -- print("offset", offset.x, offset.y)
            self.m_tv:setContentOffset(offset, _animate)
            self.m_tv:setBounceable( true )
        end
    elseif "MOVE_HALF" == string.upper(_op) and _moveIndex then --移动到指定格子(移动的格子保持第一位)
        -- 纵向没处理
        local viewSizeW = self.m_config.viewSize.width
        local cellSizeW = self.m_config.cellSize.width
        local viewSizeH = self.m_config.viewSize.height
        local cellSizeH = self.m_config.cellSize.height
        local direction = self.m_tv:getDirection()
        local maxCountInViewSize = direction == cc.SCROLLVIEW_DIRECTION_VERTICAL and math.ceil(viewSizeH/cellSizeH) or math.ceil(viewSizeW/cellSizeW)
        local restSize = direction == cc.SCROLLVIEW_DIRECTION_VERTICAL  and (maxCountInViewSize - viewSizeH/cellSizeH)*cellSizeH or (maxCountInViewSize - viewSizeW/cellSizeW)*cellSizeW
        -- print("格子个数:", maxCountInViewSize, viewSizeW/cellSizeW)
        local moveCnts  = _moveIndex > self.m_count and self.m_count or _moveIndex
        -- 格子个数少时不移位
        if  maxCountInViewSize <= self.m_count  then
            self.m_tv:setBounceable( false )

            if cc.SCROLLVIEW_DIRECTION_VERTICAL == direction then
                --偏移 = -table总高 + 可视高 + 移动格子数
                offsetY = -self.m_tv:getContentSize().height + viewSizeH + (cellSizeH * (moveCnts-1))
                -- print("offset", offset.x, offset.y, "OFF", offsetX, offsetY)
                -- >0 移动到最后，已经超过可移动范围
                offset.y = offsetY >= 0 and 0 or offsetY-(cellSizeH/2)
            else
                offsetX = - self.m_tv:getContentSize().width  + self.m_config.cellSize.width*( self.m_count - ( moveCnts - maxCountInViewSize )  ) - restSize
                if  ( moveCnts >= maxCountInViewSize and offset.x >= offsetX ) or ( moveCnts < maxCountInViewSize and offset.x < offsetX ) then
                    offset.x = offsetX >= 0 and 0 or offsetX
                end
            end
            -- print("offset", offset.x, offset.y)
            self.m_tv:setContentOffset(offset, _animate)
            self.m_tv:setBounceable( true )
        end

     elseif "MOVE_HORIZONTAL" == string.upper(_op) and _moveIndex then --移动到指定格子(移动的格子保持第一位)
        -- 纵向没处理
        local viewSizeW = self.m_config.viewSize.width
        local cellSizeW = self.m_config.cellSize.width
        local viewSizeH = self.m_config.viewSize.height
        local cellSizeH = self.m_config.cellSize.height
        local direction = self.m_tv:getDirection()
        local maxCountInViewSize =  math.ceil(viewSizeW/cellSizeW)
        local restSize  = (maxCountInViewSize - viewSizeW/cellSizeW)*cellSizeW
        offset = cc.p(0,0)
         print("格子个数:", maxCountInViewSize, self.m_count)
        local moveCnts  = _moveIndex > self.m_count and self.m_count or _moveIndex
        -- 格子个数少时不移位
        if  maxCountInViewSize <= self.m_count  then
            self.m_tv:setBounceable( false )
            offsetX = -cellSizeW *(_moveIndex-1)
            local maxOffX =  (-cellSizeW*self.m_count)+viewSizeW
            --print("offsetoffsetoffsetoffset", offsetX, maxOffX, self.m_tv:getContentSize().width)
            if offsetX < maxOffX then
                offsetX = maxOffX
            end
            offset.x = offsetX
            --print("offset", offset.x, offset.y, "OFF", offsetX, offsetY)
            self.m_tv:setContentOffset(offset, _animate)
            self.m_tv:setBounceable( true )
        end

    elseif "BOTTOM" == string.upper(_op) then --更新后滑动到最后
        --[[
        	禁止tableview滑动
        	让格子到最后一页的位置
        	setBounceable 可以tableview自己控制offset是否越界的问题.,设置初始偏移完毕后要还原
        ]]
        local direction = self.m_tv:getDirection()
        if direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
            self.m_tv:setBounceable(false)
            offsetY = self.m_tv:getContentSize().height + self.m_config.viewSize.height
            -- 格子个数少时不移位
            offsetY = offsetY >= 0 and 0 or offsetY
            self.m_tv:setContentOffset(cc.p(0, offsetY), _animate)
            self.m_tv:setBounceable(true)
        else
            self.m_tv:setBounceable(false)
            offsetX = - self.m_tv:getContentSize().width + self.m_config.viewSize.width
            -- 格子个数少时不移位
            offsetX = offsetX >= 0 and 0 or offsetX
            self.m_tv:setContentOffset(cc.p(offsetX, 0), _animate)
            self.m_tv:setBounceable(true)
        end
    end

end

function UITableView:setOffsetPos(_pos,_hasAnimate)
    self.m_tv:setContentOffset(_pos, _hasAnimate)
    self.m_tv:setBounceable( true )
end  

function UITableView:getOffsetPos()
   return self.m_tv:getContentOffset()
end  

--设置tableview是否可以touch(是否可以滚动)
function UITableView:setTouchEnabled(_enabled)
    self.m_tv:setTouchEnabled(_enabled)
end

function UITableView:isTouchEnabled()
    return self.m_tv:isTouchEnabled()
end

--更新该更新的格子
function UITableView:updateCellAtIndex(_idx)
    self.m_tv:updateCellAtIndex(_idx)
end

--根据ccb获取格子大小
function UITableView:getCCBCellSize()
    local proxy = cc.CCBProxy:create()
    local ccbRoot = {}
    local ccbNode = CCBReaderLoad(self.m_config.cellCCB, proxy, ccbRoot)
    print("self.m_config.cellCCB"..self.m_config.cellCCB)
    printTable("ccbNode",ccbNode)
    printTable("ccbRoot",ccbRoot)
    local size = ccbRoot.m_spritebg:getContentSize()
    return size
end

return UITableView
