--[[
    --回馈界面
]]--
local ccbFile = "csb/SubView/Layer_reward.csb"

local LayerReward = class("LayerReward", function()
    local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)

function LayerReward:ctor(isFirst,pickNum)
    self.isfirst  = isFirst
    self.picNum   = pickNum
    g_J2LuaSystem.regJ2LuaFunc(g_J2LuaSystem.J2Lua_WeiXinShare,handler(self,self.J2Lua_WeiXinShare))
    g_C2LuaSystem.regC2LuaFunc(g_C2LuaSystem.C2Lua_WXShareSuccess,handler(self,self.C2Lua_WXShareSuccess)) 
    self:initUI() 
end
function LayerReward:onEnter()
    -- body
end
function LayerReward:onExit()
    -- body
end
function LayerReward:onCleanup()
    g_C2LuaSystem.unregC2LuaFunc(g_C2LuaSystem.C2Lua_WXShareSuccess)
    g_J2LuaSystem.unregJ2LuaFunc(g_J2LuaSystem.J2Lua_WeiXinShare)
end
 --初始化ui
function LayerReward:initUI()
    self:loadCCB()
end

--加载ui文件
function LayerReward:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    local  mBackground = _UI:getChildByName("layer_bg")
    self.button_quit = mBackground:getChildByName("btn_ok_logout")
    self.button_cancle = mBackground:getChildByName("btn_cancle_logout")
    g_utils.setButtonClick(self.button_quit,handler(self,self.onBtnClick))
     g_utils.setButtonClick(self.button_cancle,handler(self,self.onBtnClick))
    
end

function LayerReward:onBtnClick( _sender )
    local s_name = _sender:getName()
    if s_name == "btn_cancle_logout" then
        if self.isfirst == 1 then
            --展示acticity
            g_LobbyCtl:_showActivityView(self.picNum)
        end
        g_SMG:removeByName("LayerReward")
    elseif s_name == "btn_ok_logout" then
        
        g_WeiXin:shareMainWeixinCircle()
        if self.isfirst == 1 then
            --展示acticity
            g_LobbyCtl:_showActivityView(self.picNum)
        end
        
    end
end
function LayerReward:C2Lua_WXShareSuccess()
    g_LobbyCtl:WeiXinShareCircle()
    g_SMG:removeByName("LayerReward")
end

function LayerReward:J2Lua_WeiXinShare( value )
    g_LobbyCtl:WeiXinShareCircle()
    g_SMG:removeByName("LayerReward")
end
return LayerReward