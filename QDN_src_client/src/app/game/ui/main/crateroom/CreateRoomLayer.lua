
--[[
    --创建房间
]]--
local ccbfile = "ccb/createRoom.ccbi"

local TianZhuRule = require("app.game.ui.main.crateroom.TianZhuRule")
local JinPingRule = require("app.game.ui.main.crateroom.JinPingRule")
local LiPingRule = require("app.game.ui.main.crateroom.LiPingRule")
local Layer_delegatesuccess = require("app.game.ui.main.LayerDelegateSuccess")

local CreateRoomLayer = class("CreateRoomLayer", function()
   local node = require("app.common.ui.UILockLayer").new()
    node:setNodeEventEnabled(true)
    return node
end)
local Http_Tag_Fefresh        = "Http_Tag_Fefresh" --刷新
function CreateRoomLayer:ctor(_cfg)

  
    _cfg = _cfg or {}
    printTable("_cfg = ",_cfg)
    self.m_clubInfo = _cfg

    --添加网络监听
    g_http.listeners("CreateRoomLayer",handler(self, self.httpSuccess),handler(self, self.httpFail))
    self:load_ccb()

    
    self:initUI()

    -- if self.clubCode then
    --   local code = string.len(self.clubCode)
    --   if code > 2 then
    --     self:initClubInfo()
    --   end
    -- end
    self:initClubInfo()
end

--设置俱乐部信息
function CreateRoomLayer:initClubInfo()

  if self.m_clubInfo.isClub then
    self.m_ccbRoot.m_club_line:setVisible(true)
    self.m_ccbRoot.m_clubName:setString(self.m_clubInfo.name)
    self.m_ccbRoot.m_club_diamond:setString(self.m_clubInfo.bigGold)
    local str = self.m_clubInfo.enoughLevel == 1 and "充足" or "不足"
    self.m_ccbRoot.m_clubState:setString(str)
    if self.m_clubInfo.enoughLevel == 0 then
      self.m_ccbRoot.m_clubState:setColor(cc.c3b(219, 45, 15))
    end
  else
    self.m_ccbRoot.m_club_line:setVisible(false)
  end
end

--清理
function CreateRoomLayer:onCleanup()
     g_http.unlisteners("CreateRoomLayer")
end

function CreateRoomLayer:load_ccb()
    self.m_ccbRoot = {
        ["onRuleClick"]        = function(_sender, _event) self:onRuleClick(_sender, _event) end,
        ["onClosed"]           = function(_sender, _event) self:onClosed(_sender, _event) end,
        ["onCreate"]           = function(_sender, _event) self:onCreate(_sender, _event) end,
        ["onCreateDelegate"]   = function(_sender, _event) self:onCreateDelegate(_sender, _event) end,
        ["onProxyInfo"]        = function(_sender, _event) self:onDelegateInfo(_sender, _event) end,
    }
    local proxy = cc.CCBProxy:create()
    local node  =  CCBReaderLoad(ccbfile, proxy, self.m_ccbRoot)
    node:addTo(self)
end

 --初始化ui
function CreateRoomLayer:initUI()
    self.m_rules = {}

    local jinping = JinPingRule.new()
    jinping:addTo(self)
    jinping:setVisible(false)
    local liping  = LiPingRule.new()
    liping:addTo(self)
    liping:setVisible(false)
    local tianzhu = TianZhuRule.new()
    tianzhu:addTo(self)
    tianzhu:setVisible(false)

    self.m_rules[1] = jinping
    self.m_rules[2] = liping
    self.m_rules[3] = tianzhu

    if self.m_clubInfo.isClub then
      for i = 1,3 do
        self.m_rules[i]:setPositionY(self.m_rules[i]:getPositionY() - 60)
      end
    end

    self.curretnbtn  = nil
    self.currentRule = nil
    
    local table_style = g_LocalDB:read("tableregion")
    if table_style == 1 then
        self:onRuleClick(self.m_ccbRoot.m_btn_4d)
    elseif table_style == 2  then
        self:onRuleClick(self.m_ccbRoot.m_btn_3d)
    elseif table_style == 3 then
        self:onRuleClick(self.m_ccbRoot.m_btn_2d)
    end 

    if g_data.userSys.isdelegate == 0 or self.m_clubInfo.isClub then--不能代开房间
        self.m_ccbRoot.m_DelegateInfo_button:setVisible(false)
        self.m_ccbRoot.m_Delegate_button:setVisible(false)
    end

    -- if g_GameConfig.isiOSAppCheck then
    --     self.m_ccbRoot.m_diamond1:setVisible(false)
    --     self.m_ccbRoot.m_diamond2:setVisible(false)
    --     self.m_ccbRoot.m_2:setVisible(false)
    --     self.m_ccbRoot.m_3:setVisible(false)
    -- end
end

