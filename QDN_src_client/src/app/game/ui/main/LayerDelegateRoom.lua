--[[
    --回馈界面
]]--
local ccbFile = "csb/LobbyView/layer_delegateroom.csb"
local CellItemDelegateRoom = require("app.game.ui.main.CellItem.CellItemDelegateRoom")

local LayerDelegateRoom = class("LayerDelegateRoom", function()
    local node = cc.Layer:create()
    node:setNodeEventEnabled(true)
    return node
end)
local Http_Tag_Fefresh        = "Http_Tag_Fefresh" --刷新
local Http_Tag_Dissmiss       = "Http_Tag_Dissmiss"--解散
function LayerDelegateRoom:ctor(_cfg)
    printTable("here==============",_cfg)
    self.type = 1 -- 1 代开房间模式 2 代开记录模式
    self.data_on ={}
    self.data_over = {}
    self:regEvent()
    self.data = _cfg.Data
    self:loadCCB()
    self:initUI() 
    print("here=1=============")
end
function LayerDelegateRoom:regEvent()
    g_http.listeners("LayerDelegateRoom",
        handler(self, self.httpSuccess),
        handler(self, self.httpFail))
end
function LayerDelegateRoom:onCleanup()
    self:unregEvent()
end
function LayerDelegateRoom:unregEvent()
    g_http.unlisteners("LayerDelegateRoom")
end
function LayerDelegateRoom:httpSuccess(response, _tag)
    print("go==========")
    g_SMG:removeWaitLayer()
    if not response then
        print("ERROR _response 没有数据")
        return
    end
    
    if Http_Tag_Fefresh == _tag then
        local tb = json.decode(response)
        printTable("tb=========",tb)
       
        if not tb then return end
        self.data ={}
        self.data_on ={}
        self.data_over ={}

        self.data = tb.Data
        
        self:initUI()
    elseif Http_Tag_Dissmiss == _tag then
        local tb = json.decode(response)
        printTable("tb",tb)
        if not tb then return end
        --处理当前解散代理房间之后
        local ResultCode = tb.ResultCode 
        if ResultCode == 0 then
            --成功了
            local data = tb.Data
            local LayerTipError = g_UILayer.Common.LayerTipError.new(data)
            g_SMG:addLayer(LayerTipError)
            --刷新
            local function RequestFrefresh()
               local checktable = {
                accessKey = g_data.userSys.accessKey,
                DeviceID = g_data.userSys.openid,
                UserID =  g_data.userSys.UserID,
                }
                local url =  g_GameConfig.URL.."/getTableInfo"
                g_http.POST(url,checktable,"LayerDelegateRoom", Http_Tag_Fefresh)
            end
            self:performWithDelay(RequestFrefresh, 0.5)
            g_SMG:addWaitLayer()

           
        elseif ResultCode == -1 then
            --失败了
            local errormsg = tb.ErrMsg 
            local LayerTipError = g_UILayer.Common.LayerTipError.new(errormsg)
            g_SMG:addLayer(LayerTipError)
            print("dissmissfailed!")
        end
    end
end

function LayerDelegateRoom:httpFail(response, _tag)
    g_SMG:removeWaitLayer()
    if _tag == Http_Tag_Fefresh then
        print("request fresh failed ------------")
    end
end
 --初始化ui
