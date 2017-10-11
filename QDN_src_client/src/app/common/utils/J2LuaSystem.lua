--java中调用lua接口方法 ，  使用注册的方式调用到相应的lua方法

local m = {}
--缓存注册的方法
local db = {}

--定义java调用lua
m.J2Lua_WeiXinAccess = "J2Lua_WeiXinAccess"   --微信登录结束
m.J2Lua_WeiXinShare = "J2Lua_WeiXinShare"   --微信登录结束
m.J2Lua_WXLoginErrorShow = "J2Lua_WXLoginErrorShow"   --微信登录结束


function J2LuaSystem_CallBack(funId_data_stringTable)
	print("J2LuaSystem_CallBack::::::",funId_data_stringTable)
	local funId_data_table = json.decode(funId_data_stringTable)
    local f = db[funId_data_table["funId"]]
    local _data = json.decode(funId_data_table["data"])
    if f then
        f(_data)
    end
end

-- 注册方法类型ID对应调用的方法
function m.regJ2LuaFunc(_funcID, _func)
	print("J2LuaSystem.regJ2LuaFunc:",_funcID, _func)
	assert(_funcID, "ERROR:J2LuaSystem.regC2LuaFunc nil")
	db[_funcID] = _func
end

--注销
function m.unregJ2LuaFunc(_funcID)
	db[_funcID] = nil
end

--注销所有
function m:unregAll()
	db = {}
end



return m