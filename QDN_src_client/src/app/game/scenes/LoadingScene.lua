
--[[
    登陆场景
]]
local LoadingScene = class("LoadingScene", function()
    return display.newScene("LoadingScene")
end)

local REQ_CLIENT = "REQ_CLIENT"
local ccbfile = "ccb/loading.ccbi"
function LoadingScene:ctor()
    self.m_tickSchedule = nil
    self:load_ccb()
    self:initUI()
    self:regEvent()
end

--清理
function LoadingScene:onCleanup()
     self:unregEvent()
end

function LoadingScene:onEnter()
     -- g_SMG:addLayer(require("app.game.ui.main.LayerResultOneRound").new())
end

function LoadingScene:onExit()
end

function LoadingScene:load_ccb()
    self.m_ccbRoot = {}
    local proxy = cc.CCBProxy:create()
    local node  =  CCBReaderLoad(ccbfile, proxy, self.m_ccbRoot)
    node:addTo(self)
end

function LoadingScene:initUI()
    local ccb = self.m_ccbRoot
    --进度条
    local m_loading_bar_bg = ccb.m_loading_bar_bg
    local bar = display.newProgressTimer("#loading_bar.png", display.PROGRESS_TIMER_BAR)
    bar:setMidpoint(cc.p(0,0))
    bar:setBarChangeRate(cc.p(1,0))
    bar:setAnchorPoint(cc.p(0.5,0.5))
    bar:setPosition(cc.p(m_loading_bar_bg:getPositionX(), m_loading_bar_bg:getPositionY()))
    bar:addTo(m_loading_bar_bg:getParent())
    self.m_bar = bar
    self:setProgressBar(0, 100)

    local clientVersion = g_LocalDB:read("clientversion")
    ccb.m_VersionLable:setSystemFontName("fonts/FZZZHONGHJW.TTF")
    ccb.m_VersionLable:setString("App v "..clientVersion)

    self:get_clientConfig()
    self.tickTime = 0
    self:run_spot()
end

--点点点
function LoadingScene:run_spot()
    self.m_ccbRoot.m_spot_1:stopAllActions()
    self.m_ccbRoot.m_spot_2:stopAllActions()
    self.m_ccbRoot.m_spot_3:stopAllActions()

    self.m_ccbRoot.m_spot_1:runAction(cc.Sequence:create({cc.FadeOut:create(0),cc.DelayTime:create(1),cc.FadeIn:create(0)}))
    self.m_ccbRoot.m_spot_2:runAction(cc.Sequence:create({cc.FadeOut:create(0),cc.DelayTime:create(2),cc.FadeIn:create(0)}))
    self.m_ccbRoot.m_spot_3:runAction(cc.Sequence:create({cc.FadeOut:create(0),cc.DelayTime:create(3),cc.FadeIn:create(0),
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                        self:run_spot()
                    end)
        }))  
end


--设置进度条
function LoadingScene:setProgressBar(_num, _max)
    local percent = (_num/_max)*100
    self.m_bar:stopAllActions()
    local t = 1/60
    local step = (percent - self.m_bar:getPercentage()) / 6
    if step <= 0 then step = 1 end
    -- print("step", step)
    self.m_bar:schedule(function()
        local num = self.m_bar:getPercentage() + step
        -- print("numUp"..num)
        -- print("percent"..percent)
        if num >= percent then
            num = percent
            self.m_bar:stopAllActions()
        end
        self.m_bar:setPercentage(num)
    end, 0)
end

function LoadingScene:run_m_tickSchedule()
    if self.m_tickSchedule == nil then
        self.m_tickSchedule = self:schedule( function() self:tick(0.1) end, 0.1)
    end
end

function LoadingScene:un_m_tickSchedule()
    if self.m_tickSchedule then
        self:stopAction(self.m_tickSchedule)
        self.m_tickSchedule = nil
    end   
end

function LoadingScene:tick( ft )
    local TICK_TIME = 1
    self.tickTime = self.tickTime + ft
    if self.tickTime > TICK_TIME then
        if self.m_tickSchedule ~= nil then
            self:stopAction(self.m_tickSchedule)
            self.m_tickSchedule = nil
        end
        g_SMG:endReload()
        -- app:enterLoginScene()
        local login = require("app.game.ui.LoginLayer").new()
        login:addTo(self)
    else
        self:setProgressBar(self.tickTime,TICK_TIME)
    end
