--[[
    --回馈界面
]]--
local CellItemResultDetail = require("app.game.ui.main.CellItem.CellItemResultDetail")
local ccbFile = "csb/ResultView/LayerResultDetail.csb"

local LayerResultDetail = class("LayerResultDetail", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return cc.Layer:create()
end)

function LayerResultDetail:ctor(_cfg)
    
    self.cgf = _cfg
    self:initUI() 
end

 --初始化ui
function LayerResultDetail:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerResultDetail:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    local tb_p = {
    188,
    496,
    804,
    1112,
    }
    local mBackground = _UI:getChildByName("bg_tankuang_jiexuan_1")
    local sp_wintag = mBackground:getChildByName("title_win_3")
    --判断输赢
    local  tb_reslylist = self.cgf.result_list
    
    for i=1,#tb_reslylist do
        --刷新输赢的标志
        if  tb_reslylist[i].uid == g_data.roomSys:myInfo().uid then
            if  tb_reslylist[i].win_fan_cnt== 0 then      --不输不赢
                sp_wintag:setTexture("res/srcRes/RoomScene/Result/title_pingju.png")
            elseif tb_reslylist[i].win_fan_cnt > 0 then   --赢了
                sp_wintag:setTexture("res/srcRes/RoomScene/Result/title_win.png")
            elseif tb_reslylist[i].win_fan_cnt < 0 then   --输了
                sp_wintag:setTexture("res/srcRes/RoomScene/Result/title_title_lose.png")
            end
        end
    end
    
    
    local btn_return = mBackground:getChildByName("Button_1")

    for i=1,#self.cgf.details.result_list do --遍历详情的内容 添加cell上去
        local celldetai = CellItemResultDetail.new(self.cgf.details.result_list[i],self.cgf.result_list)
        celldetai:setPosition(tb_p[i],589)
        mBackground:addChild(celldetai, 2, "detailcell")
    end
    
    g_utils.setButtonClick(btn_return,handler(self,self.onBtnClick))
 
    
end

function LayerResultDetail:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "Button_1" then
        g_SMG:removeLayer()
    end
end


return LayerResultDetail