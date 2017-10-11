--c++中调用lua接口方法 ，  使用注册的方式调用到相应的lua方法

local C2LuaSystem = {}
--缓存注册的方法
local db = {}

--定义c++调用lua
C2LuaSystem.C2Lua_WeiXinAccess = "C2Lua_WeiXinAccess"   --微信登录结束
C2LuaSystem.C2Lua_GvoiceLoginResponse = "C2Lua_GvoiceLoginResponse"   --用户信息改变
C2LuaSystem.C2Lua_GvoiceUserStateChange = "C2Lua_GvoiceUserStateChange"   --用户信息改变

C2LuaSystem.C2Lua_GvoiceLoginFailed = "C2Lua_GvoiceLoginFailed"   --用户信息改变
C2LuaSystem.C2Lua_OnStatusUpdateSuccess = "C2Lua_OnStatusUpdateSuccess"   --用户信息改变
C2LuaSystem.C2Lua_OnQuitRoom = "C2Lua_OnQuitRoom"   --用户信息改变

C2LuaSystem.C2Lua_WXShareSuccess = "C2Lua_WXShareSuccess"   --微信分享成功
function C2LuaSystem_CallBack(_funcID,_data)
	print("C2LuaSystem_CallBack::::::",_funcID)
    local f = db[_funcID]
    if f then
        f(_data)
    end
end

-- 注册方法类型ID对应调用的方法
function C2LuaSystem.regC2LuaFunc(_funcID, _func)
	print("C2LuaSystem.regC2LuaFunc:",_funcID, _func)
	assert(_funcID, "ERROR:C2LuaSystem.regC2LuaFunc nil")
	db[_funcID] = _func
end

--注销
function C2LuaSystem.unregC2LuaFunc(_funcID)
	db[_funcID] = nil
end

--注销所有
function C2LuaSystem:unregAll()
	db = {}
end



return C2LuaSystem
