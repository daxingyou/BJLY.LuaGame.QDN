--[[
    --玩家操作页面
]]--
local _filePlayerIcon = "csb/RoomView/PlayerIcon.csb"
local PlayerIcon = class("PlayerIcon", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

function PlayerIcon:ctor()
    self.isReg = false
    self:initUI()
end

function PlayerIcon:updateReconnect()
    if self.m_info.QueMen ==nil or self.m_info.QueMen <1 then 
    else 
        self:setQueMenTexture()
        self.m_queMenSprite:setVisible(true)
        self.m_queMenSprite:stopAllActions()
        self.m_queMenSprite:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1.0)))
    end
    self:onChickenStatus()
end

function PlayerIcon:onCleanup()
    self:unregEvent()
end

--注册事件
function PlayerIcon:regEvent()
    self.isReg = true
    g_msg:reg(self.regKey, g_msgcmd.UI_Chicken_Change, handler(self, self.onChickenStatus))--玩家加入
    g_msg:reg(self.regKey, g_msgcmd.DB_PLAY_GAME_START, handler(self, self.onGameStar))    --游戏开始
    g_msg:reg(self.regKey, g_msgcmd.UI_Banker_Change, handler(self, self.onBankerStatus))    --庄家状态
    g_msg:reg(self.regKey, g_msgcmd.UI_DingQue_Success, handler(self, self.onDingQueStatus))    --定缺状态
    g_msg:reg(self.regKey, g_msgcmd.UI_BreakBroadcast, handler(self, self.onlineStatue))--掉线
    g_msg:reg(self.regKey, g_msgcmd.UI_ChatBroadcast, handler(self, self.onChatHandle))----表情聊天广播
    g_msg:reg(self.regKey, g_msgcmd.DB_ReadyBroadcast, handler(self, self.onReadyStatus))
    g_msg:reg(self.regKey, g_msgcmd.UI_ROUND_SCORE_State, handler(self, self.onScoreStatus))
    g_msg:reg(self.regKey, g_msgcmd.UI_VOICE_State, handler(self, self.setVoiceState))----表情聊天广播
    g_msg:reg(self.regKey, g_msgcmd.UI_DingQue_END, handler(self, self.onDingQueEnd))
    g_msg:reg(self.regKey, g_msgcmd.UI_MinglouBroadcast, handler(self, self.onTingStatus))

    g_http.listeners(self.regKey,
        handler(self, self.httpSuccess),
        handler(self, self.httpFail))
end

--注销事件
function PlayerIcon:unregEvent()
    if not self.isReg then return end
    self.isReg = false
    g_msg:unreg(self.regKey, g_msgcmd.UI_Chicken_Change)
    g_msg:unreg(self.regKey, g_msgcmd.DB_PLAY_GAME_START)
    g_msg:unreg(self.regKey, g_msgcmd.UI_Banker_Change)
    g_msg:unreg(self.regKey, g_msgcmd.UI_DingQue_Success)
    g_msg:unreg(self.regKey, g_msgcmd.UI_ChatBroadcast)
    g_msg:unreg(self.regKey, g_msgcmd.UI_BreakBroadcast)--掉线
    g_msg:unreg(self.regKey, g_msgcmd.UI_VOICE_State)
    g_msg:unreg(self.regKey, g_msgcmd.UI_ROUND_SCORE_State)
    g_msg:unreg(self.regKey, g_msgcmd.UI_DingQue_END)
    g_msg:unreg(self.regKey, g_msgcmd.UI_MinglouBroadcast)
    g_http.unlisteners(self.regKey)
end

