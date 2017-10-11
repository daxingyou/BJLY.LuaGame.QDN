--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/CellitemTotalResult.csb"

local CellitemTotalResult = class("CellitemTotalResult", function()
    return cc.Layer:create()
end)

function CellitemTotalResult:ctor(_cfg)
    self._cfg = _cfg
    self.uid = self._cfg.uid
    self:initUI() 
end

 --初始化ui
function CellitemTotalResult:initUI()
    self:loadCCB()
end

--加载ui文件
function CellitemTotalResult:loadCCB()
    local _root = cc.uiloader:load(ccbFile)
    _root:addTo(self)
    local  mBackground = _root:getChildByName("bg_suanfen_others_1")
    for i=1,8 do
        local sp_fen = mBackground:getChildByName(string.format("Text_fenshu_%d",i))
        if i > #self._cfg.score_round then
             sp_fen:setVisible(false)
             else
                 sp_fen:setVisible(true)
                 if self._cfg.score_round[i] > 0 then
                 sp_fen:setString("+"..self._cfg.score_round[i])
                 else
                     sp_fen:setString(self._cfg.score_round[i])
                 end
        end
    end
     if self.uid == g_data.roomSys:myInfo().uid  then
       mBackground:setTexture("res/images/layer_result/bg_paixing_mine.png")      
    else
       mBackground:setTexture("res/images/layer_result/bg_paixing_others.png")
    end
    local tx_total = mBackground:getChildByName("Text_1_1_4_1_0")
    if self._cfg.total_fen > 0 then
        tx_total:setString("+"..self._cfg.total_fen)
    else
        tx_total:setString(self._cfg.total_fen)
    end
    local tx_name = mBackground:getChildByName("Text_1")

    
    local userinfo = g_data.roomSys:getPlayerInfo(self.uid)

    local nickname = userinfo.weichat_nick

    tx_name:setString(nickname)
    local  tx_uid = mBackground:getChildByName("Text_1_0")
    tx_uid:setString(self.uid)

    local isDayingjia = mBackground:getChildByName("icon_dayingjia_6")
    local  isMe = self:getIsBigWinerByUid(self.uid)
    if isMe == 1 then
        isDayingjia:setVisible(true)
    else
        isDayingjia:setVisible(false)
    end 
    local m_ownerSprite = mBackground:getChildByName("m_ownerSprite")
    m_ownerSprite:setVisible(g_data.roomSys.Owner == self.uid)


    local iconName = self.uid..".png"
    local path = device.writablePath..iconName
    if cc.FileUtils:getInstance():isFileExist(path) then
        local mHead = mBackground:getChildByName("touxiang_5")
        mHead:setTexture(path)
        mHead:setScale(73/mHead:getContentSize().width)
    end
end

function CellitemTotalResult:getIsBigWinerByUid(uid)
    
    local  isMe = 1--标志是否我是大赢家
    local  myinfo = g_data.reportSys:getFinalReportByUid(uid)
    
    for i=1,#g_data.reportSys.m_finalReport do
        local playerinf = g_data.reportSys.m_finalReport[i]
        printTable("playerinf",playerinf)
        if playerinf.uid ~= uid then --不是我本人
           if playerinf.total_fen > myinfo.total_fen then
              isMe=0
              break
           end
        end
    end
    return isMe 
end
function CellitemTotalResult:onBtnClick( _sender )
    
end

function CellitemTotalResult:setClickHandle( clickHandle)
    self.clickHandle = clickHandle
end


function CellitemTotalResult:setData( dataTable )
    
    
end


return CellitemTotalResult