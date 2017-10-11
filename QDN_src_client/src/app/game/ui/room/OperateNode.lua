--[[
    --玩家操作页面 吃 碰 杠 胡
    --只对玩家自己操作
]]--

local ccbfile = "ccb/operate.ccbi"
local OperateNode = class("OperateNode", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function OperateNode:ctor()
    self:initUI()
    self:unlock()
    self.detail    = {}
    self.detail[1] = self.m_ccbRoot.m_item1
    self.detail[2] = self.m_ccbRoot.m_item2
    self.detail[3] = self.m_ccbRoot.m_item3

    self.m_ccbRoot.m_item1:getChildByTag(30):setName("button")
    self.m_ccbRoot.m_item2:getChildByTag(30):setName("button")
    self.m_ccbRoot.m_item3:getChildByTag(30):setName("button")

    self:regEvent()
end

function OperateNode:onCleanup()
    self:unregEvent()
end

--注册事件
function OperateNode:regEvent()
      --玩家加入
    g_msg:reg("OperateNode", g_msgcmd.DB_PLAY_OPERATE_ASK, handler(self, self.operate))
    g_msg:reg("OperateNode", g_msgcmd.DB_PLAY_OPERATE_Result, handler(self, self.finish))
    g_msg:reg("OperateNode", g_msgcmd.DB_PLAY_OPERATE_Pass, handler(self, self.hideButtons))
    g_msg:reg("OperateNode", g_msgcmd.UI_MinglouAsk, handler(self, self.hideButtons))
    g_msg:reg("OperateNode", g_msgcmd.DB_PLAY_GAME_START, handler(self, self.hideButtons))    --游戏开始
end

--注销事件
function OperateNode:unregEvent()
    g_msg:unreg("OperateNode", g_msgcmd.DB_PLAY_OPERATE_ASK)
    g_msg:unreg("OperateNode", g_msgcmd.DB_PLAY_OPERATE_Result)
    g_msg:unreg("OperateNode", g_msgcmd.UI_MinglouAsk)
    g_msg:unreg("OperateNode", g_msgcmd.DB_PLAY_OPERATE_Pass)
    g_msg:unreg("OperateNode", g_msgcmd.DB_PLAY_GAME_START)
end

function OperateNode:load_ccb()
    self.m_ccbRoot = {
        ["hu"] = function(_sender, _event) self:onHu(_sender, _event) end,
        ["ting"] = function(_sender, _event) self:onTing(_sender, _event) end,
        ["kong"] = function(_sender, _event) self:onKong(_sender, _event) end,
        ["pong"] = function(_sender, _event) self:onPong(_sender, _event) end,
        ["pass"] = function(_sender, _event) self:onPass(_sender, _event) end,
        ["onKongClick"] = function(_sender, _event) self:onKongClick(_sender, _event) end,
    }
    local proxy = cc.CCBProxy:create()
    local node  =  CCBReaderLoad(ccbfile, proxy, self.m_ccbRoot)
    node:addTo(self)
end


--操作
-- resume_uid //点击“过”之后，需要找到的焦点用户
-- action_card    //牌
-- actions   //动作数组(0无动作，1左吃（吃的牌在左边），2中吃，3右吃，4碰，5杠，6明搂，7胡)
-- gang_cards
function OperateNode:operate(_msg)
    local op= _msg.data.op

    local actions = op.actions
    if actions[1] == 0 then  
        return
    end
    
    self.action_card = op.action_card
    local resume_uid =  op.resume_uid
    self.gang_cards =  op.gang_cards

    self:addButton(CardDefine.operateType.Pass)
    for k,v in pairs(actions) do
         self:addButton(v)
    end
end

function OperateNode:initUI()
    self.buttons ={}
    self:load_ccb()
end

function OperateNode:addButton(_type)
    local ccb = self.m_ccbRoot
    local button = nil
    if _type == CardDefine.operateType.Pass then
        button = ccb.m_pass
        button:setScale(0.8)
    elseif _type == CardDefine.operateType.Kong then
        button = ccb.m_kong
    elseif _type == CardDefine.operateType.Pong then
        button = ccb.m_pong
    elseif _type == CardDefine.operateType.Hu then
        button = ccb.m_hu
        button:setScale(1.2)
    elseif _type == CardDefine.operateType.Ready then
        button = ccb.m_ting
    end
    -- button:setVisible(true)
    for i=1,#self.buttons do
        if self.buttons[i] == button then
            return
        end
    end
    self.buttons[#self.buttons+1] = button

    -- 这个坐标是按钮的右侧
    -- 每排完一个减去自身的宽度，等待下一个按钮的设置
    local x = 800/960*display.width
    local y = 220
    local gap = 45
    for i=1,#self.buttons do
        local size = self.buttons[i]:getContentSize()
        self.buttons[i]:setPosition(cc.p(x-size.width/2, y))
        x = x - size.width - gap
    end
    self:performWithDelay(function()
        for i=1,#self.buttons do
            self.buttons[i]:setVisible(true)
        end
    end, g_data.roomSys.m_float)
    
end

--胡
function OperateNode:onHu(_sender, _event)
    g_utils.setButtonLockTime(_sender,1)
    
    g_netMgr:send(g_netcmd.MSG_OPERATE, { operate_code = 7 ,  operate_cardid =  self.action_card} , 0)
end

--听
function OperateNode:onTing(_sender, _event)
    g_utils.setButtonLockTime(_sender,1)

    g_netMgr:send(g_netcmd.MSG_MINGLOU_ASK, {} , 0)
end

--杠
function OperateNode:onKong(_sender, _event)
    g_utils.setButtonLockTime(_sender,1)

    if #self.gang_cards == 1 then
         g_netMgr:send(g_netcmd.MSG_OPERATE, { 
            operate_code = CardDefine.operateType.Kong ,  
            operate_cardid =  self.gang_cards[1]} , 0)
    else
        self:hideButtons()
        local temp = nil
        for k,v in pairs(self.gang_cards) do
            temp = self.detail[k]
            self:setDetail(temp,v)
        end
    end
end
--碰
function OperateNode:onPong(_sender, _event)
    g_utils.setButtonLockTime(_sender,1)

    g_netMgr:send(g_netcmd.MSG_OPERATE, { 
            operate_code = CardDefine.operateType.Pong ,  
            operate_cardid =  self.action_card} , 0)

end
--过
function OperateNode:onPass(_sender, _event)
    g_utils.setButtonLockTime(_sender,1)

    g_netMgr:send(g_netcmd.MSG_OPERATE, { operate_code = 0 ,  operate_cardid =  0} , 0)
end

function OperateNode:setDetail(item,_value)

    local button = item:getChildByName("button")
    local tile  = nil
    local child = nil 
    item:setVisible(true)
    button:setTag(_value)

    local card_bg = {
      "green_mj_bg1.png",
      "blue_mj_bg1.png"
    }
    local tablestyle = g_LocalDB:read("tablestyle")
    for i =1 ,4 do
        tile = item:getChildByTag(i)
        tile:setSpriteFrame(card_bg[tablestyle])
        tile:removeAllChildren()
        child = display.newSprite("#"..CardDefine.enum[_value][2])
        child:setAnchorPoint(cc.p(0.5,0.5))
        child:addTo(tile)
        child:setPosition(tile:getContentSize().width/2,tile:getContentSize().height/2+10)
    end
end

function OperateNode:onKongClick( _sender, _event )
    local value = _sender:getTag()
    g_netMgr:send(g_netcmd.MSG_OPERATE, {
                operate_code = CardDefine.operateType.Kong ,
                operate_cardid =  value} , 0)
    self:hideButtons()
end

--操作结果
function OperateNode:finish(_msg)
    if _msg then
        local op    = _msg.data.op
        local code  = op.operate_code
        local uid  = op.operate_uid

        if uid == g_data.userSys.UserID then
             self:hideButtons()
        end
    end
end

function OperateNode:hideButtons()
    for i=1,#self.buttons do
        self.buttons[i]:setVisible(false)
    end
    self.buttons = {}
    self.detail[1]:setVisible(false)
    self.detail[2]:setVisible(false)
    self.detail[3]:setVisible(false)
end


return OperateNode