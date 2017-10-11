--[[
    --回馈界面
]]--
local CellItemRecord = require("app.game.ui.main.CellItem.CellItemRecord_Detail")
local ccbFile = "csb/LobbyView/LayerRecord.csb"

local LayerRecordDetail = class("LayerRecordDetail", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

local Http_History_Detail = "Http_History_Detail"

function LayerRecordDetail:ctor(_cfg)
    printTable(_cfg,"table===========")
    self.cgf = _cfg
    self:initUI()
    self:__regHTTP()
end

 --初始化ui
function LayerRecordDetail:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerRecordDetail:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local btnExit = mBackground:getChildByName("btn_exit")

    g_utils.setButtonClick(btnExit,handler(self,self.onBtnClick))

    local lvMsg = mBackground:getChildByName("listView_record")
    local __cname = tolua.type(lvMsg)

    print("*************************LayerMessage==",__cname,lvMsg)

    --点击观看录像
    local function cellClickHandle( _index )
        local tb = {
            Round   = _index,
            TableID = self.cgf.RoomID,
            UserID  = g_data.userSys.UserID,

            accessKey = g_data.userSys.accessKey,
            DeviceID = g_data.userSys.openid,
        }
        printTable("tb=========",tb)
        local url =  g_GameConfig.URL.."/get_history_detail" 
        self:performWithDelay(function() g_http.POST(url, tb,"LayerRecordDetail", Http_History_Detail) end, 0.1)
    end

    local  tb_cfg = self.cgf
    printTable("aaa = ",tb_cfg)
    for i=1,self.cgf.Round do
        tb_cfg.index = i
        print("tb_cfg.index ==",tb_cfg.index)
        local cell = CellItemRecord.new(tb_cfg)
        cell:setClickHandle(cellClickHandle)

        local layout = ccui.Layout:create()
        layout:setTouchEnabled(true)
        layout:setContentSize(cell:getContentSize()) 
        layout:addChild(cell)
        lvMsg:pushBackCustomItem(layout)
    end
end

function LayerRecordDetail:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    elseif s_name == "btn_copy" then

    end
end

--创建http
function LayerRecordDetail:__regHTTP()
    --http失败
    local function __httpFail(_response, _tag)
        print(Http_History_Detail, "httpFail", _response, _tag)  
    end

    --http成功
    local function __httpSuccess(_response, _tag)
        print(Http_History_Detail, "httpSuccess", _tag)
        -- print(_response)
        if not _response then
            print("ERROR _response 没有数据")
            return
        end

        local ok = false
        if Http_History_Detail == _tag then
           local tb = json.decode(_response)
           printTable("HistoryDataDetail",tb)
            if tb.ResultCode == 0 then
                local detail = tb.HistoryDataDetail
                g_data.roomSys.PlayRule = self.cgf.PlayRule
                local video = require("app.game.ui.video.VideoLayer").new(detail)
                g_SMG:addLayer(video)
            else
                local LayerTipError = g_UILayer.Common.LayerTipError.new(tb.ErrMsg)
                g_SMG:addLayer(LayerTipError)
                return
            end
            ok = true
        end

        --失败处理
        if not ok then
            __httpFail("", _tag)
        end
    end
    --监听http
    g_http.listeners("LayerRecordDetail", __httpSuccess, __httpFail)
end

--创建http
function LayerRecordDetail:__unHTTP()
    g_http.unlisteners("LayerRecordDetail")
end

function LayerRecordDetail:onCleanup()
    self:__unHTTP()
end
  

return LayerRecordDetail