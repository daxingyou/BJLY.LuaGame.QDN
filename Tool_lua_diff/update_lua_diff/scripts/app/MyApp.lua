
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")

require("app.utils.dir")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
	CCFileUtils:sharedFileUtils():addSearchPath("res/")
	
	self:enterScene( "MainScene", nil, "fade", 0.6, display.COLOR_WHITE )   
end

return MyApp