--选择地方
function CreateRoomLayer:onRuleClick( _sender, _event)
    self.tb = {}
    local  table_style = _sender:getTag()
    g_LocalDB:save("tableregion", table_style)
    if self.currentRule then
        self.currentRule:setVisible(false)
    end
    self.currentRule = self.m_rules[table_style]
    self.currentRule:setVisible(true)
    if self.curretnbtn then
        self.curretnbtn:setEnabled(true)
    end
    self.curretnbtn = _sender
    self.curretnbtn:setEnabled(false)
end

function CreateRoomLayer:onCreate( _sender, _event )
   g_data.roomSys.m_roomInfo.ReplaceTable = 0
   self.tb = self.currentRule:getRule()
   self.tb.accessKey = g_data.userSys.accessKey
   self.tb.DeviceID = g_data.userSys.openid
   self.tb.UserID   =  g_data.userSys.UserID
   self.tb.clubCode = self.m_clubInfo.code
   self.tb.ReplaceTable = 0
   printTable("self.tb ==========",self.tb)
    local url =  g_GameConfig.URL.."/createroom"  -- 登陆
    self:performWithDelay(function()
         g_http.POST(url,self.tb,"CreateRoomLayer", "crtRoom")
         end, 0.1)
      g_SMG:addWaitLayer()
end

function CreateRoomLayer:onClosed( _sender, _event )
    print("==========关闭============")
    g_SMG:removeLayer()
end

function CreateRoomLayer:onDelegateInfo()
    local checktable = {
        accessKey = g_data.userSys.accessKey,
        DeviceID = g_data.userSys.openid,
        UserID =  g_data.userSys.UserID,
     }
     local url =  g_GameConfig.URL.."/getTableInfo"
       g_http.POST(url,checktable,"CreateRoomLayer", Http_Tag_Fefresh)
       g_SMG:addWaitLayer()
end
function CreateRoomLayer:onCreateDelegate(_sender)
    g_data.roomSys.m_roomInfo.ReplaceTable = 1
    self.tb = self.currentRule:getRule()
    self.tb.accessKey = g_data.userSys.accessKey
    self.tb.DeviceID = g_data.userSys.openid
    self.tb.UserID =  g_data.userSys.UserID
    self.tb.ReplaceTable = 1
    local url =  g_GameConfig.URL.."/createroom"  -- 登陆
    self:performWithDelay(function()
            g_http.POST(url,self.tb,"CreateRoomLayer", "crtRoom")
        end, 0.1)
     g_SMG:addWaitLayer()
end

--http成功
function CreateRoomLayer:httpSuccess(_response, _tag)
    print("httpSuccess", _tag)
    if not _response then
        print("ERROR _response 没有数据")
        return
    end

    local ok = false
    for i=1,1 do
        --请求客户端版本
        if "crtRoom" == _tag then
            g_SMG:removeWaitLayer() 
            print("====创建房间成功")
            --不保存本地，直接读取
            local tb = json.decode(_response)
            printTable("response_tb", tb)
            if not tb then break end

            if tb.ResultCode == -1 then
                local LayerTipError = g_UILayer.Common.LayerTipError.new(tb.ErrMsg)
                g_SMG:addLayer(LayerTipError)
                return
            end
            if tb.ResultCode == 3 then
                local LayerTipError = g_UILayer.Common.LayerTipError.new(tb.ErrMsg)
                g_SMG:addLayer(LayerTipError)
                return
            end
            g_GameConfig.kServerAddr = tb.Host
            g_GameConfig.kServerPort = tb.Port
            g_data.roomSys.kTableID  = tb.TableID
            g_GameConfig.kSeatID     = tb.SeatID
            g_data.roomSys.Owner     = tb.Owner
            self.tb.roomId           = tb.TableID
            self.tb.club_code        = tb.club_code
            self.tb.clubName         = tb.clubName
            
            g_data.roomSys:updateGameRule(self.tb)
            if g_data.roomSys.m_roomInfo.ReplaceTable == 1 then--此房间是代开的
                print("代开成功 代开的房间号是",tb.TableID)
              
                local layer_delegatesuceess=Layer_delegatesuccess.new(self.tb)
                g_SMG:addLayer(layer_delegatesuceess)
                return
            end
            g_netMgr:connectGameServer()
            
        elseif Http_Tag_Fefresh == _tag then
            printTable("tb========",tb)
            local tb = json.decode(_response)
            printTable("response_tb", tb)
            if not tb then break end
            if tb.ResultCode ~= 0 then
            local LayerTipError = g_UILayer.Common.LayerTipError.new(tb.ErrMsg)
            g_SMG:addLayer(LayerTipError)
                return
            end
               local layer = g_UILayer.Main.UIDelegateRoomLsyer.new(tb)
               g_SMG:addLayer(layer)
               g_SMG:removeWaitLayer()
        end
        ok = true
    end
    --失败处理
    if not ok then
        self:httpFail({code="101", response=""}, _tag)
    end
end


--http失败
function CreateRoomLayer:httpFail(_response, _tag)
    g_SMG:removeWaitLayer()
    print("httpFail", _response, _tag)
    printTable("_response",_response)
end

return CreateRoomLayer