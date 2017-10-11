
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

local downpath = cc.FileUtils:getInstance():getWritablePath() .. "download/src/?.lua;"

package.path = downpath..package.path .. ";src/"
cc.FileUtils:getInstance():setPopupNotify(false)
-- require("app.game.MyApp").new():run()

xpcall(function() require("app.game.MyApp").new():run() end, __G__TRACKBACK__)

---测试 
-- require("game")
-- game.startup()