end

function  LoadingScene:get_clientConfig()
    local clientVersion = g_LocalDB:read("clientversion")
    local platform      = device.platform
    local tb = {
        version   = clientVersion,
        platform  = platform
    }
    local url =  g_GameConfig.URL.."/version_verify"  -- 检查更新 -测试

    g_http.listeners("LoadingScene",
        handler(self, self.httpSuccess),
        handler(self, self.httpFail)) 
    self:performWithDelay(function()
            g_http.POST(url, tb,"LoadingScene", REQ_CLIENT)
        end, 0.1)
end

function LoadingScene:regEvent()
     --监听http
    g_thunder:regNotice("LoadingScene", handler(self, self.downFun))
end

function LoadingScene:unregEvent()
    g_thunder:unregNotice("LoadingScene")
end

function LoadingScene:enterRoom()
    app:enterRoomScene()
end

--http成功
-- {
--     "TAG":0, -- 1游客  0 真实
--     "forceUpdate":false, --更新客户端
--     "isUpdate":true,  -- Lua更新
--     "latestVersion":"1.9",
    ---更新列表
--     "updateResources":[
--         {
--             "resUrl":"http://d.laiyagame.com/jinping/res/1.9.1",
--             "version":"1.9.1"
--         }.
--         {
--             "resUrl":"http://d.laiyagame.com/jinping/res/1.9.2",
--             "version":"1.9.2"
--         }
--     ],
--     "url":"www"
-- }
function LoadingScene:checkClient(tb)
    if tb.TAG == 0 then
        --是否整包更新
        local isForceUpdate = tb.isForceUpdate
        local url = tb.Url
        if isForceUpdate then
            print("整包更新")
            local update = require("app.game.ui.LoginSceneLayer.LoadingUpdate").new(url)
            g_SMG:addLayerByName(update)
            -- device.openURL(url)
            -- app:exit()
            return
        end
        local IsUpdate = tb.IsUpdate
        if IsUpdate then
            print("更新lua")
            self.total = #tb.updateResources
            for i,v in ipairs(tb.updateResources) do
                g_thunder:addTask(v.version, v.resUrl)
            end
            return
        end
    else
        --提审服务器
        -- g_GameConfig.URL     = "http://apiqdn.laiyagame.com:56492"
        g_GameConfig.isGuest = true
        g_GameConfig.isiOSAppCheck = false --ios提审时把它设置为true
        print("游客登录")
    end
    self:run_m_tickSchedule()
end

function LoadingScene:httpSuccess(response, _tag)
    g_http.unlisteners("LoadingScene")
    print("httpSuccess", _tag)
    if not response then
        print("ERROR _response 没有数据")
        return
    end

    local ok = false
    for i=1,1 do
         if REQ_CLIENT == _tag then
            --不保存本地，直接读取
            local tb = json.decode(response)
            printTable("tb",tb)
            if not tb then break end
             self:checkClient(tb)
        end

        ok = true
    end
    --失败处理
    if not ok then
        self:httpFail({code="101", response=""}, _tag)
    end
end

--http失败
function LoadingScene:httpFail(response, _tag)
    print("httpFail", response, _tag)

    local LayerTipError = g_UILayer.Common.LayerTipError.new("无法连接网络,\n请检查的网络连接",true)
    g_SMG:addLayer(LayerTipError)
end

function LoadingScene:downFun( _event, _task)
    local TASK_RUN = g_thunder.TASK_RUN
    if TASK_RUN == _event then --下载中，进度
        local  kbmax  = _task.kbmax
        local  kbnum  = _task.kbnum
        print("kbmax = ",kbmax,"kbnum",kbnum)
        self:setLoadLabel(kbnum,kbmax)
        self:setProgressBar(kbnum,kbmax)
    elseif TASK_END == _event then --下载成功
    end
end

function LoadingScene:setLoadLabel(n,m)
    local c = self.total - #g_thunder.m_tasks
    local txt =  string.format("%d",n * 100 / m) .. "%".."("..c.."/"..self.total..")"
    self.m_ccbRoot.m_ProLabel:setString(txt)
end
return LoadingScene
