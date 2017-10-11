
--[[
    --创建房间
]]--

local LiPingRule = class("LiPingRule", function()
    return display.newNode()
end)
function LiPingRule:ctor()

    self:load_ccb()
    self:initUI() 
end
 --初始化ui
function LiPingRule:initUI()
    self.tb = {}
    self.tb.region = "liping"

     --天柱默认闷杠
    local round_num = g_LocalDB:read("roundnum_lp")
    if round_num == 4 then
        self:onRoundSelected(self.m_ccbRoot.m_4round_button)
    else
        self:onRoundSelected(self.m_ccbRoot.m_8round_button)
    end

    local  numOfPlayer = g_LocalDB:read("numofplayer_lp")
    if numOfPlayer == 4 then
        self:onNumCheck(self.m_ccbRoot.m_siren_button)
    elseif numOfPlayer == 3  then
        self:onNumCheck(self.m_ccbRoot.m_sanren_button)
    elseif numOfPlayer == 2  then
        self:onNumCheck(self.m_ccbRoot.m_2ren_button) 
    end

    local  isdingmai = g_LocalDB:read("isdingmai_lp")
    self.m_ccbRoot.m_portion_button:setTag(isdingmai)
   
    if isdingmai == 1 then 
      self.m_ccbRoot.m_portionSelected:setSpriteFrame("commonccz_selected.png")
      local numOfdingmai = g_LocalDB:read("numofdingmai_lp")
      if numOfdingmai == 1 then
          self:onPortionCheck(self.m_ccbRoot.m_1portion_button)
      elseif numOfdingmai == 2 then
          self:onPortionCheck(self.m_ccbRoot.m_2portion_button)
      elseif numOfdingmai == 4 then
          self:onPortionCheck(self.m_ccbRoot.m_4portion_button)
      end
    else
      self.m_ccbRoot.m_portionSelected:setSpriteFrame("commonccz_unselected.png")
      self:onPortionCheck(self.m_ccbRoot.m_1portion_button)
    end
    self:setPortionColor()
    local isDeathLight = g_LocalDB:read("isdeathlight_lp")
    self.m_ccbRoot.m_lightSelected:setTag(isDeathLight)
    self.tb.DeathByLight = isDeathLight
    self.m_ccbRoot.m_lightSelected:setSpriteFrame(isDeathLight == 1 and "commonccz_selected.png" or "commonccz_unselected.png")


    local liangfang = g_LocalDB:read("isliangfang_lp")
    self.m_ccbRoot.m_liangfangSelected:setTag(liangfang)
    self.m_ccbRoot.m_liangfangSelected:setSpriteFrame(liangfang== 0 and "commonccz_unselected.png" or "commonccz_selected.png")
    if numOfPlayer == 4 then
      self.m_ccbRoot.m_liangfangSelected:setSpriteFrame("commonccz_disable.png")
    end
    self.tb.isliangfang = liangfang
    if g_GameConfig.isiOSAppCheck then
        self.m_ccbRoot.m_diamond1:setVisible(false)
        self.m_ccbRoot.m_diamond2:setVisible(false)
        self.m_ccbRoot.m_2:setVisible(false)
        self.m_ccbRoot.m_3:setVisible(false)
    end
end

function LiPingRule:load_ccb()
    self.m_ccbRoot = 
    {
      --人数选着
      ["onNumCheck"]      = function(_sender, _event) self:onNumCheck(_sender, _event) end,
      --局数选择
      ["onRoundSelected"] = function(_sender, _event) self:onRoundSelected(_sender, _event) end,

      ["onPortionSelected"]  = function(_sender, _event) self:onPortionSelected(_sender, _event) end,
      ["onPortionCheck"]     = function(_sender, _event) self:onPortionCheck(_sender, _event) end,
      ["onLightSelected"]    = function(_sender, _event) self:onLightSelected(_sender, _event) end,
      ["onNumSelected"]      = function(_sender, _event) self:onNumSelected(_sender, _event) end,
     
    }
    local proxy = cc.CCBProxy:create()
    local node  =  CCBReaderLoad("ccb/LiPingRule.ccbi", proxy, self.m_ccbRoot)
    node:addTo(self)
end

