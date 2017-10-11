--[[
    --  动画页面
]]--
local _fileAnimationNode = "csb/RoomView/AnimationNode.csb"
local AnimationNode = class("AnimationNode", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

function AnimationNode:ctor()
    self:initUI()
    self:regEvent()
end

function AnimationNode:onCleanup()
    self:unregEvent()
end

--注册事件
function AnimationNode:regEvent()
    --鸡状态变化
    g_msg:reg("AnimationNode", g_msgcmd.UI_Chicken_Change, handler(self, self.onChickenStatus))--玩家加入
    g_msg:reg("AnimationNode", g_msgcmd.DB_PLAY_OPERATE_Result, handler(self, self.operateResult))
    g_msg:reg("AnimationNode", g_msgcmd.UI_MinglouBroadcast, handler(self, self.onTingStatus))
end

--注销事件
function AnimationNode:unregEvent()
    g_msg:unreg("AnimationNode", g_msgcmd.UI_Chicken_Change)
    g_msg:unreg("AnimationNode", g_msgcmd.DB_PLAY_OPERATE_Result)
    g_msg:unreg("AnimationNode", g_msgcmd.UI_MinglouBroadcast)
end

--初始化UI
function AnimationNode:initUI()
  
    display.addSpriteFrames("effect.plist","effect.pvr.ccz")
    local _UI = cc.uiloader:load(_fileAnimationNode)
    _UI:addTo(self)

    self.actions = {}
    for i = 1, 4 do
        temp = _UI:getChildByName("action_"..i)
        if temp then
            self.actions[i] = temp
            temp:setScale(0)
        end
    end
end

function AnimationNode:play(_uid,_code,_hu,_kong,_isZimo,_puid)
    local p = g_data.roomSys:getPlayerInfo(_uid)
    self.sex = 1
    if p then
        self.sex = p.sex
    end
  
    self.current = self.actions[p.direction]
    if self.current then
        self.current:setAnchorPoint(cc.p(0.6,0.49))
        self:playAnimation(_code,_hu,_kong,_isZimo)
    end
end

function AnimationNode:getSound( value )
    local lg = g_LocalDB:read("language_type")
    local _sound = nil
    if self.sex == 1 then --男
        if "normal" == lg then
            _sound = g_audioConfig.operate[value]["man_common"]
        else
            _sound = g_audioConfig.operate[value]["man_native"]
        end
    else
        if "normal" == lg then
            _sound = g_audioConfig.operate[value]["woman_common"]
        else
            _sound = g_audioConfig.operate[value]["woman_native"]
        end
    end

    if OperateType.Hu_DianPao == value then
        print("_sound ==",_sound)
    end
    
    return _sound
end

--播放动画
function AnimationNode:playAnimation(_code,_hu,_kong,_isZimo)
    local _AnimationTabel = {}  --动画播放列表
    local function _Animation(node,value)
        self.current:setSpriteFrame(OperateType.Animation_Res[value.path])

        local tb = {}

        --播放操作声音
        local action = cc.CallFunc:create(function()
                        local sound = self:getSound(value.path)
                        g_audio.playSound(sound)
                    end)
        table.insert(tb,action)
         
         --图片动画
        action = cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1.5))
        table.insert(tb,action)

        if self:isPongOrKong(_code) then
            action = cc.CallFunc:create(function()
                        self.current:setAnchorPoint(cc.p(0.5,0.5))
                        self.current:setSpriteFrame(OperateType.Animation_Res_2[value.path])
                    end)
            table.insert(tb,action)
        end

        action = cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 0.8))
        table.insert(tb,action)
       
        action= cc.DelayTime:create(0.3)
        table.insert(tb,action)
        action = cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 0))
        table.insert(tb,action)
        
        self.current:runAction(cc.Sequence:create(tb))
    end
    
    if _code == OperateType.Hu then
      if _kong and _kong > 0 then
          table.insert(_AnimationTabel,cc.CallFunc:create(_Animation,{path = _kong+200}))
          table.insert(_AnimationTabel,cc.DelayTime:create(0.8))
      else
        if _isZimo then
          table.insert(_AnimationTabel,cc.CallFunc:create(_Animation,{path = OperateType.Hu_TYPE_9}))
          table.insert(_AnimationTabel,cc.DelayTime:create(0.5))
        else
          --点炮音效
          local action = cc.CallFunc:create(function()
                        local sound = self:getSound(OperateType.Hu_DianPao)
                        g_audio.playSound(sound)
                    end)
          table.insert(_AnimationTabel,action)
          table.insert(_AnimationTabel,cc.DelayTime:create(0.6))
        end
      end
      table.insert(_AnimationTabel,cc.CallFunc:create(_Animation,{path = _hu+100}))
    else
        table.insert(_AnimationTabel,cc.CallFunc:create(_Animation,{path = _code}))
    end
    self.current:stopAllActions()
    self.current:runAction(cc.Sequence:create(_AnimationTabel))