function LayerDelegateRoom:initUI()
    --把当前的数据分成正在进行的和已经完成的

    local  on = 1
    local  over = 1
    
    for i=1,#self.data do
        if self.data[i].table_status == 0 or self.data[i].table_status == 1  then --还没开始或者正在进行
           self.data_on[on] = self.data[i]
           on = on + 1
           print("on=====",on)
        else
           self.data_over[over] =self.data[i]
           over = over + 1
           print("over=====",over)
        end
    end
    
    self.list1 = self.root:getChildByName("ListView_1")
    self.list2 = self.root:getChildByName("ListView_1_0")

    self.list1:removeAllItems()
    self.list2:removeAllItems()
    
    printTable("over_data",self.data_on)
    for i=1,#self.data_on do
        local  data = self.data_on[i]
         printTable("data_data",data)
        local cell = CellItemDelegateRoom.new(data)
        local function cellClickHandle( id )--点击解散回调
                --请求解散
        g_SMG:addWaitLayer()
        local creat_tabel =
        {
            accessKey = g_data.userSys.accessKey,
            DeviceID = g_data.userSys.openid,
            UserID =  g_data.userSys.UserID,
            TableID = id,
        }
        local url =  g_GameConfig.URL.."/recoveryTable"  -- 登陆
        self:performWithDelay(function()
                g_http.POST(url,creat_tabel,"LayerDelegateRoom",Http_Tag_Dissmiss)
            end, 0.1)
        end
        cell:setClickHandle(cellClickHandle)
        local layout = ccui.Layout:create()
        layout:setTouchEnabled(true)
        layout:setContentSize(cc.size(980, 190))--(cell:getContentSize()) 
        layout:addChild(cell)
        self.list1:pushBackCustomItem(layout)
    end 
    
    for i=1,#self.data_over do
        local  data = self.data_over[i]
        printTable("data_data---------",data)
        local cell = CellItemDelegateRoom.new(data)
        printTable("data_data33333---------",data)
        cell:setType(0)--设置邀请和解散按钮不可见
        local layout = ccui.Layout:create()
        layout:setTouchEnabled(true)
        layout:setContentSize(cc.size(980, 190))--(cell:getContentSize()) 
        layout:addChild(cell)
        self.list2:pushBackCustomItem(layout)
    end
    self:changeType(self.type)
end
function LayerDelegateRoom:changeType(_type)
    if _type == 1 then
        self.list1:setVisible(true)
        self.list2:setVisible(false)
        self.button_daikai:loadTextures("images/delegateRoom/title_ykf_checked.png","images/delegateRoom/title_ykf_checked.png","images/delegateRoom/title_ykf_checked.png")
        self.button_jilu:loadTextures("images/delegateRoom/title_dkjl.png","images/delegateRoom/title_dkjl.png","images/delegateRoom/title_dkjl.png")
        self.button_daikai:setLocalZOrder(11)
        self.button_jilu:setLocalZOrder(10)
    else
        self.list1:setVisible(false)
        self.list2:setVisible(true)
        self.button_daikai:loadTextures("images/delegateRoom/title_ykfj.png","images/delegateRoom/title_ykfj.png","images/delegateRoom/title_ykfj.png")
        self.button_jilu:loadTextures("images/delegateRoom/title_dkjl_checked.png","images/delegateRoom/title_dkjl_checked.png","images/delegateRoom/title_dkjl_checked.png")
        self.button_daikai:setLocalZOrder(10)
        self.button_jilu:setLocalZOrder(11)
        
    end
end
--加载ui文件
function LayerDelegateRoom:loadCCB()
    print("00000000···",csbfile)

    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    print("111111···")
    self.root = _UI
    self.button_refresh = _UI:getChildByName("Button_daikaijilu_0")
    g_utils.setButtonClick(self.button_refresh,handler(self,self.onBtnClick))

    self.button_daikai = _UI:getChildByName("Button_daikaifangjian")
    g_utils.setButtonClick(self.button_daikai,handler(self,self.onBtnClick))

    self.button_jilu = _UI:getChildByName("Button_daikaijilu")
    g_utils.setButtonClick(self.button_jilu,handler(self,self.onBtnClick))
    print("2222222")

    self.Button_exit = _UI:getChildByName("Button_exit")
    g_utils.setButtonClick(self.Button_exit,handler(self, self.onBtnClick))

end
function LayerDelegateRoom:onBtnClick(_sender)
    local name = _sender:getName()
    if name == "Button_daikaijilu_0" then
        local checktable = {
        accessKey = g_data.userSys.accessKey,
        DeviceID = g_data.userSys.openid,
        UserID =  g_data.userSys.UserID,
     }
       local url =  g_GameConfig.URL.."/getTableInfo"
       g_http.POST(url,checktable,"LayerDelegateRoom", Http_Tag_Fefresh)
       g_SMG:addWaitLayer()
    elseif name == "Button_daikaifangjian" then
        self.type = 1 
       self:changeType(1)
    elseif name == "Button_daikaijilu" then
        self.type = 2 
       self:changeType(2)
    elseif name == "Button_exit" then
        g_SMG:removeLayer()
    end
end


return LayerDelegateRoom