--人数点击
function LiPingRule:onNumCheck(_sender, _event)
    local ccb   = self.m_ccbRoot
    local roleCount    = _sender:getTag()
    if self.tb.numofplayer ==  roleCount then
      return
    end
    self.m_ccbRoot.m_1_check:setSpriteFrame("commonccz_uncheked.png")
    self.m_ccbRoot.m_2_check:setSpriteFrame("commonccz_uncheked.png")
    self.m_ccbRoot.m_3_check:setSpriteFrame("commonccz_uncheked.png")

    self.m_ccbRoot.m_1_check:setSpriteFrame(roleCount == 4 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_2_check:setSpriteFrame(roleCount == 3 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_3_check:setSpriteFrame(roleCount == 2 and "commonccz_checked.png" or "commonccz_uncheked.png")

    self:setLiangFang(roleCount)
    --保存人数
    g_LocalDB:save("numofplayer_lp",roleCount)
    self.tb.numofplayer = roleCount
end

--设置颜色
function LiPingRule:setLiangFang(numOfPlayer)
    local color  = numOfPlayer == 4 and cc.c3b(100,100,100) or cc.c3b(100,54,30)
    self.m_ccbRoot.m_liangfang_txt:setColor(color)
    if numOfPlayer == 4 then
        self.m_ccbRoot.m_2fang_button:setEnabled(false)
        self.m_ccbRoot.m_2fang_button:setTag(0)
        self.m_ccbRoot.m_liangfangSelected:setSpriteFrame("commonccz_disable.png")
        g_LocalDB:save("isliangfang_lp",0)
        self.tb.isliangfang = 0
    else
        if  self.tb.numofplayer == 4 then
          self.m_ccbRoot.m_2fang_button:setEnabled(true)
          self.m_ccbRoot.m_liangfangSelected:setSpriteFrame("commonccz_unselected.png")
        end
    end
end

--局数选择
function LiPingRule:onRoundSelected( _sender, _event )
    local round = _sender:getTag()
    self.m_ccbRoot.m_4roundCheck:setSpriteFrame(round == 4 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_8roundCheck:setSpriteFrame(round == 8 and "commonccz_checked.png" or "commonccz_uncheked.png")
    g_LocalDB:save("roundnum_lp",round)
    self.tb.RoundLimit = round
end

--订卖选择
function LiPingRule:onPortionSelected( _sender, _event )
    local isSelected = _sender:getTag()
    print("isselected",isSelected)
    _sender:setTag(isSelected == 1 and 0 or 1)
    self.m_ccbRoot.m_portionSelected:setSpriteFrame(isSelected == 1 and "commonccz_unselected.png" or "commonccz_selected.png")
    self:onPortionCheck(self.m_ccbRoot.m_1portion_button)
    self:setPortionColor()
    local tag = _sender:getTag()
    g_LocalDB:save("isdingmai_lp",_sender:getTag())
end

--订卖份数选择
function LiPingRule:onPortionCheck( _sender, _event )
    local ccb   = self.m_ccbRoot
    local portion    = _sender:getTag()
    local isSelected = ccb.m_portion_button:getTag()


  
    
    if isSelected == 0 then
        self.tb.Additional = 0
        return 
    end
    ccb.m_1portion:setSpriteFrame("commonccz_uncheked.png")
    ccb.m_2portion:setSpriteFrame("commonccz_uncheked.png")
    ccb.m_4portion:setSpriteFrame("commonccz_uncheked.png")
    
    self.tb.Additional  = portion
    print("portion =====",portion)
    ccb.m_1portion:setSpriteFrame(portion == 1 and "commonccz_checked.png" or "commonccz_uncheked.png")
    ccb.m_2portion:setSpriteFrame(portion == 2 and "commonccz_checked.png" or "commonccz_uncheked.png")
    ccb.m_4portion:setSpriteFrame(portion == 4 and "commonccz_checked.png" or "commonccz_uncheked.png")
    g_LocalDB:save("numofdingmai_lp",portion)
end
--设置颜色
function LiPingRule:setLiangFangColor(numOfPlayer)
    local color      = numOfPlayer == 4 and cc.c3b(100,100,100) or cc.c3b(100,54,30)
    local ccb   = self.m_ccbRoot
    ccb.m_liangfang_txt:setColor(color)
    if numOfPlayer == 4 then
        self.m_ccbRoot.m_2fang_button:setEnabled(false)
        self.m_ccbRoot.m_liangfangSelected:setSpriteFrame("commonccz_unselected.png")
    else
        self.m_ccbRoot.m_2fang_button:setEnabled(true)
    end
end
--设置颜色
function LiPingRule:setPortionColor()
    local isSelected = self.m_ccbRoot.m_portion_button:getTag()
    local color      = isSelected == 1 and cc.c3b(100,54,30) or cc.c3b(100,100,100)
    self.m_ccbRoot.m_1portionName:setColor(color)
    self.m_ccbRoot.m_2portionName:setColor(color)
    self.m_ccbRoot.m_4portionName:setColor(color)

    if isSelected == 0 then
      self.m_ccbRoot.m_1portion:setSpriteFrame("commonccz_checked_disable.png")
      self.m_ccbRoot.m_2portion:setSpriteFrame("commonccz_checked_disable.png")
      self.m_ccbRoot.m_4portion:setSpriteFrame("commonccz_checked_disable.png")
    end
      
end

function LiPingRule:onLightSelected( _sender, _event )
    local isSelected = _sender:getTag()
    _sender:setTag(isSelected == 1 and 0 or 1)
    self.m_ccbRoot.m_lightSelected:setSpriteFrame(isSelected == 1 and "commonccz_unselected.png" or "commonccz_selected.png")
    self.tb.DeathByLight  = _sender:getTag()
   g_LocalDB:save("isdeathlight_lp",_sender:getTag())
end

function LiPingRule:onNumSelected(_sender, _event)
    local ccb   = self.m_ccbRoot
    ccb.m_liangfangSelected:setSpriteFrame(_sender:getTag() == 1 and "commonccz_unselected.png" or "commonccz_selected.png")
    _sender:setTag(_sender:getTag() == 1 and 0 or 1)
    local tag = _sender:getTag()
    g_LocalDB:save("isliangfang_lp",tag)
    self.tb.isliangfang = tag
end

function LiPingRule:getRule()
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
  return self.tb
end

return LiPingRule