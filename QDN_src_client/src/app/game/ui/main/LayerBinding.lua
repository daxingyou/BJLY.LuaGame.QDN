--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/LayerBinding.csb"

local m = class("LayerBinding", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

local personType = {
    tgy = 1,--推广员
    tjr = 2,--推荐人
}

function m:ctor(_cfg)
    self._data = _cfg
    self:initUI()

    g_http.listeners(g_httpTag.BIND_PLAYER,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.BIND_PARTNER,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.GET_PARTNER_INFO,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.GETP_LAYER_INFO_BY_INVITE_CODE,handler(self, self.httpSuccess),handler(self, self.httpFail))
end

 --初始化ui
function m:initUI()
    self:loadCCB()
end

function m:onEnter()
end

function m:onExit()
end

function m:onCleanup()    
    g_http.unlisteners(g_httpTag.BIND_PLAYER)
    g_http.unlisteners(g_httpTag.BIND_PARTNER)
    g_http.unlisteners(g_httpTag.GET_PARTNER_INFO)
    g_http.unlisteners(g_httpTag.GETP_LAYER_INFO_BY_INVITE_CODE)
end
function m:httpSuccess(_response,_tag)
    printTable("_response",_response,_tag)
    if not _response then
        print("ERROR _response 没有数据")
        return
    end

    local data = json.decode(_response)
    printTable("response_tb", data)
    if not data then return end
    if data.ResultCode == -1 then
        self:showErrorTxt(data.ErrMsg)
        return
    end
    if g_httpTag.BIND_PLAYER == _tag then
        print("-----success")

        g_SMG:removeLayer()
        self._ctrl["TextField_Code"]:setEnabled(false)
        self._ctrl["btn_binding_code"]:setEnabled(false)
        g_data.userSys.RefereeID = self._bindID--推荐人邀请码
    elseif g_httpTag.BIND_PARTNER == _tag then
        print("---BIND_PARTNER--success")

        g_SMG:removeLayer()
        
        self._ctrl["TextField_Person"]:setEnabled(false)
        self._ctrl["btn_binding_person"]:setEnabled(false)
        g_data.userSys.PromoterID = self._bindID --我的推广员ID
    elseif g_httpTag.GET_PARTNER_INFO == _tag then
        local fun = function()
            self:Bind(personType.tgy,data.Data.userId)       
        end
        data.Data.confirmHandle = fun
        g_SMG:addLayer(g_UILayer.Main.UIBindConfirm.new(data.Data))
    elseif g_httpTag.GETP_LAYER_INFO_BY_INVITE_CODE == _tag then
        local fun = function()
            self:Bind(personType.tjr,data.Data.userId)       
        end
        data.Data.confirmHandle = fun
        g_SMG:addLayer(g_UILayer.Main.UIBindConfirm.new(data.Data))
    end
end
function m:httpFail(response,_tag)
    -- body
end

function m:showErrorTxt(errorTxt)
    local LayerTipError = g_UILayer.Common.LayerTipError.new(errorTxt)
    g_SMG:addLayer(LayerTipError)
end

--加载ui文件
function m:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    local mBackground = _UI:getChildByName("layer_bg")

    self._ctrl = {}
    local mapCtrlNameValue = {
        TextField_Code = "tjryqm",
        TextField_Person = "wdtgy",

        btn_binding_code = "btn_binding_code",
        btn_binding_person = "btn_binding_person",
        btn_exit = "btn_exit"
    }
    for k,v in pairs(mapCtrlNameValue) do
        local ctrl = mBackground:getChildByName(k)
        if ctrl then
            if string.find(k,"btn_") == 1 then
                g_utils.setButtonClick(ctrl,handler(self,self.onBtnClick))
            else 
                ctrl:setString(self._data[v])
            end
        end
        self._ctrl[k] = ctrl
    end

    if string.len(self._data["tjryqm"]) ~= 0 then
        self._ctrl["TextField_Code"]:setEnabled(false)
        self._ctrl["btn_binding_code"]:setEnabled(false)
    end

    if string.len(self._data["wdtgy"]) ~= 0 then
        self._ctrl["TextField_Person"]:setEnabled(false)
        self._ctrl["btn_binding_person"]:setEnabled(false)
    end
end

function m:onBtnClick( _sender )
    local s_name = _sender:getName()
    print("----name=",s_name)
    if s_name == "btn_exit" then
        g_SMG:removeLayer()
    elseif s_name == "btn_binding_code" then
        local str = self._ctrl["TextField_Code"]:getString()
        if string.len(str) ~= 0 then
            self:getPersonInfo(personType.tjr,str)
        end
    elseif s_name == "btn_binding_person" then
        local str = self._ctrl["TextField_Person"]:getString()
        if string.len(str) ~= 0 then
            self:getPersonInfo(personType.tgy,str)
        end
    end
end

function m:getPersonInfo(Type,bindID)
    print("-------type=-",Type) 
    local data = {}
    if Type == personType.tgy then  
        data.partnerId = bindID
        self:httpPost(g_httpTag.GET_PARTNER_INFO,data,g_httpTag.GET_PARTNER_INFO,g_httpTag.GET_PARTNER_INFO)
    elseif Type == personType.tjr then        
        data.inviteCode = bindID
        self:httpPost(g_httpTag.GETP_LAYER_INFO_BY_INVITE_CODE,data,g_httpTag.GETP_LAYER_INFO_BY_INVITE_CODE,g_httpTag.GETP_LAYER_INFO_BY_INVITE_CODE)
    end
end

function m:Bind(Type,bindID)
    self._bindID = bindID
    local data = {}
    if Type == personType.tgy then
        data.partnerId = bindID
        self:httpPost(g_httpTag.BIND_PARTNER,data,g_httpTag.BIND_PARTNER,g_httpTag.BIND_PARTNER)
    elseif Type == personType.tjr then 
        data.invitePlayerId = bindID
        self:httpPost(g_httpTag.BIND_PLAYER,data,g_httpTag.BIND_PLAYER,g_httpTag.BIND_PLAYER)
    end
end

function m:httpPost(urlTag,data,responseTag,subTag)
    data.accessKey = g_data.userSys.accessKey
    data.DeviceID = g_data.userSys.openid
    data.UserID = g_data.userSys.UserID
    dump(data,"---httpPostData---")
    g_http.POST(g_GameConfig.URL .. urlTag,data,responseTag,subTag)
end

return m