--
--游戏界面管理
--
local SceneManager = class("SceneManager")

local sharedDirector = cc.Director:getInstance()
local winSize = sharedDirector:getWinSize()


local TAG_ORDER_WAIT = 1000 --网络等待层
local TAG_START = 100 --二级弹出框的起始tag值

function SceneManager:ctor()
	self.m_layers = {}
	self.m_list   = {}
	self.m_layerUp = nil
	self.m_isLoading = false --是否在loading层中

	--网络等待节点
	self.m_Loading = require("app.game.ui.common.LayerLoading").new()
	self.m_Loading:retain()

	self.m_netConnect = require("app.game.ui.room.NetconnectTip").new()
	self.m_netConnect:retain()

	g_msg:reg("SceneManager", g_msgcmd.SOCKET_CONNECT_SUCCESS, handler(self, self.onSocketSuccess))
    g_msg:reg("SceneManager", g_msgcmd.SOCKET_CONNECT_FAIL, handler(self, self.onSocketFail))
    g_msg:reg("SceneManager", g_msgcmd.DB_ENTER_ROOM,
    	function()
    		app:enterRoomScene()
    	end)
end

function SceneManager:onSocketSuccess()
	print("========onSocketSuccess===========")
	print("g_data.userSys.UserID =",g_data.userSys.UserID,"g_data.roomSys.kTableID= ",g_data.roomSys.kTableID)
	g_netMgr:send(g_netcmd.MSG_LOGIN, { 
		uid = g_data.userSys.UserID,
		table_id = g_data.roomSys.kTableID},0)
end

function SceneManager:onSocketFail()
	print("========onSocketFail===========")
	print("g_data.roomSys.m_status = ",g_data.roomSys.m_status)
	if g_GameConfig.Game_State == g_GameConfig.GS.Room then
		if g_data.roomSys.m_status == RoomDefine.Status.End then
		else
			self:addNetConnectLayer()
        	-- local tip = require("app.game.ui.room.NetconnectTip")
        	-- self:addLayerByName(tip.new())
        	-- g_SMG:addLayer(tip.new())
    	end
	end
end

function SceneManager:replaceSceneWithName(_sceneName)
    local scenePackageName = app.packageRoot .. ".scenes." .. _sceneName
    print("SceneManager:replaceSceneWithName=",_sceneName)

    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(unpack(checktable(args)))
    self:replaceScene(scene)
end

function SceneManager:replaceScene(_sceneName)
    local sceneClass = require(_sceneName)
	self:removeAllLayer()
	local scene= sceneClass.new()

	display.replaceScene(scene)
	-- display.replaceScene(_scene,"crossFade", 0.15, cc.c3b(0, 0, 0))
    display.removeUnusedSpriteFrames()
end

function SceneManager:pushScene(_scene)
	self:removeAllLayer()
	self:removeWaitLayer()
	if _scene then
		-- self:createCamera(_scene)
		sharedDirector:pushScene(_scene)
	end
end

function SceneManager:popScene()
	self:removeAllLayer()
	self:removeWaitLayer()
	sharedDirector:popScene()
end
--push一个界面到当前界面
function SceneManager:pushSceneWithType(_sType,_data)

	local newScene = nil
	if newScene then
		self:pushScene(newScene)
	end
end

function SceneManager:popSceneWithType(_sType,_data)
	self:removeAllLayer()
	self:removeWaitLayer()
	self:popScene()
end

--[[
	界面是否存在
]]
function SceneManager:isExist(name)
	local key = name
	return (self.m_list[key] and true) or false
end	

--todo以后改成name
function SceneManager:addLayerByName( _layer, parent, _noMask,... )
 	-- 如果存在
	if self:isExist(_layer.__cname) then
		self:removeByName(_layer.__cname)
	end
	-- 创建
	if parent then
		parent:addChild(_layer,101)
	else
		_layer:addTo(display.getRunningScene(), 101)
	end

	if not _noMask then
			local colorLayer = display.newColorLayer(cc.c4b(0, 0, 0, 170))
			colorLayer:setCascadeOpacityEnabled(true)
			colorLayer:setOpacity(0)
			colorLayer:addTo(_layer, -1)
			colorLayer:runAction(cc.Sequence:create({
				cc.FadeOut:create(0),-- 淡出
			    cc.Spawn:create({
                    cc.FadeIn:create(0.25),-- 淡入
                 }),
			}))
	end
	
	local key = _layer.__cname
	print( "SceneManager: addLayerByName key = ", key )
	self.m_list[key] = _layer
	return _layer
