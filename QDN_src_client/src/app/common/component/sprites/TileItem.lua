
local TileItem = class("TileItem", function()
    local node =  display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)


function TileItem:ctor(_file,_op,eTile,_direction)
  makeUIControl_(self)
  self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)
  self.index = g_data.cardSys:getIndex()
  self.direction = _direction
  self.m_eTile  = eTile
	
  self:load_ccb(_file)
	self:initUI(_op)

  self:onTablestyle()
  self:regEvent()
end

function TileItem:onCleanup()
    self:unregEvent()
end

--注册事件
function TileItem:regEvent()
    g_msg:reg(self.index, g_msgcmd.UI_Setting_Change, handler(self, self.onTablestyle))
end

--注销事件
function TileItem:unregEvent()
    g_msg:unreg(self.index, g_msgcmd.UI_Setting_Change)
end

function TileItem:onTablestyle()
  local tablestyle = g_LocalDB:read("tablestyle")
  local bg         = CardDefine.card_bg[self.direction][tablestyle]
  local bg_4_6     = CardDefine.card_bg_4_6[self.direction][tablestyle]
  local bg_kong    = CardDefine.card_bg_kong[self.direction][tablestyle]
  for i = 1,8 do
     if i==6 or i == 4 or i == 8 or i == 5 then
      self.child[i]:setSpriteFrame(bg_4_6)
    else
      self.child[i]:setSpriteFrame(bg)
    end

    if self.op == OperateType.Self_kong then
        if i == 1 or i == 2 or i == 3 then
          self.child[i]:setSpriteFrame(bg_kong)
        end
    end
  end
end

--加载ccbi
function TileItem:load_ccb(_file)
  self.m_ccbRoot = {}
  local proxy = cc.CCBProxy:create()
  local node  = CCBReaderLoad(_file, proxy, self.m_ccbRoot)
  node:addTo(self)

  self.child ={}
  self.ccps = {}
  for i = 1,8 do
    self.child[i] = self.m_ccbRoot["item_"..i]
    local x,y     = self.child[i]:getPosition()
    self.ccps[i]  = cc.p(x,y)
    local value   = self.child[i]:getChildByTag(30)
    value:setSpriteFrame(CardDefine.enum[self.m_eTile][2])
  end
end

function TileItem:initUI(op)
    self.heights = {27,27,27,35,0,35}
	  self.op = op
    local _child = self.child
    self:restPos()

    _child[1]:setVisible( op == OperateType.pong or
    					  op == OperateType.Left_pong or
    					  op == OperateType.Mid_pong or
    					  op == OperateType.Left_kong or
    					  op == OperateType.Right_kong or
    					  op == OperateType.Self_kong or 
    					  op == OperateType.Mid_kong or 
                op == OperateType.Fill_kong)

    _child[2]:setVisible(true)
    _child[3]:setVisible( op == OperateType.pong or
    					  op == OperateType.Right_pong or
    					  op == OperateType.Left_kong or
    					  op == OperateType.Right_kong or
    					  op == OperateType.Self_kong or
    					  op == OperateType.Mid_kong or
    					  op == OperateType.Fill_kong)
   
    _child[4]:setVisible( op == OperateType.Right_pong or
    					  op == OperateType.Right_kong)

    _child[5]:setVisible(op == OperateType.Mid_kong )
    
    _child[6]:setVisible( op == OperateType.Left_pong or
    					  op == OperateType.Left_kong)

    _child[7]:setVisible( op == OperateType.Fill_kong or 
    					  op == OperateType.Self_kong)
    _child[8]:setVisible( op == OperateType.Mid_pong)

    local _width  = 0
    local _height = 0 
    for k, v in pairs(_child) do
        if k == 1 or k == 2 or k == 3 or k == 4 or k == 6 then
            if v:isVisible() then
              _width   = _width  + v:getContentSize().width*v:getScaleX()
              _height  = _height + self.heights[k]
            end
        end
        if op == OperateType.Self_kong then
            if k == 1 or k == 2 or k == 3 then
              v:getChildByTag(30):setVisible(false)
            end
        end
    end
    if  self.direction == CardDefine.direction.bottom or self.direction ==  CardDefine.direction.top then
        _width  = _width + 10
    else
        _height = _height + 10
    end
    self.m_Width = _width
    self:setLayoutSize(_width, _height)
end

function TileItem:restPos()
  for k, v in pairs(self.child) do
    v:setPosition(self.ccps[k])
  end
end

function TileItem:setTileColor(color)
  for k, v in pairs(self.child) do
    v:setColor(color)
  end
end

return TileItem