end

--冲锋鸡动画特殊处理
function AnimationNode:onChickenStatus( _msg )
    local p = g_data.roomSys:getPlayerInfo(_msg.data.uid)
    if p == nil then return end
    self.sex = p.sex
    if p.ChargeChicken then
        local ccb = self:runAnimation("ccb/chargeChicken.ccbi")
        local sound = self:getSound(OperateType.ChargeChicken)
        g_audio.playSound(sound)
        ccb:runAction(cc.Sequence:create({
                cc.DelayTime:create(1.5),
                cc.CallFunc:create(function() 
                    ccb:stopAllActions()
                    ccb:removeFromParent(true) 
                    end)
            }))
 
        -- self:play(_msg.data.uid,OperateType.ChargeChicken)
    elseif p.DutyChicken then
        local ccb = self:runAnimation("ccb/dutyChicken.ccbi")
        local sound = self:getSound(OperateType.DutyChicken)
        g_audio.playSound(sound)
        ccb:runAction(cc.Sequence:create({
                cc.DelayTime:create(1.5),
                cc.CallFunc:create(function() 
                    ccb:stopAllActions()
                    ccb:removeFromParent(true) 
                    end)
            }))
    end
end

--播放动画
function AnimationNode:playTing(_uid)
    local p = g_data.roomSys:getPlayerInfo(_uid)
    self.sex = p.sex
    self.current = self.actions[p.direction]
    self.current:setAnchorPoint(cc.p(0.6,0.49))
  
    self.current:setTexture(OperateType.Animation_Res[OperateType.Ready])

    local tb = {}

    --播放操作声音
    local action = cc.CallFunc:create(function()
                    local sound = self:getSound(OperateType.Ready)
                    g_audio.playSound(sound)
                end)
    table.insert(tb,action)
     
     --图片动画
    action = cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1.5))
    table.insert(tb,action)

    action = cc.CallFunc:create(function()
                    self.current:setAnchorPoint(cc.p(0.5,0.5))
                    self.current:setTexture(OperateType.Animation_Res_2[OperateType.Ready])
                end)
    table.insert(tb,action)

    action = cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 0.8))
    table.insert(tb,action)
   
    action= cc.DelayTime:create(0.3)
    table.insert(tb,action)
    action = cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 0))
    table.insert(tb,action)
    
    self.current:runAction(cc.Sequence:create(tb))
end

-- OperateType.pong          = 1 --碰
-- OperateType.Left_kong     = 2--左杠
-- OperateType.Right_kong    = 3
-- OperateType.Mid_kong      = 4
-- OperateType.Fill_kong     = 5--补杠
-- OperateType.Self_kong     = 6--暗杠
-- OperateType.Ready         = 7--听
-- OperateType.Hu            = 8--胡
-- OperateType.Left_pong     = 9 --左碰
-- OperateType.Mid_pong      = 10 --中碰
-- OperateType.Right_pong    = 11 
-- OperateType.ChargeChicken   = 12 --冲锋鸡
-- OperateType.DutyChicken   = 13 --


function AnimationNode:runAnimation(_file)
    local proxy = cc.CCBProxy:create()
    local node  =  CCBReaderLoad(_file, proxy, self.m_ccbRoot)
    node:addTo(self)
    return node
end


function AnimationNode:isPongOrKong(code)
    return    code ==OperateType.pong 
           or code ==OperateType.Left_pong 
           or code ==OperateType.Mid_pong 
           or code ==OperateType.Right_pong
           or code ==OperateType.Left_kong 
           or code ==OperateType.Right_kong 
           or code ==OperateType.Mid_kong 
           or code ==OperateType.Fill_kong 
           or code ==OperateType.Self_kong
end


--操作结果
function AnimationNode:operateResult(_msg)
    local op           = _msg.data.op
    local _uid         = op.operate_uid  --主碰
    local _puid        = op.provide_uid  --被碰
    local _code        = op.operate_code --(1碰，2左杠，3右杠，4对门杠，5补杠，6暗杠，7听，8胡，9左碰，10中碰，11右碰)
    local _dutyChicken = op.is_zerenji   --碰杠中是否有责任鸡   0 不是鸡，1责任鸡，2普通鸡
    local _huType      = op.hu_type      -- 胡类型(1平胡， 2大对子， 3七对， 4龙七对， 5清一色， 6清七对， 7清大对， 8青龙背)  
    local _kongType    = op.gang_type    --杠类型（1杠上花， 2杠上炮， 3枪杠胡)
    local _isZimo      = false
    
    if _dutyChicken ~= 1 then
        if _code == OperateType.Hu then
            _isZimo = _uid == _puid
        end
        self:play(_uid,_code,_huType,_kongType,_isZimo,_puid)
    end
end

function AnimationNode:onTingStatus( _msg )
    local _uid  = _msg.data.uid
    self:playTing(_uid)
end

return AnimationNode