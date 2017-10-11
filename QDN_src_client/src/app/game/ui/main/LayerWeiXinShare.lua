--[[
    --回馈界面
]]--
local ccbFile = "csb/SubView/LayerWeiXinShare.csb"

local m = class("LayerWeiXinShare", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function m:ctor(_cfg)
    self._isClickShareCircle = false
    self:initUI() 
    g_J2LuaSystem.regJ2LuaFunc(g_J2LuaSystem.J2Lua_WeiXinShare,handler(self,self.J2Lua_WeiXinShare))
    g_C2LuaSystem.regC2LuaFunc(g_C2LuaSystem.C2Lua_WXShareSuccess,handler(self,self.C2Lua_WXShareSuccess)) 
end

 --初始化ui
function m:initUI()
    self:loadCCB()
    self:setTouchEndedFunc(function()
        g_SMG:removeLayer()
    end)
end

--加载ui文件
function m:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    local mBackground = _UI:getChildByName("layer_bg")
    local ctlName = {"btn_share_qun","btn_share_quan"}
    for i,v in ipairs(ctlName) do  
        local btn = mBackground:getChildByName(v)
        g_utils.setButtonClick(btn,handler(self,self.onBtnClick))
    end
    g_utils.setButtonClick(mBackground,handler(self,self.onBtnClick))
end

function m:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_share_qun" then
        self._isClickShareCircle = false
        self:shareUrlWX(g_ToLua.shareType.friendQun)
    elseif s_name == "btn_share_quan" then
        self._isClickShareCircle = true
        self:shareUrlWX(g_ToLua.shareType.friendCircle)
    end
end

function m:shareUrlWX(_type)
    g_WeiXin:shareMainWeixinByType(_type)
end

function m:onEnter()
    -- body
end
function m:onExit()
    -- body
end
function m:onCleanup()
    g_C2LuaSystem.unregC2LuaFunc(g_C2LuaSystem.C2Lua_WXShareSuccess)
    g_J2LuaSystem.unregJ2LuaFunc(g_J2LuaSystem.J2Lua_WeiXinShare)
end

function m:C2Lua_WXShareSuccess()
    if self._isClickShareCircle then
        g_LobbyCtl:WeiXinShareCircle()
    end
end

function m:J2Lua_WeiXinShare( value )
    print("m:J2Lua_WeiXinshare---value:",value)
    if value == 4 then
        g_LobbyCtl:WeiXinShareCircle()
    end
end

return m