--初始化UI
function PlayerIcon:initUI()
    self:setContentSize(cc.size(240, 240))
    local _UI = cc.uiloader:load(_filePlayerIcon)
    _UI:addTo(self)
    self:setAnchorPoint(cc.p(0.25,0.5))

    self.m_infoNode = _UI:getChildByName("m_Node")

    self.m_iconSprite      = self.m_infoNode:getChildByName("m_iconSprite")   --头像

    self.m_nickNameLabel   = self.m_infoNode:getChildByName("m_nickNameLabel") --昵称 
    self.m_score_bg        = self.m_infoNode:getChildByName("m_score_bg") --是否在线
    self.m_scoreLabel      = self.m_infoNode:getChildByName("m_scoreLabel")    --分数
    self.m_onlineSprite    = self.m_infoNode:getChildByName("m_onlineSprite") --是否在线

   

    self.m_isBankerSprite  = self.m_infoNode:getChildByName("m_isBankerSprite") --庄
    self.m_readySprite     = self.m_infoNode:getChildByName("m_readySprite") --是否准备
    -- self.m_readySprite:setScale(0.5)--准备的手太大 挡住右边上边的头像

    self.m_chickenSprite   = self.m_infoNode:getChildByName("m_chickenSprite") --冲锋鸡
    self.m_tingSprite      = self.m_infoNode:getChildByName("m_tingSprite") --听牌
    self.m_queMenSprite    = self.m_infoNode:getChildByName("m_queMenSprite") --缺门
    self.m_queMenSprite:setVisible(false)

    self.m_iconButton      = self.m_infoNode:getChildByName("m_iconButton")
    g_utils.setButtonClick(self.m_iconButton,handler(self,self.onInfoClick))
  
    self.m_emojiSprite     = self.m_infoNode:getChildByName("m_emojiSprite")
    self.m_chatPaoImg      = self.m_infoNode:getChildByName("Image_pao")
    self.m_chatTxt         = self.m_chatPaoImg:getChildByName("Text_chat")
    self.m_yuyinSprite     = self.m_chatPaoImg:getChildByName("Sprite_yuyin")

    -- self:initData()
end


function PlayerIcon:initData()
    self:unregEvent()
    self.regKey ="PlayerIcon"..self.m_info.uid
    self:regEvent()

    self.m_nickNameLabel:setString(self.m_info.weichat_nick)
    self.m_scoreLabel:setString(self.m_info.gold)

    self.sex = self.m_info.sex == 1 and 1 or 2
    self.uid     = self.m_info.uid
    self.seatid  = self.m_info.seatid
    self:unscheduleAll()
    --下载头像
    local intIcon = string.len(self.m_info.weichat_face_address)
    if intIcon > 3 then
        self:checkUpdateIcon()
    end

    --设置庄
    self:onBankerStatus()

    self.status = self.m_info.status
    --局中断线重连 暂时处理
    if  self.status == 5 then
         g_netMgr:send(g_netcmd.MSG_READY,{}, 0)
    end
    if self.m_info.direction == 2 then
        self.m_emojiSprite:setPosition(-120,22)
    end
    self:moveToPosition()
end

function PlayerIcon:onInfoClick()
  --已经初始化过了
  if self.m_info.jncnt_ok then
     g_SMG:addLayerByName(g_UILayer.Main.UISelfInfo.new({},self.uid))
  else
     g_netMgr:send(g_netcmd.MSG_GET_JU_CNT,{ uid = self.uid }, 0)
  end
end

--头像更新计时器，直到更新到头像后停止
function PlayerIcon:checkUpdateIcon()
    local iconName = string.format("%d.png",self.uid)
    local path =  device.writablePath..iconName
    if not cc.FileUtils:getInstance():isFileExist(path) then

        if self.m_iconSchedule == nil then
            g_http.Download(self.m_info.weichat_face_address,self.regKey,self.regKey,path) 
            self.m_iconSchedule = self:schedule(function() self:checkUpdateIcon() end, 1)
        end
    else
        if self.m_iconSchedule ~= nil then
            self:stopAction(self.m_iconSchedule)
            self.m_iconSchedule = nil
        end
        
        local node  = g_utils.setClip(path,self.m_iconSprite)
        return true
    end    
    return false
end

--停止
function PlayerIcon:unscheduleAll( )
  if self.m_iconSchedule ~= nil then
      self:stopAction(self.m_iconSchedule)
      self.m_iconSchedule = nil
  end
end

-- 移动到目标位置
function PlayerIcon:moveToPosition( )
    local height = display.height
    local width  = display.width
    local _pos   = nil
    if self.m_info.direction == CardDefine.direction.top then
        _pos = cc.p(width*0.8,height*0.91)
    elseif self.m_info.direction == CardDefine.direction.bottom then
        _pos = cc.p(width*0.06,height*0.35)
    elseif self.m_info.direction == CardDefine.direction.left then
        _pos = cc.p(width*0.06,height*0.6)
    elseif self.m_info.direction == CardDefine.direction.right then
       _pos = cc.p(width*0.94,height*0.65)
    end
    if _pos then
        self:setScale(0)
        self:setPosition(_pos)
        self:stopAllActions()
        self:runAction(cc.Sequence:create({
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1.2)),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 0.8)),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1.0))
            }))
    end
end

