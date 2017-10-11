
require("config")
require("cocos.init")
require("framework.init")
require("app.core.Trackback")

local MyApp = class("MyApp", cc.mvc.AppBase)
function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    collectgarbage("collect")    
    collectgarbage("setpause",100)    
    collectgarbage("setstepmul",5000) 
    --初始化随机种子
    math.newrandomseed()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
     --初始化时钟
	 --游戏配置
    g_GameConfig = require("app.game.GameConfig")

    --设置 Director 相机投影的模式，设置为2d的模式， 默认值时3
    local sharedDirector    = cc.Director:getInstance()
    sharedDirector:setProjection(0)  --0_2D   1_3D    3CUSTOM     4DEFAULT = _3D
    --适配
    local glview = sharedDirector:getOpenGLView()
    glview:setDesignResolutionSize(1280.0,720.0,cc.ResolutionPolicy.EXACT_FIT)
    g_GameConfig.initConfig()
    self:resetDisplay()
  
  	self:initResPath()--初始化资源路径
    require("app.game.init")

    --这是音量
    g_audio.init()


  	self:enterLoadingScene()--进入更新场景
end


--初始化资源路径
function MyApp:initResPath()
    print("=============MyApp:initResPath=============")
    local FileUtils = cc.FileUtils:getInstance()
    --优先搜索下载文件夹 暂时注释
    local downloadPaht = device.writablePath.."download/"
    FileUtils:addSearchPath(downloadPaht.."src/")
    FileUtils:addSearchPath(downloadPaht.."res/")
    FileUtils:addSearchPath(downloadPaht.."res/pb")
    FileUtils:addSearchPath(downloadPaht.."res/ccb")
    FileUtils:addSearchPath(downloadPaht.."res/images")
    FileUtils:addSearchPath(downloadPaht.."res/sound")

    --本地res路径
    FileUtils:addSearchPath("src/")
    FileUtils:addSearchPath("res/")
    FileUtils:addSearchPath("res/pb")
    FileUtils:addSearchPath("res/fonts")
    FileUtils:addSearchPath("res/images")
    FileUtils:addSearchPath("res/sound")

    FileUtils:addSearchPath("res/chinese")
end


function MyApp:resetDisplay()
        -- 重置display 参数
    local winSize = cc.Director:getInstance():getWinSize()
    display.size               = {width = winSize.width, height = winSize.height}
    display.width              = display.size.width
    display.height             = display.size.height
    display.cx                 = display.width / 2
    display.cy                 = display.height / 2
    display.c_left             = -display.width / 2
    display.c_right            = display.width / 2
    display.c_top              = display.height / 2
    display.c_bottom           = -display.height / 2
    display.left               = 0
    display.right              = display.width
    display.top                = display.height
    display.bottom             = 0
    display.widthInPixels      = display.sizeInPixels.width
    display.heightInPixels     = display.sizeInPixels.height

    printInfo("##################### MyApp:resetDisplay #####################")
    printInfo(string.format("# CONFIG_SCREEN_AUTOSCALE      = %s", CONFIG_SCREEN_AUTOSCALE))
    printInfo(string.format("# CONFIG_SCREEN_WIDTH          = %0.2f", CONFIG_SCREEN_WIDTH))
    printInfo(string.format("# CONFIG_SCREEN_HEIGHT         = %0.2f", CONFIG_SCREEN_HEIGHT))
    printInfo(string.format("# display.widthInPixels        = %0.2f", display.widthInPixels))
    printInfo(string.format("# display.heightInPixels       = %0.2f", display.heightInPixels))
    printInfo(string.format("# display.contentScaleFactor   = %0.2f", display.contentScaleFactor))
    printInfo(string.format("# display.width                = %0.2f", display.width))
    printInfo(string.format("# display.height               = %0.2f", display.height))
    printInfo(string.format("# display.cx                   = %0.2f", display.cx))
    printInfo(string.format("# display.cy                   = %0.2f", display.cy))
    printInfo(string.format("# display.left                 = %0.2f", display.left))
    printInfo(string.format("# display.right                = %0.2f", display.right))
    printInfo(string.format("# display.top                  = %0.2f", display.top))
    printInfo(string.format("# display.bottom               = %0.2f", display.bottom))
    printInfo(string.format("# display.c_left               = %0.2f", display.c_left))
    printInfo(string.format("# display.c_right              = %0.2f", display.c_right))
    printInfo(string.format("# display.c_top                = %0.2f", display.c_top))
    printInfo(string.format("# display.c_bottom             = %0.2f", display.c_bottom))
    printInfo("##################### MyApp:resetDisplay End ####################")
end


--进入更新场景
function MyApp:enterLoadingScene()
    g_SMG:startReload()
    g_GameConfig.Game_State = g_GameConfig.GS.Loading
    g_http.unlisteners("NetconnectTip")
    g_SMG:replaceScene(g_GameConfig.SceneName.LoadingScene)
end

--进入主场景
function MyApp:enterMainScene()
    g_GameConfig.updateState(g_GameConfig.GS.Main)
    g_SMG:replaceScene(g_GameConfig.SceneName.MainScene)
end

--进入主场景
function MyApp:enterRoomScene()
    g_GameConfig.Game_State = g_GameConfig.GS.Room
    g_SMG:replaceScene(g_GameConfig.SceneName.RoomScene)
    g_audio.playMusic(g_audioConfig.music["yxyy"]["path"])
end

--过渡场景
function MyApp:transitionScene(args)
    g_GameConfig.Game_State = g_GameConfig.GS.Transition
    g_SMG:replaceScene(g_GameConfig.SceneName.TransitionScene,args)
end

--退到后台执行的方法
function MyApp:onEnterBackground()
    print("======== MyApp:onEnterBackground ==========")
    if g_msg then g_msg:post(g_msgcmd.ENTER_BACKGROUND) end
   
    -- display.pause()
    if g_GameConfig.Game_State == g_GameConfig.GS.Main or g_GameConfig.Game_State == g_GameConfig.GS.Room then
       g_gcloudvoice:closespeaker()
    end
end

--返回前台执行方法
function MyApp:onEnterForeground()
    print("======== MyApp:onEnterForeground ==========")
    if g_msg then g_msg:post(g_msgcmd.ENTER_FOREGROUND) end

    if g_GameConfig.Game_State == g_GameConfig.GS.Main or g_GameConfig.Game_State == g_GameConfig.GS.Room  then
       g_gcloudvoice:openspeaker()
    end
end

return MyApp
