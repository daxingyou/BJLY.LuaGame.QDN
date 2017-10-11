
--[[
    --创建房间
]]--

local JinPingRule = class("JinPingRule", function()
    return display.newNode()
end)
function JinPingRule:ctor()

    self:load_ccb()
    self:initUI() 
end
 --初始化ui
function JinPingRule:initUI()
  self.tb = {}
   --天柱默认闷杠
  local round_num = g_LocalDB:read("roundnum_jp")
  if round_num == 4 then
      self:onRoundSelected(self.m_ccbRoot.m_4round_button)
  else
      self:onRoundSelected(self.m_ccbRoot.m_8round_button)
  end

  local  numOfPlayer = g_LocalDB:read("numofplayer_jp")
  if numOfPlayer == 4 then
      self:onNumCheck(self.m_ccbRoot.m_siren_button)
  elseif numOfPlayer == 3  then
      self:onNumCheck(self.m_ccbRoot.m_sanren_button)
  elseif numOfPlayer == 2  then
      self:onNumCheck(self.m_ccbRoot.m_2ren_button) 
  end

  local ismengang = g_LocalDB:read("ismengangmulti2_jp")
  if ismengang == 1 then
      self:onJinPingMenGangCheck(self.m_ccbRoot.button_mengang_jinping)
  else
      self:onJinPingMenGangCheck(self.m_ccbRoot.button_zigang_jinping)
  end
  if g_GameConfig.isiOSAppCheck then
      self.m_ccbRoot.m_diamond1:setVisible(false)
      self.m_ccbRoot.m_diamond2:setVisible(false)
      self.m_ccbRoot.m_2:setVisible(false)
      self.m_ccbRoot.m_3:setVisible(false)
  end

  local liangfang = g_LocalDB:read("isliangfang_jp")
  print("liangfang =",liangfang)
  self.m_ccbRoot.m_liangfangSelected:setTag(liangfang)
  self.m_ccbRoot.m_liangfangSelected:setSpriteFrame(liangfang== 0 and "commonccz_unselected.png" or "commonccz_selected.png")
  if numOfPlayer == 4 then
    self.m_ccbRoot.m_liangfangSelected:setSpriteFrame("commonccz_disable.png")
  end
  self.tb.isliangfang = liangfang
end

function JinPingRule:load_ccb()
    self.m_ccbRoot = 
    {
      --人数选着
      ["onNumCheck"]            = function(_sender, _event) self:onNumCheck(_sender, _event) end,
      --局数选择
      ["onRoundSelected"]       = function(_sender, _event) self:onRoundSelected(_sender, _event) end,
      --补差价
      ["onJinPingMenGangCheck"] = function(_sender, _event) self:onJinPingMenGangCheck(_sender, _event) end,
      ["onNumSelected"]      = function(_sender, _event) self:onNumSelected(_sender, _event) end,
    }
    local proxy = cc.CCBProxy:create()
    local node  =  CCBReaderLoad("ccb/JinPingRule.ccbi", proxy, self.m_ccbRoot)
    node:addTo(self)
end

--人数点击
function JinPingRule:onNumCheck(_sender, _event)
    local ccb   = self.m_ccbRoot
    local portion    = _sender:getTag()
     if self.tb.numofplayer ==  portion then
      return
    end
    

    self.m_ccbRoot.m_1_check:setSpriteFrame("commonccz_uncheked.png")
    self.m_ccbRoot.m_2_check:setSpriteFrame("commonccz_uncheked.png")
    self.m_ccbRoot.m_3_check:setSpriteFrame("commonccz_uncheked.png")

    self.m_ccbRoot.m_1_check:setSpriteFrame(portion == 4 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_2_check:setSpriteFrame(portion == 3 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_3_check:setSpriteFrame(portion == 2 and "commonccz_checked.png" or "commonccz_uncheked.png")
    
    self:setLiangFang(portion)
    self.tb.numofplayer = portion
    --保存人数
    g_LocalDB:save("numofplayer_jp",portion)
end

--设置颜色
function JinPingRule:setLiangFang(numOfPlayer)
    local color  = numOfPlayer == 4 and cc.c3b(100,100,100) or cc.c3b(100,54,30)
    self.m_ccbRoot.m_liangfang_txt:setColor(color)
    if numOfPlayer == 4 then
        self.m_ccbRoot.m_2fang_button:setEnabled(false)
        self.m_ccbRoot.m_2fang_button:setTag(0)
        self.m_ccbRoot.m_liangfangSelected:setSpriteFrame("commonccz_disable.png")
        g_LocalDB:save("isliangfang_jp",0)
        self.tb.isliangfang = 0
    else
        if  self.tb.numofplayer == 4 then
          self.m_ccbRoot.m_2fang_button:setEnabled(true)
          self.m_ccbRoot.m_liangfangSelected:setSpriteFrame("commonccz_unselected.png")
        end
    end
end

--局数选择
function JinPingRule:onRoundSelected( _sender, _event )
    local round = _sender:getTag()
    self.m_ccbRoot.m_4roundCheck:setSpriteFrame(round == 4 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_8roundCheck:setSpriteFrame(round == 8 and "commonccz_checked.png" or "commonccz_uncheked.png")
    g_LocalDB:save("roundnum_jp",round)
    self.tb.RoundLimit = round
end

function JinPingRule:onJinPingMenGangCheck(_sender,_event)
    self.tb.IsMenGangMulti2 = _sender:getTag()
    if _sender:getTag() == 1 then--闷杠
       self.m_ccbRoot.check_mengang_jinping:setSpriteFrame("commonccz_checked.png")
       self.m_ccbRoot.check_zigang_jinping:setSpriteFrame("commonccz_uncheked.png")
       g_LocalDB:save("ismengangmulti2_jp",1)
    else
       self.m_ccbRoot.check_mengang_jinping:setSpriteFrame("commonccz_uncheked.png")
       self.m_ccbRoot.check_zigang_jinping:setSpriteFrame("commonccz_checked.png")
       g_LocalDB:save("ismengangmulti2_jp",0)
    end
end

function JinPingRule:onNumSelected(_sender, _event)
    local ccb   = self.m_ccbRoot
    ccb.m_liangfangSelected:setSpriteFrame(_sender:getTag() == 1 and "commonccz_unselected.png" or "commonccz_selected.png")
    _sender:setTag(_sender:getTag() == 1 and 0 or 1)
    local tag = _sender:getTag()
    g_LocalDB:save("isliangfang_jp",tag)
    self.tb.isliangfang = tag
end

function JinPingRule:getRule()
  if self.tb.numofplayer == 4 then
      self.tb.PlayRule = 1
  elseif self.tb.numofplayer == 3 then
      if self.tb.isliangfang == 1 then
         self.tb.PlayRule = 4
      else
         self.tb.PlayRule = 2
      end
  elseif self.tb.numofplayer == 2 then
      if self.tb.isliangfang == 1 then
         self.tb.PlayRule = 5
      else
         self.tb.PlayRule = 3
      end        
  end
  self.tb.region = "jinping"
  return self.tb
end

return JinPingRule