end

--[[
	删除界面
]]
function SceneManager:removeByName(name)
	if not self:isExist(name) then
		return
	end
	local key = name
	local layer = self.m_list[key]
	if layer then
		layer:removeFromParent(true)
		self.m_list[key] = nil
	else
		print("SceneManager:removeByName not found", key)
	end
end

--添加layer到当前scene中，一般设置显示的layer为模式显示方式，屏蔽该layer下的触摸事件
function SceneManager:addLayer(_layer, _isShow, _noMask)
	local num = #self.m_layers
	local scene = sharedDirector:getRunningScene()
	--前一个
	local preLayer = nil
	if num >= 1 then
		preLayer = scene:getChildByTag(num+TAG_START)
	end
	--重复层，不会同时打开2个
	if preLayer and preLayer.__cname and preLayer.__cname == _layer.__cname then
		return
	end

	print("SceneManager:addLayer**************  num", num, _layer.__cname)
	table.insert(self.m_layers, _layer)

	--加入背景阴影层
	if num == 0 then
		if not _noMask then
			local colorLayer = display.newColorLayer(cc.c4b(0, 0, 0, 170))
			colorLayer:setCascadeOpacityEnabled(true)
			colorLayer:setOpacity(0)
			colorLayer:addTo(scene, TAG_START, TAG_START)
			colorLayer:runAction(cc.Sequence:create({
				cc.FadeOut:create(0),-- 淡出
			    cc.Spawn:create({
                    cc.FadeIn:create(0.25),-- 淡入
                 }),
			}))
		    -- colorLayer:setCameraMask(SceneManager.s_CM[SceneManager.GAME_LAYER.Camera3])
		end
	end
	
	_layer:addTo(scene, num+TAG_START+1, num+TAG_START+1)
	-- _layer:setCameraMask(SceneManager.s_CM[SceneManager.GAME_LAYER.Camera3])
	self:setPopAction(_layer, true, function()
			if _layer.onEnter then
    			_layer:onEnter()
    		end
		end)

	--隐藏之前的对话框
	if preLayer then
		-- self:setPopAction(preLayer, false, function()
			if not _isShow then
				preLayer:setVisible(false)				
				
			end
			if preLayer.onExit then
				preLayer:onExit()
			end

		-- end)
	end
end

--移除当前界面的提示框
function SceneManager:removeLayer(_noAction)
	local num = #self.m_layers
	print("SceneManager:removeLayer----------------  num:"..num)
	if num >= 1 then
		table.remove(self.m_layers, num)
    end
    local scene = sharedDirector:getRunningScene()
    local curLayer = scene:getChildByTag(num+TAG_START)
    if curLayer then
    	-- curLayer:setCameraMask(SceneManager.s_CM[SceneManager.GAME_LAYER.Camera2])
    	self:setPopAction(curLayer, false, function()
    			if curLayer.onExit then
    				curLayer:onExit()
    			end
    			curLayer:removeFromParent(true)
    		end,_noAction)
    end

    --推出后面的对话框
    num = #self.m_layers
    if num >= 1 then
    	local preLayer = scene:getChildByTag(num+TAG_START)
		if preLayer then
			preLayer:setVisible(true)
			self:setPopAction(preLayer, true, function()
					if preLayer.onEnter then
						preLayer:onEnter()
					end
				end)
		end
    end

    --删除背景阴影层
    if num==0 then
    	local colorLayer =  scene:getChildByTag(TAG_START)
    	if colorLayer then
    		print("SceneManager:removeLayer.......TAG_START")
    		colorLayer:setCascadeOpacityEnabled(true)
			colorLayer:setCascadeOpacityEnabled(true)
			colorLayer:runAction(cc.Sequence:create({
				cc.Spawn:create({
                    cc.FadeOut:create(0.25),-- 淡出
                 }),
				cc.CallFunc:create(function() scene:removeChildByTag(TAG_START, true) end)
			}))
		end
	end
end

