--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/CellItmeDetailResult.csb"

local CellItemResultDetail = class("CellItemResultDetail", function()
    return cc.Layer:create()
end)

function CellItemResultDetail:ctor(_cfg , playerinfoconfig)
    self._cfg = _cfg
    self.playerinfoconfig = playerinfoconfig
    self:initUI() 
end

 --初始化ui
function CellItemResultDetail:initUI()
    self:loadCCB()
end

--加载ui文件
function CellItemResultDetail:loadCCB()
    local _root = cc.uiloader:load(ccbFile)
    _root:addTo(self)
    local  mBackground = _root:getChildByName("bg_suanfen_others_1")


    --玩家基本信息
    local  uid = self._cfg.uid
    local  playerInfo = g_data.roomSys:getPlayerInfo(self._cfg.uid)
    local  sp_icon_tingpai = mBackground:getChildByName("icon_baoting_39")
    if playerInfo.isTingPai == true then
        sp_icon_tingpai:setVisible(true)
    else
        sp_icon_tingpai:setVisible(false)
    end
    --玩家是否是自己的标志
    if uid == g_data.roomSys:myInfo().uid  then
       mBackground:setTexture("res/images/layer_result/bg_suanfen_mine.png")      
    else
       mBackground:setTexture("res/images/layer_result/bg_suanfen_others.png")
    end
--头像暂时不知道存放地址
    local iconName = string.format("%d.png",playerInfo.uid)
    local path =  device.writablePath..iconName
    if cc.FileUtils:getInstance():isFileExist(path) then
        local mHead = mBackground:getChildByName("touxiang_4")
        mHead:setTexture(path)
        mHead:setScale(73/mHead:getContentSize().width)
    end
    --总分
    local tx_zong=mBackground:getChildByName("Text_total_gold")
    tx_zong:setString(string.format("%d",playerInfo.score))
    --名字
    local name = mBackground:getChildByName("Text_name_user")
    name:setString(playerInfo.weichat_nick)

    --是否时装
    local  sp_zhuang=mBackground:getChildByName("qd1_0013_z_415")
    if playerInfo.uid == g_data.roomSys.banker_uid then
        sp_zhuang:setVisible(true)
    else
        sp_zhuang:setVisible(false)
    end

    --找到这个uid对应的用户基本数据
    local u_hupai = 0
    local u_gangpai = 0
    local u_addgold = 0
    for i=1,#self.playerinfoconfig do
        if self.playerinfoconfig[i].uid == uid then
            u_hupai =self.playerinfoconfig[i].hupai_type
            u_gangpai = self.playerinfoconfig[i].hupai_fangshi
            u_addgold = self.playerinfoconfig[i].win_fan_cnt
        end
    end

    --加减的分数
    local tx_score=mBackground:getChildByName("Text_addgold")

    if u_addgold <= 0 then 
        tx_score:setString(string.format("%d",u_addgold))
        
    else
        tx_score:setString(string.format("+%d",u_addgold))
        
    end


    --叫牌
    local tx_jiao=mBackground:getChildByName("Text_hupaitype")
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
    tx_jiao:setString(tb_hutye[u_hupai+1]); 
    --显示杠牌类型 1自摸 2点炮 3放热跑 4杠上花 5抢杠胡（有杠上花就没有自摸）
    local tx_gang_type= mBackground:getChildByName("Text_fangshi")
    local tb_gangtype = {
    "自摸",
    "点炮",
    "放热炮",
    "杠上花",
    "抢杠胡",
    }
    if u_gangpai <=5 and u_gangpai >= 1  then 
        tx_gang_type:setString(tb_gangtype[u_gangpai])
    else
        local sp_gang=mBackground:getChildByName("bg_hupaifanshi_little_6")
        sp_gang:setVisible(false)
        tx_gang_type:setVisible(false)
    end


    for i=1,9 do
        local  n_messgae = mBackground:getChildByName(string.format("Node_tx_%d",i))
        local Tx_name = n_messgae:getChildByName("Text_name")
        local Tx_num = n_messgae:getChildByName("num")
        local Tx_zhuang2 = n_messgae:getChildByName("Text_tag_1_0_0")

        if i <= #self._cfg.weaves then
            local tx_name = self._cfg.weaves[i].kind
            local tx_num = self._cfg.weaves[i].fen
            local tx_zhuang2 = self._cfg.weaves[i].is_zhuang2bei
            if tx_zhuang2 == 0 then
                Tx_zhuang2:setVisible(false)
            end
            Tx_name:setString(tx_name)
            Tx_num:setString(tx_num)
            
            local color = self._cfg.weaves[i].color
            if color == 1 then
                n_messgae:setColor(cc.c3b(255, 0, 0))
            elseif color == 2 then
                n_messgae:setColor(cc.c3b(0, 255, 0))
            else
                n_messgae:setColor(cc.c3b(255, 255, 255))
            end

            else
                n_messgae:setVisible(false)
        end
    end

end

function CellItemResultDetail:onBtnClick( _sender )
    
end

function CellItemResultDetail:setClickHandle( clickHandle)
    self.clickHandle = clickHandle
end


function CellItemResultDetail:setData( dataTable )
    
    
end


return CellItemResultDetail