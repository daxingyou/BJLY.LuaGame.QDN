--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/Layer_cell_clubrecord.csb"

local ItemCellClub = class("ItemCellClub", function()
    return cc.Layer:create()
end)

function ItemCellClub:ctor(_cfg)
    printTable("cfg=======",_cfg)
    self.arg_detail = _cfg
    self.clubcode = self.arg_detail.tx_id
    self:initUI()
end

 --初始化ui
function ItemCellClub:initUI()
    self:loadCCB()
end

--加载ui文件
function ItemCellClub:loadCCB()
    local _UI1 = cc.uiloader:load(ccbFile)
    _UI1:addTo(self)
    self:setContentSize(_UI1:getContentSize())

   

    local _UI = _UI1:getChildByName("bg_club_shenqing")




    local tx_name = _UI:getChildByName("Text_name")
    tx_name:setString(self.arg_detail.name)

    local tx_id = _UI:getChildByName("Text_id")
    tx_id:setString(self.arg_detail.code)

    local tx_Text_numofplayer = _UI:getChildByName("Text_numofplayer")
    tx_Text_numofplayer:setString(self.arg_detail.createTime)

    local tx_status = _UI:getChildByName("Text_numname_0_0")
    if self.arg_detail.status == 0 then
        tx_status:setString("已经退出")
        elseif self.arg_detail.status == 1 then
            tx_status:setString("正在申请")
            elseif self.arg_detail.status == 4 then
            tx_status:setString("撤销申请")
            elseif self.arg_detail.status == 2 then
                tx_status:setString("审核通过")
    end
end
return ItemCellClub