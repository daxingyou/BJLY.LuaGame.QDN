--[[
	UIListView
	用法示例
	local listView=require("lib.ui.UIListView").new({
        data=tempdata,
        config={
            ccbFile="ListNode.ccbi",
            layerBg=self.m_ccbRoot.m_layerListBg,
            callfunc=callFunc
            }
        })
    listView:setListen(function(_event,_data)
            if _event=="ON_CLICK" then
                --_data.listView:removeItem(_data.item,true)
            end
        end)
]]

local UIListView = class("UIListView", function()
    local node=display.newNode()
    return node
end)
local OFFSET_ITEM_WIDTH=2
local OFFSET_ITEM_HEIGHT=2
--函数事件，监听方使用
local ccbFunEvent = {
    "ON_CLICK"
}
--传入数据和配置
function UIListView:ctor(_cfg)
	self:initData(_cfg)
	self:initUI()
end
function UIListView:initData(_cfg)
	self.m_ccbRoot={}
	self.m_ccbNode={}
	self.m_btnListen = nil
	self.m_selData=nil
	if not _cfg then return end
	self.m_data=_cfg.data
	self.m_config=_cfg.config
	self.m_callfunc=self.m_config.callfunc
	self.m_layerBg=self.m_config.layerBg
	self.m_bgColor=self.m_config.bgColor
	self.m_bgImg=self.m_config.bgImg
	self.m_bgScale9=self.m_config.bgScale9
	self.m_direction=self.m_config.direction or cc.ui.UIScrollView.DIRECTION_VERTICAL
	self.m_alignment=self.m_config.alignment or cc.ui.UIListView.ALIGNMENT_CENTER
	self.m_offsetWidth=self.m_config.offsetWidth or OFFSET_ITEM_WIDTH
	self.m_offsetHeight=self.m_config.offsetHeight or OFFSET_ITEM_HEIGHT
	self.m_ccbFile=self.m_config.ccbFile
end

function UIListView:initUI()
	self:setItemWidthHeight()
    self.m_layerSize = self.m_layerBg:getContentSize()
    local width=self.m_layerSize.width
    local height=self.m_layerSize.height
    self.ulv = cc.ui.UIListView.new {
        bgColor = self.m_bgScale9,
        bg = self.m_bgImg,
        bgScale9 = self.m_bgScale9,
        viewRect = cc.rect(0, 0, width, height),
        direction = self.m_direction,
        alignment=self.m_alignment
        }
        :onTouch(handler(self, self.touchListener))
        :addTo(self)
        self:addTo(self.m_layerBg)
    self:update()
end

function UIListView:setItemWidthHeight()
    local proxy = cc.CCBProxy:create()
    local ccbRoot={}
    local ccbNode = CCBReaderLoad(self.m_ccbFile, proxy, ccbRoot)
	local contentSize = ccbRoot.m_spritebg:getContentSize()
    self.m_itemWidth=contentSize.width+self.m_offsetWidth
    self.m_itemHeight=contentSize.height+self.m_offsetHeight
end
function UIListView:update()
	if self.ulv then
        self.ulv:removeAllItems()
    end
    self.m_ccbRoot={}
	self.m_ccbNode={}
	for k,v in pairs(self.m_data) do
        if type(k)~="number" then
            break
        end
        local item = self.ulv:newItem()
        local proxy = cc.CCBProxy:create()
        self.m_ccbRoot[k]={}
        self.m_ccbNode[k] = CCBReaderLoad(self.m_ccbFile, proxy, self.m_ccbRoot[k])
        -- local contentSize=self.m_ccbNode[k]:getCascadeBoundingBox()
        -- for k,v in pairs(contentSize) do
        --     print(k,v)
        -- end
        self:setUI(self.m_ccbRoot[k],v)
        item:addContent(self.m_ccbRoot[k].m_spritebg)
        item:setItemSize(self.m_layerSize.width, self.m_itemHeight)
        print(k)
        self.ulv:addItem(item,k)
    end
    self.ulv:reload()
end
function UIListView:setUI(_ccbRoot,_value)
	if self.m_callfunc~=nil then
		self.m_callfunc(_ccbRoot,_value)
	end
end

function UIListView:touchListener(_event)
    local listView = _event.listView
    local item=_event.item
    if "clicked" == _event.name then
    	self:onClick(_event)
        --listView:removeItem(event.item, true)
    elseif "moved" == _event.name then
        --self.bListViewMove = true
    elseif "ended" == _event.name then
        --self.bListViewMove = false
    else
        print("_event name:" .. _event.name)
    end
end
function UIListView:onClick(_event)
	local listView = _event.listView
    local item=_event.item
    --local tag=item:getTag()
    local tag=listView:getItemPos(item)
    local data={}
    data.listView=listView
    data.item=item
    data.tag=tag
    data.root=self.m_ccbRoot[tag]
    data.value=self.m_data[tag]
    if self.m_btnListen then
    	self.m_btnListen(ccbFunEvent[1],data)
	end
	self:insertData(data.value,tag)
end
--得到当前选中的数据
function UIListView:getSelData()
	return self.m_selData
end
--插入当前click的数据
function UIListView:insertData(_data,_tag)
	if not self.m_selData then
		self.m_selData={}
		table.insert(self.m_selData,_tag,_data)
	else
		local ins = 1
		for k,v in pairs(self.m_selData) do
			if k==_tag then
				ins=0
				break
			end
		end
		if ins==1 then
			table.insert(self.m_selData,_tag,_data)
		end
	end
	--table.sort(self.m_selData)
end
--设置回调方法
function UIListView:setListen(_fun)
    self.m_btnListen = _fun
end
return UIListView
