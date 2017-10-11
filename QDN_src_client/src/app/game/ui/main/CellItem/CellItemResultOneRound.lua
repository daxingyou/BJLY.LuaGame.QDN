--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/CellitemOneRoundResult.csb"

local CellItemResultOneRound = class("CellItemResultOneRound", function()
    return cc.Layer:create()
end)

function CellItemResultOneRound:ctor(_cfg)
    self._cfg = _cfg
    self:initUI() 
end
local card_bg = {
  "green_mj_bg1.png",
  "blue_mj_bg1.png"
}

local card_bg_4_6 = {
  "green_mj_bg3.png",
  "blue_mj_bg3.png"
}
 --初始化ui
function CellItemResultOneRound:initUI()
    self:loadCCB()
end

--加载ui文件
function CellItemResultOneRound:loadCCB()
    local _root = cc.uiloader:load(ccbFile)
    _root:addTo(self)
    local  _UI = _root:getChildByName("Node_jiesuantiao")
    --玩家基本信息
    local  playerInfo = g_data.roomSys:getPlayerInfo(self._cfg.uid)
    dump(playerInfo, "oneroundplayerinfo=================")
    local  sp_icon_tingpai=_UI:getChildByName("icon_chong_495_0")
    if playerInfo.isTingPai == true then
        sp_icon_tingpai:setVisible(true)
    else
        sp_icon_tingpai:setVisible(false)
    end
    local  sp_bg_tiao=_UI:getChildByName("bg_paixing_others")
    if playerInfo.uid == g_data.roomSys:myInfo().uid  then
       sp_bg_tiao:setTexture("res/images/layer_result/bg_paixing_mine.png")      
    else
       sp_bg_tiao:setTexture("res/images/layer_result/bg_paixing_others.png")
    end
    --头像暂
    local iconName = playerInfo.uid..".png"
    local path = device.writablePath..iconName
    if cc.FileUtils:getInstance():isFileExist(path) then
        local mHead = _UI:getChildByName("touxiang_492")
        print("进来了")
        mHead:setTexture(path)
        mHead:setScale(73/mHead:getContentSize().width)
    end
 
