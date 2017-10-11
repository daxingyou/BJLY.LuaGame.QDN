--[[
    --回馈界面
]]--
local CellItemResultOneRound = require("app.game.ui.main.CellItem.CellItemResultOneRound")
local ccbFile = "csb/ResultView/LayerResultOneRound.csb"
local shareFlag = false

local LayerResultOneRound = class("LayerResultOneRound", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)
local card_bg = {
  "green_mj_bg1.png",
  "blue_mj_bg1.png"
}
function LayerResultOneRound:ctor()
    self.roundReport = g_data.reportSys:getRoundReport()
    dump(self.roundReport,"roundReport")
    self.hegiht_cell = 540
    self:initUI() 
    self:setName("LayerResultOneRound")
end

 --初始化ui
function LayerResultOneRound:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerResultOneRound:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
--输赢标志
    local cell_hight = {495.97,378.18,260.39,142.60,}
    local  winTag = _UI:getChildByName("title_result")--输赢标志
    local  tb_reslylist = self.roundReport.result_list
    for i=1,#tb_reslylist do
        --刷新输赢的标志
        if  tb_reslylist[i].uid == g_data.roomSys:myInfo().uid then
            if  tb_reslylist[i].win_fan_cnt== 0 then      --不输不赢
                winTag:setTexture("res/srcRes/RoomScene/Result/title_pingju.png")
            elseif tb_reslylist[i].win_fan_cnt > 0 then   --赢了
                winTag:setTexture("res/srcRes/RoomScene/Result/title_win.png")
            elseif tb_reslylist[i].win_fan_cnt < 0 then   --输了
                winTag:setTexture("res/srcRes/RoomScene/Result/title_title_lose.png")
            end
        end
        --创建cell添加到场景中
        dump(tb_reslylist[i],"tb_reslylist[i]")
        print(i,"tag----------")
        local  cell = CellItemResultOneRound.new(tb_reslylist[i])
        cell:setPosition(33.61,cell_hight[i])
        self:addChild(cell, 1)
    end
--是否黄庄
    local  ishuangzhuang = _UI:getChildByName("is_huangzhuang")
    if self.roundReport["is_huangzhuang"] == 1 then

        ishuangzhuang:setVisible(true)
        local  sp_fanpaiji = _UI:getChildByName("nodeFanPaiJi"):getChildByName("mj_bg"):getChildByName("mj_value")
        sp_fanpaiji:setVisible(false)
        --ishuangzhuang:setTexture("res/loading/layer_result/title_huangzhuang.png")
        local tablestyle = g_LocalDB:read("tablestyle")
        sp_fanpaiji:getParent():setSpriteFrame(card_bg[tablestyle])
    else
         ishuangzhuang:setVisible(false)
         --翻牌鸡展示
        local  sp_fanpaiji = _UI:getChildByName("nodeFanPaiJi"):getChildByName("mj_bg"):getChildByName("mj_value")
        local  value_mj = self.roundReport["fanpaiji_cardid"]
        local tablestyle = g_LocalDB:read("tablestyle")
       
        sp_fanpaiji:getParent():setSpriteFrame(card_bg[tablestyle])
        print("value_mj-----",value_mj)
        if value_mj ~=0 then
            local  path_png = CardDefine.enum[value_mj][2] 
            sp_fanpaiji:setSpriteFrame(path_png)
        else
            sp_fanpaiji:setVisible(false)
        end
    end

  
--底部按钮
    local btnContinue = _UI:getChildByName("Button_jixu")
    local btnDetail = _UI:getChildByName("Button_suanfen")
    local btnShare = _UI:getChildByName("Button_share")
    if g_GameConfig.isiOSAppCheck == true then
        btnShare:setVisible(false)
        btnShare:setEnabled(false)
    end

    g_utils.setButtonClick(btnContinue,handler(self,self.onBtnClick))
    g_utils.setButtonClick(btnDetail,handler(self,self.onBtnClick))
    g_utils.setButtonClick(btnShare,handler(self,self.onBtnClick))
--对局信息
    local  bg_rule = _UI:getChildByName("nodeRule")
    local  sp_roomid = bg_rule:getChildByName("Text_fangjian_0")
    local  sp_jushu = bg_rule:getChildByName("Text_fangjian_0_0")
    local  sp_ismenggang = bg_rule:getChildByName("Text_fangjian_0_0_0")
    local  jianguangsi = bg_rule:getChildByName("Text_fangjian_0_0_0_1")
    sp_roomid:setString(g_data.roomSys.kTableID)
    sp_jushu:setString((g_data.roomSys.RoundLimit-g_data.roomSys.left_round).."/"..g_data.roomSys.RoundLimit.."局")

    local table_type = g_data.roomSys.region--g_LocalDB:read("tableregion")

    print("table_type---",table_type)
    
    if table_type == "jinping" then
       if g_data.roomSys.IsMenGangMulti2 == 1 then
          sp_ismenggang:setString("闷杠X2")
      else
        sp_ismenggang:setString("自杠X2")
       end
       jianguangsi:setVisible(false)
    elseif table_type == "liping" then
       if g_data.roomSys.Additional == 0 then
          sp_ismenggang:setVisible(false)
      else
           sp_ismenggang:setString("订卖"..g_data.roomSys.Additional.."分")
       end
       if  g_data.roomSys.DeathByLight == 1  then
           jianguangsi:setVisible(true)
        else
           jianguangsi:setVisible(false)
        end
    elseif table_type == "tianzhu" then
      if g_data.roomSys.IsMenGangMulti2 == 1 then
          sp_ismenggang:setString("闷杠X2")
      else
        sp_ismenggang:setVisible(false)
       end
       if g_data.roomSys.supplementPriceFlag == 1 then
          jianguangsi:setString("补差价")
        else
            jianguangsi:setVisible(false)
       end
    end
end

function LayerResultOneRound:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "Button_jixu" then
        print("g_data.roomSys.left_round --->",g_data.roomSys.left_round)
        if g_data.roomSys.left_round ~= 0  then
           g_netMgr:send(g_netcmd.MSG_READY,{}, 0)
        else
           g_SMG:removeLayer()
           local layer = g_UILayer.Main.UIReslutTotal.new()
           g_SMG:addLayer(layer)
        end
    elseif s_name == "Button_suanfen" then
        --进入算分详情界面
        local layer = g_UILayer.Main.UIReslutDetail.new(self.roundReport)
        g_SMG:addLayer(layer)

    elseif s_name == "Button_share" then
        --分享截屏
        if not shareFlag then

            shareFlag = true
            g_ToLua:printScreen("share.jpg")
            self:performWithDelay(function ()
                g_ToLua:shareImageWX(device.writablePath.."share.jpg", 0)
                shareFlag=false
            end, 0.05)
        end
    end
end

return LayerResultOneRound