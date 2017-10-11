local GameConfig = {}

 --请求客户端配置地址

-- GameConfig.URL = "http://120.77.175.70:56492"
--GameConfig.URL =  "http://182.92.161.204:56492"
GameConfig.URL = "http://apiqdn.laiyagame.com:56492"
-- GameConfig.URL =  "http://192.168.1.110:56492"
-- GameConfig.URL =  "http://192.168.1.111:56492"
-- --服务器地址
GameConfig.kServerAddr = ""
GameConfig.kServerPort = 0--port

GameConfig.isGuest = true  --用户的登录模式
GameConfig.guestID = "1121_12——sck"
--GameConfig.guestID = "gue" .. math.random(os.time())
GameConfig.isiOSAppCheck = false --ios提审时把它设置为true

if 0 == DEBUG then
	GameConfig.DEBUG_MENU      = false --是否开启deug菜单
	GameConfig.DEBUG_RELOAD    = false --是否启用热加载
	GameConfig.LOCAL_DEBUG     = false --是否开启本地测试
    GameConfig.SKIP_UPDATE     = false --跳过更新，全部读取本地
	GameConfig.SELECT_SERVER   = false --是否可以选择服务器
elseif 1 == DEBUG then
	GameConfig.DEBUG_MENU      = true  --是否开启deug菜单
	GameConfig.DEBUG_RELOAD    = false --是否启用热加载
	GameConfig.LOCAL_DEBUG     = false --是否开启本地测试
    GameConfig.SKIP_UPDATE     = false --跳过更新，全部读取本地
	GameConfig.SELECT_SERVER   = false --是否可以选择服务器
else
	GameConfig.DEBUG_MENU      = true  --是否开启deug菜单
	GameConfig.DEBUG_RELOAD    = true  --是否启用热加载
	GameConfig.LOCAL_DEBUG     = false --是否开启本地测试
    GameConfig.SKIP_UPDATE     = true --跳过更新，全部读取本地
	GameConfig.SELECT_SERVER   = false --是否可以选择服务器
end

-------------游戏设置信息----------
--通知开关
GameConfig.NotifyEnable = true
--音乐开关
GameConfig.MusicEnable = true
--音效开关
GameConfig.SoundEnable = true
--当前时间
GameConfig.CurrentTime = 0
--是否android平台
GameConfig.isAndroid = false
--是否ipad设备
GameConfig.isIPad = false
--是否iphone设备
GameConfig.isIPhone = false
--当前设备参考的长度倍率
GameConfig.referenceMultiple = 1
--当前设备显示界面的大小
GameConfig.SceneSize = {width =960, height=640}
--当前设备参考的界面大小
GameConfig.ReferenceSceneSize = {width=960, height=640}
--界面ui类型
GameConfig.kUI_1024x768 = 1
GameConfig.kUI_1136x640 = 2
--GameConfig.kUI_960x640 = 3
GameConfig.UIType = GameConfig.kUI_1024x768
--游戏的整体流程状态
GameConfig.Game_State = 0
--状态定义
GameConfig.GS = {
    Loading    = 1,  --登陆
    Main       = 2,  --大厅
    Room       = 3,
    
    Transition = 9, --过渡
}
GameConfig.SceneName =
{
    LoadingScene    = "app.game.scenes.LoadingScene",
	MainScene 		= "app.game.scenes.MainScene", 
	RoomScene  		= "app.game.scenes.RoomScene",
    TransitionScene = "app.game.scenes.TransitionScene",
}


function GameConfig.updateState(_stae)
	g_GameConfig.Game_State = _stae
	if g_GameConfig.Game_State == g_GameConfig.GS.Main  then
		g_data.roomSys:exitRoom() -- 清理房间数据
    	g_audio.playMusic(g_audioConfig.music["dlyy"]["path"])
    	g_netMgr:close()
	end
end


--sceneSize 屏幕显示大小
--referenceSceneSize ui设计参考的屏幕大小
function GameConfig.initConfig()
	if device.platform == "android" then
		GameConfig.isAndroid = true
	end

	if device.model == "iphone" then
		GameConfig.isIPhone = true
	elseif device.model == "ipad" then
		GameConfig.isIPad = true
	end

	-- GameConfig.SceneSize = sceneSize
	-- GameConfig.ReferenceSceneSize = referenceSceneSize

	-- local value = sceneSize.height/referenceSceneSize.height;
	-- local referenceValue = 1

	-- if value<0.5 then
	-- 	referenceValue = 0.25
	-- elseif value<1 then
	-- 	referenceValue = 0.5
	-- elseif value<2 then
	-- 	referenceValue = 1
	-- elseif value<3 then
	-- 	referenceValue = 2
	-- end

	-- -- GameConfig.referenceMultiple = referenceValue
	-- print("-------------GameConfig init---------------------")
	-- print("referenceValue:"..referenceValue)
	-- print("-------------------------------------------------")
end


function GameConfig.getSceneSize()
	return GameConfig.SceneSize
end

function GameConfig.autoLength(length)
	return GameConfig.referenceMultiple*length
end

function GameConfig.autoSize(size)
	return cc.size(size.width*GameConfig.referenceMultiple, size.height*GameConfig.referenceMultiple)
end

function GameConfig.autoPosition(pos)
	return cc.p(pos.x*GameConfig.referenceMultiple, pos.y*GameConfig.referenceMultiple)
end

function GameConfig.autoC3BScale(scale)
	return scale*GameConfig.c3bScaleRefMultiple
end

function GameConfig.getUploadURL()
	local f = "app.platform.update_"
    if "ios" == device.platform then
        f = f.."ios"
    elseif "android" == device.platform then
        f = f.."android"
    else
        f = f.."ios"
    end
    local updataConfig = require(f)

    return updataConfig.getUploadURL()
end

--各机型适配，进行ui的缩放调整
function GameConfig.setConfigUi(_rootNode,_closeNode,_scale)
	if g_GameConfig.UIType == g_GameConfig.kUI_1024x768 then
        return
    else
    	local scale = 0.9
    	if _scale then
    		scale = _scale
    	end
    	if _rootNode then
    		_rootNode:setScale(_rootNode:getScale()*scale)
            _rootNode:setPositionY(_rootNode:getPositionY()-_rootNode:getContentSize().height*0.05)
    	end
    	if _closeNode then
    		_closeNode:setScale(_closeNode:getScale()/scale)
    	end
    end
end

return GameConfig
