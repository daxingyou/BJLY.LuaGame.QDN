
--[[
    待完善
]]--

local BaseRule = class("BaseRule", function()
    return display.newNode()
end)
function BaseRule:ctor()
    self:initProperty()
    self:load_ccb()
    self:initUI() 
end

function BaseRule:initProperty()
  self.tb = {}
  self.m_ccbRoot = {}
  self.ccbfile = ""
end

 --初始化ui
function BaseRule:initUI()

    self.m_rules = g_LocalDB:read("rules")

    if self.m_rules.RoundLimit == 4 then
        self:onRoundSelected(self.m_ccbRoot.m_4round_button)
    else
        self:onRoundSelected(self.m_ccbRoot.m_8round_button)
    end

    if self.m_rules.count == 4 then
        self:onNumCheck(self.m_ccbRoot.m_siren_button)
    elseif self.m_rules.count == 3  then
        self:onNumCheck(self.m_ccbRoot.m_sanren_button)
    elseif self.m_rules.count == 2  then
        self:onNumCheck(self.m_ccbRoot.m_2ren_button) 
    end
end

function BaseRule:setRegion()
     self.tb.region = "liping"
end

function BaseRule:load_ccb()
    local proxy = cc.CCBProxy:create()
    local node  =  CCBReaderLoad(elf.ccbfile , proxy, self.m_ccbRoot)
    node:addTo(self)
end

--人数点击
function BaseRule:onPlayerCountSelected(_sender, _event)
    local ccb   = self.m_ccbRoot
    local count    = _sender:getTag()

    self.m_ccbRoot.m_1_check:setSpriteFrame("commonccz_uncheked.png")
    self.m_ccbRoot.m_2_check:setSpriteFrame("commonccz_uncheked.png")
    self.m_ccbRoot.m_3_check:setSpriteFrame("commonccz_uncheked.png")

    self.m_ccbRoot.m_1_check:setSpriteFrame(count == 4 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_2_check:setSpriteFrame(count == 3 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_3_check:setSpriteFrame(count == 2 and "commonccz_checked.png" or "commonccz_uncheked.png")

    self:setLiangFang(count)
    self.m_rules.count = count
end

--设置颜色
function BaseRule:setLiangFang( count )
    local color  = count == 4 and cc.c3b(100,100,100) or cc.c3b(100,54,30)
    self.m_ccbRoot.m_liangfang_txt:setColor(color)
    if count == 4 then
        self.m_ccbRoot.m_2fang_button:setEnabled(false)
        self.m_ccbRoot.m_liangfangSelected:setSpriteFrame("commonccz_unselected.png")
    else
        self.m_ccbRoot.m_2fang_button:setEnabled(true)
    end
end

--局数选择
function BaseRule:onRoundSelected( _sender, _event )
    local round = _sender:getTag()
    self.m_ccbRoot.m_4roundCheck:setSpriteFrame(round == 4 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_ccbRoot.m_8roundCheck:setSpriteFrame(round == 8 and "commonccz_checked.png" or "commonccz_uncheked.png")
    self.m_rules.RoundLimit = round
end

function BaseRule:onNumSelected(_sender, _event)
    local ccb   = self.m_ccbRoot
    ccb.m_liangfangSelected:setSpriteFrame(_sender:getTag() == 1 and "commonccz_unselected.png" or "commonccz_selected.png")
    _sender:setTag(_sender:getTag() == 1 and 0 or 1)
    local tag = _sender:getTag()
    self.m_rules.isliangfang = tag
end

function BaseRule:getRule()
  if self.m_rules.count == 4 then
      self.tb.PlayRule = 1
  elseif self.m_rules.count == 3 then
      self.m_rules.PlayRule = self.m_rules.isliangfang == 1 and 4 or 2
  elseif self.m_rules.count == 2 then
      self.m_rules.PlayRule = self.m_rules.isliangfang == 1 and 5 or 3
  end
  self:setRegion()
  return self.tb
end

return BaseRule