--鸡
    local ji_iocn=_UI:getChildByName("icon_chong_495")
    ji_iocn:setVisible(false)
    if playerInfo.ChargeChicken == true and  self._cfg.ji_num ~= 0 then
        ji_iocn:setVisible(true)
    elseif playerInfo.DutyChicken == true then
        ji_iocn:setVisible(true)
        ji_iocn:setTexture("res/srcRes/RoomScene/Player/icon_ze.png")
    end

     
    --总分数-------
    --总分
    local tx_zong=_UI:getChildByName("Text_16_0_0")
    tx_zong:setString(string.format("%d",playerInfo.score))
    --名字
    local name= _UI:getChildByName("Text_name")
    name:setString(playerInfo.weichat_nick)

    --id
    --local tx_id=_UI:getChildByName("Text_16_0_1_0")
    --tx_id:setString(string.format("%d",playerInfo.uid))

    --是否时装
    local  sp_zhuang=_UI:getChildByName("qd1_0013_z_494")
    if playerInfo.uid == g_data.roomSys.banker_uid then
        sp_zhuang:setVisible(true)
    else
        sp_zhuang:setVisible(false)
    end
    --加减的分数
    local tx_score=_UI:getChildByName("Text_fenshu")
    local tx_score_fuhao=_UI:getChildByName("Text_19")
    if self._cfg.win_fan_cnt <= 0 then 
        tx_score:setString(string.format("%d",self._cfg.win_fan_cnt))
        tx_score_fuhao:setVisible(false)
    else
        tx_score:setString(string.format("+%d",self._cfg.win_fan_cnt))
        tx_score_fuhao:setVisible(false)
    end
    --叫牌
    local tx_jiao=_UI:getChildByName("Text_15")
    local tb_hutye = {
    "没叫",
    "有叫",
    "平胡",
    "大对子",
    "七对",
    "龙七对",
    "清一色",
    "清七对",
    "清大对",
    "青龙背",
    }
    --胡牌类型 0没叫 1有叫 2平胡， 3大对子， 4七对， 5龙七对， 6清一色， 7清七对， 8清大对， 9青龙背
    tx_jiao:setString(tb_hutye[self._cfg.hupai_type+1]); 
    --显示杠牌类型 1自摸 2点炮 3放热跑 4杠上花 5抢杠胡（有杠上花就没有自摸）
    local tx_gang_type=_UI:getChildByName("Text_gangtype")
    local tb_gangtype = {
    "自摸",
    "点炮",
    "放热炮",
    "杠上花",
    "抢杠胡",
    }
    if self._cfg.hupai_fangshi <=5 and self._cfg.hupai_fangshi >= 1  then 
        tx_gang_type:setString(tb_gangtype[self._cfg.hupai_fangshi])
    else
        local sp_gang=_UI:getChildByName("bg_hupaifangshi_big")
        sp_gang:setVisible(false)
        tx_gang_type:setVisible(false)
    end
    --鸡牌
    local n_ji=_UI:getChildByName("Node_ji")
    local sp_ji=n_ji:getChildByName("ji_1"):getChildByName("mj_value")
    local jinum_me=self._cfg.ji_num

    local tablestyle = g_LocalDB:read("tablestyle")
      for i = 1,4 do
        local sp_ji = n_ji:getChildByName("ji_"..i)
         if i==2 or i == 3 or i == 4  then
          sp_ji:setSpriteFrame(card_bg[tablestyle])
        else
          sp_ji:setSpriteFrame(card_bg_4_6[tablestyle])
        end
      end

    if  playerInfo.ChargeChicken == true and self._cfg.ji_num ~=0 then
        sp_ji:getParent():setVisible(true)
        sp_ji:setSpriteFrame("mj_11.png")
        jinum_me=jinum_me-1
    else
        sp_ji:getParent():setVisible(false)
    end
    for i=1,3 do
        local sp_ji1 = n_ji:getChildByName("ji_"..i+1):getChildByName("mj_value")
        sp_ji1:getParent():setVisible(false)
    end
    for i=1,jinum_me do
        local sp_ji1=n_ji:getChildByName("ji_"..i+1):getChildByName("mj_value")
        sp_ji1:getParent():setVisible(true)
        sp_ji1:setSpriteFrame("mj_11.png")
    end
    local x     = 305
    local gap   = 10
    local item  = nil
    local op    = nil
    local value = nil 
    for i = 1, #self._cfg.weaves do
        op    = self._cfg.weaves[i].weave_kind
        value = self._cfg.weaves[i].card_id

        item = require("app.common.component.sprites.TileItemBottom").new(op,value)
        item:setScale(0.8)
        item:setPosition(cc.p(x,-50))
        item:addTo(_UI)
        x = x + item.m_Width + gap
    end
        
    --手牌
    local tb_hands = self._cfg.hand_cards
    table.sort(tb_hands, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a >b
                    else
                        return tostring(a) > tostring(b)
                    end
                end)

    local n_shoupai = _UI:getChildByName("nodeCards")
    for i=1,14 do
       local sp_shoupai=n_shoupai:getChildByName(string.format("poker_%d",i))
       sp_shoupai:setVisible(false)
       sp_shoupai:setSpriteFrame(card_bg[tablestyle])
    end
    --胡牌
    local sp_hu_pai=n_shoupai:getChildByName("poker_hu")
    if self._cfg.hupai_type >= 2 then 
       sp_hu_pai:setVisible(true)
       sp_hu_pai:setSpriteFrame(card_bg[tablestyle])
       local sp_hu_value=sp_hu_pai:getChildByName("mj_value")
       sp_hu_value:setSpriteFrame(CardDefine.enum[self._cfg.hu_cardid][2])
    else
       sp_hu_pai:setVisible(false)
    end
    for i=1,13 do
       if  i <= #self._cfg.hand_cards then
           local mj_shoupai=n_shoupai:getChildByName(string.format("poker_%d",i))
           mj_shoupai:setVisible(true)
           local sp_hua=mj_shoupai:getChildByName("mj_value")
           sp_hua:setSpriteFrame(CardDefine.enum[self._cfg.hand_cards[i]][2])
          
       end
    end
end

function CellItemResultOneRound:onBtnClick( _sender )
    
end

function CellItemResultOneRound:setClickHandle( clickHandle)
    self.clickHandle = clickHandle
end


function CellItemResultOneRound:setData( dataTable )  
    
end


return CellItemResultOneRound