--http成功
function PlayerIcon:httpSuccess(response, _tag)
    print("PlayerIcon:httpSuccess")
    if not response then
        print("ERROR _response 没有数据")
        return
    end
    local ok = false
    for i=1,1 do
        self:saveDownloadDone(_tag,response)
        ok = true
    end
    --失败处理
    if not ok then
        self:httpFail({code="101", response=""}, _tag)
    end
end

function PlayerIcon:httpFail(response, _tag)
    print("httpFail", response, _tag)
end

--记录下载成功
function PlayerIcon:saveDownloadDone(name,content)
    io.writefile(device.writablePath .. name, content)
end

--离线
function PlayerIcon:onlineStatue(_msg)
    local _uid    = _msg.data.uid
    local _status = _msg.data.status
    if _uid == self.uid then
        self.m_onlineSprite:stopAllActions()
        self.m_onlineSprite:setVisible(_status ~= 1)
        if _status ~= 1 then
            local act = cc.Sequence:create({cc.ScaleTo:create(0.4,1.3),cc.ScaleTo:create(0.4,0.7)})
            self.m_onlineSprite:runAction(cc.RepeatForever:create(act))
        end
    end
end

--庄家
function PlayerIcon:onBankerStatus()
    self.m_isBankerSprite:setVisible(g_data.roomSys.banker_uid == self.uid)
end
--定缺
function PlayerIcon:onDingQueStatus(_msg)
    local _uid    = _msg.data.uid
    if self.uid ~= _uid then return end
    self:setQueMenTexture()
end

function PlayerIcon:setQueMenTexture()
    if self.m_info.QueMen ==nil or self.m_info.QueMen <1 then return end
    local tb = {"icon_wan.png","icon_tiao.png","icon_tong.png"}
    self.m_queMenSprite:setSpriteFrame(tb[self.m_info.QueMen])
end


--定缺结束 展示定缺图像
function PlayerIcon:onDingQueEnd(_msg)
    self.m_queMenSprite:setVisible(true)
    self.m_queMenSprite:stopAllActions()
    self.m_queMenSprite:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1.0)))
end

--游戏开始
function PlayerIcon:onGameStar()
    self.m_readySprite:setVisible(false)
    self.m_tingSprite:setVisible(false)
    self.m_info.QueMen = -1
end

--冲锋鸡
function PlayerIcon:onChickenStatus()
    self.m_chickenSprite:setVisible(false)
    if self.m_info.DutyChicken then
        self.m_chickenSprite:setSpriteFrame("icon_ze.png")
        self.m_chickenSprite:setVisible(true)
    elseif self.m_info.ChargeChicken then
         self.m_chickenSprite:setSpriteFrame("icon_chong.png")
        self.m_chickenSprite:setVisible(true)
    end
end

function PlayerIcon:runEmojiAnim(emojiIndex)
    self.m_emojiSprite:stopAllActions()
    self.m_emojiSprite:setVisible(true)
    local num = g_enumKey.Chat.emoji_num[emojiIndex]
    local frames = {}
    for i=0,num-1,1 do      
      local enoji_path = string.format("res/srcRes/RoomScene/Chat/Emoji/emoji_%d_%d.png",emojiIndex,i)
      local sprite = display.newSprite(enoji_path)
      if sprite then
        table.insert(frames,sprite:getSpriteFrame())
      end
    end
    local animation = display.newAnimation(frames,1/num)
    display.setAnimationCache("runEmojiAnim",animation)
    self.m_emojiSprite:playAnimationForever(display.getAnimationCache("runEmojiAnim"))
    local act1 = cc.CallFunc:create(function()
      self.m_emojiSprite:setVisible(false)
    end)

    if self.m_info.direction == CardDefine.direction.top then
          self.m_emojiSprite:setAnchorPoint(cc.p(1,1))
    end

    local act2 = cc.DelayTime:create(2)
    local seq = cc.Sequence:create(act2, act1)
    self.m_emojiSprite:runAction(seq)
end