--对话框缓冲动画
function SceneManager:setPopAction(_node, _isOpen, _fun,_noAction)

	if _noAction then --不显示动画
		if _fun then
			_fun()
		end
		return
	end
	--想让ccb以弹出的方式出场，请设置根节点名称为 m_popLayer
	if _node.m_ccbRoot and _node.m_ccbRoot.m_popLayer then

		local popLayer = _node.m_ccbRoot.m_popLayer
		-- local popLayer = _node -- 直接以node作为节点做动画
		if _isOpen then
			popLayer:ignoreAnchorPointForPosition(true)
			popLayer:setCascadeOpacityEnabled(true)
			popLayer:setScale(0)
			-- popLayer:setPosition(cc.p(popLayer:getPositionX(),popLayer:getPositionY()- display.height*0.5))
			popLayer:runAction(cc.Sequence:create({
				cc.FadeOut:create(0),-- 淡出
			    cc.Spawn:create({
                    cc.FadeIn:create(0.25),-- 淡入
                    cc.ScaleTo:create(0.25, 1.0),
                    -- cc.MoveBy:create(0.25, cc.p(0, display.height*0.5))
                 }),

				cc.CallFunc:create(_fun)
			}))
			return
		else
			popLayer:ignoreAnchorPointForPosition(true)
			popLayer:setCascadeOpacityEnabled(true)
			popLayer:runAction(cc.Sequence:create({
				cc.Spawn:create({
                    cc.FadeOut:create(0.25),-- 淡出
                    cc.ScaleTo:create(0.25, 0),
                    -- cc.MoveBy:create(0.25, cc.p(0, -display.height*0.5))
                 }),
				cc.CallFunc:create(_fun)
			}))
			return
		end
	end
    if _node.m_ccbRoot and _node.m_ccbRoot.m_nodeSetting then
        local popSetting = _node.m_ccbRoot.m_nodeSetting
        if _isOpen then
            popSetting:setScale(0)
            popSetting:runAction(cc.Sequence:create({
                cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1.0)),
            }))
            return
        else
            popSetting:runAction(cc.Sequence:create({
                cc.EaseBackOut:create(cc.ScaleTo:create(0.5, 0)),
                cc.CallFunc:create(_fun),
            }))
            return
        end
    end
	if _fun then
		_fun()
	end
end

--移除所有的层
function SceneManager:removeAllLayer()
	local scene = sharedDirector:getRunningScene()
	if not scene then return end

	for i,v in ipairs(self.m_layers) do
		if v then
       		scene:removeChild(v, true)
       	end
    end
    self.m_layers = {}

    for i,v in ipairs(self.m_list) do
		if v then
			v:removeFromParent(true)
       	end
    end
    self.m_list = {}

    --删除背景阴影层
    local colorLayer = scene:getChildByTag(TAG_START)
	if colorLayer then
		scene:removeChildByTag(TAG_START, true)
	end
end

function SceneManager:addWaitLayer(_delay)
	self.m_Loading:removeSelf()
	local scene = sharedDirector:getRunningScene()
	self.m_Loading:addTo(scene, TAG_ORDER_WAIT, TAG_ORDER_WAIT)
	self.m_Loading:show(_delay)
end

function SceneManager:removeWaitLayer()
	-- print("SceneManager:removeWaitLayer")
    self.m_Loading:hide()
    self.m_Loading:removeSelf()
end

function SceneManager:addNetConnectLayer(_delay)
	print("lose connnect from server")
	self.m_netConnect:removeSelf()
	local scene = sharedDirector:getRunningScene()
	self.m_netConnect:addTo(scene,10000)
	self.m_netConnect:setVisible(true)
	-- self.m_Loading:show(_delay)
end

function SceneManager:removeNetConnectLayer()
	-- print("SceneManager:removeWaitLayer")
    -- self.m_Loading:hide()
    self.m_netConnect:removeSelf()
end

--获取层数
function SceneManager:getLayersNum()
	local r = #self.m_layers
	return r
end

--获取当前运行的层(也是最顶层)
function SceneManager:getRunLayer()
	local num = #self.m_layers
	if num > 0 then
		return self.m_layers[num]
	end
	return nil
end

--设置loading开始
function SceneManager:startReload()
	self.m_isLoading = true
end

--设置loading结束
function SceneManager:endReload()
	self.m_isLoading = false
end

return SceneManager
