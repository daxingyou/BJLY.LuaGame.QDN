---
---崩溃函数
---by XuJian 
---


--弹出提示框
local function __popDialog(_msg)
	my.TPFunction:messageBox("脚本错误，请截图给程序！", _msg)
end


--重载init崩溃函数
__G__TRACKBACK__ = function(_msg)
    print("------------------Lua-Error----------------------")
    local msg = debug.traceback(_msg, 3)
    
    if 0 == DEBUG then
    	__popDialog(msg)
    elseif 1 == DEBUG then
    	__popDialog(msg)
    elseif 2 == DEBUG then
        print("LUA ERROR: " .. tostring(_msg) .. "\n")
        print(debug.traceback("", 2))
    end
    print("-------------------------------------------------")
end