function PlayerIcon:showChatTxt(_type,_chatTxtOrID)
    local chatStr = _chatTxtOrID
    if _type == 1 then
      chatStr = g_enumKey.Chat.comLanguage[_chatTxtOrID]
    end
    if chatStr then
      self.m_chatPaoImg:stopAllActions()
        if self.m_info.direction == CardDefine.direction.top or
         self.m_info.direction == CardDefine.direction.right then
          self.m_chatTxt:setAnchorPoint(cc.p(1,0.5))
          self.m_chatPaoImg:setFlippedX(true)
          self.m_chatTxt:setFlippedX(true)
        end

      self.m_chatTxt:setString(chatStr)
      self.m_chatPaoImg:setContentSize(cc.size(self.m_chatTxt:getContentSize().width + 70,66))
      self.m_yuyinSprite:setVisible(false) 
      self.m_chatTxt:setVisible(true)
      self.m_chatPaoImg:setVisible(true) 


      if _type == 1 then
        --播放语音
        local soundPath = "res/sound/msg_" .. _chatTxtOrID .."_man.mp3"
        if self.sex == 2 then
            soundPath = "res/sound/msg_" .. _chatTxtOrID .."_woman.mp3"
        end

        
        print("===soundPath===",soundPath)
        g_audio.playSound(soundPath)
      end
      local act1 = cc.CallFunc:create(function()
        self.m_chatTxt:setVisible(false)
        self.m_chatPaoImg:setVisible(false)
      end)
      local act2 = cc.DelayTime:create(3)
      local seq = cc.Sequence:create(act2, act1)
      self.m_chatPaoImg:runAction(seq)   
    end
end

--聊天
function PlayerIcon:onChatHandle(_msg)
    local _data   = _msg.data
    local _uid    = _msg.data.uid
    local _data   = _msg.data
    if self.uid ~= _uid then return end
    if _data._type == 1 then --表情聊天
        local _id = _data.chat_index - 100
        if _id < 100 then --表情图片
            self:runEmojiAnim(_id)
        else--表情常用语
            _id = _id - 100
            self:showChatTxt(1,_id)
        end
    else--自定义聊天
        local content = _data.chat_content
        self:showChatTxt(2,content)
    end
end

--设置是否在说话
function PlayerIcon:setVoiceState( _msg )
    local memberid  = _msg.data.memberid
    local _state    = _msg.data.member_status
    if self.m_info == nil then return end
    if tostring(memberid) ~= tostring(self.m_info.member_id) then return end
    print("_state====",_state)
    if _state == 0 then--停止说话
        self.m_chatPaoImg:setVisible(false)
        self.m_chatTxt:setVisible(false)
        self.m_yuyinSprite:setVisible(false)
        self.m_yuyinSprite:stopAllActions()
        g_audio.resumeMusic()
    elseif  _state == 2 then --正在说话
        self.m_chatPaoImg:setVisible(true)
        self.m_chatTxt:setVisible(false)
        self.m_yuyinSprite:setVisible(true)
        self:playYuYinAnim(self.m_yuyinSprite)
        self.m_chatPaoImg:setContentSize(cc.size(120,63))
        g_audio.pauseMusic()
    end 
end

--准备
function PlayerIcon:onReadyStatus(_msg)
    local _uid  = _msg.data.uid
    if self.uid == _uid then
        self.m_readySprite:setScale(0)
        self.m_readySprite:setVisible(true)
        --根据头像位置设置不同的位置
        if self.m_info.direction == 3 then--对门的
            self.m_readySprite:setPosition(50,10)
        end
        self.m_readySprite:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 0.6)))
    end
    --TODO
    if self.m_chickenSprite then
        self.m_chickenSprite:setVisible(false)
    end
    if self.m_queMenSprite then
        self.m_queMenSprite:setVisible(false)
    end
end

--听牌
function PlayerIcon:onTingStatus( _msg )
    local _uid  = _msg.data.uid
    if self.uid == _uid then
        self:setTingTexture()
    end
end

function PlayerIcon:setTingTexture()
    self.m_tingSprite:setScale(0)
    self.m_tingSprite:setVisible(true)
    local  data = {}
    data.uid = self.uid
    data.isTingPai = true 
    g_data.roomSys:updatePlyerInfo(data)
    self.m_tingSprite:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1)))
end

--分数变化
function PlayerIcon:onScoreStatus(  )
    self.m_scoreLabel:setString(self.m_info.score)
end

function PlayerIcon:playYuYinAnim(spriteCtl)
    if spriteCtl:numberOfRunningActions() > 0 then
        return
    end
    local frames = {}
    for i=1,4 do
        local path = "srcRes/RoomScene/Chat/Voice/" .. (i-1) .. ".png"
        local sprite = display.newSprite(path)
        local frame = sprite:getSpriteFrame()
        table.insert(frames,frame)
    end
    local anim = display.newAnimation(frames,1.5/4)
    spriteCtl:playAnimationForever(anim)
end

return PlayerIcon