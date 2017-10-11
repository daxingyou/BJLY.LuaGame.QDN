--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/CellItemRecord.csb"

local CellItemRecord = class("CellItemRecord", function()
    return cc.Layer:create()
end)

function CellItemRecord:ctor(_cfg)
    self._cfg = _cfg
    printTable("table---------------------", self._cfg)
    self:initUI() 
end

 --初始化ui
function CellItemRecord:initUI()
    self.subControlName = {"tx_num","tx_roomid","tx_time","tx_name1","tx_name2","tx_name3","tx_name4","tx_score1","tx_score2","tx_score3","tx_score4"}

    self.subControl = {}
    self:loadCCB()
end

--加载ui文件
function CellItemRecord:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    self:setContentSize(_UI:getContentSize())
    --self.buton=_UI:getChildByName("Button_1")

    for i =1 ,#self.subControlName do
        local  _name = self.subControlName[i]
        local _ctl = _UI:getChildByName(_name)
        self.subControl[_name] = _ctl
    end
    self.icon_fangzhu = {}
    for i=1,4 do
        local name = "bg_zhanji_landlord_"..i
        self.icon_fangzhu[i] = _UI:getChildByName(name)
    end
    if self._cfg then
        self:setData(self._cfg)
    end
    self.button_click=_UI:getChildByName("Button_34")

    g_utils.setButtonClick(self.button_click,handler(self,self.onBtnClick))

    
  
end

function CellItemRecord:onBtnClick( _sender )
    print("clickbt_index1111111111------------------------------------------")
    if self.clickHandle then
        self.clickHandle(self._cfg.index)
    end
end

function CellItemRecord:setClickHandle( clickHandle)
    self.clickHandle = clickHandle
end


function CellItemRecord:setData( dataTable )

    self.nicks ={}
    self.nicks[1] = dataTable.Nick0
    self.nicks[2] = dataTable.Nick1
    self.nicks[3] = dataTable.Nick2
    self.nicks[4] = dataTable.Nick3
-----------------------------是否是房主-------------------------------------
    for i=1,4 do
        if dataTable.ownerNick == self.nicks[i] and dataTable.ownerNick ~= nil then
           self.icon_fangzhu[i]:setVisible(true)
       else
           self.icon_fangzhu[i]:setVisible(false)
        end
    end
--------------------------------------------------------------------------
    if dataTable.RoomID then
        self.subControl[self.subControlName[2]]:setString(dataTable.RoomID)
    end
    if dataTable.Time then
        self.subControl[self.subControlName[3]]:setString(dataTable.Time)
    end
    -------------------------名字----------------------------------------- 

    if dataTable.Nick0 then
        self.subControl[self.subControlName[4]]:setString(dataTable.Nick0)
    else
        self.subControl[self.subControlName[4]]:setVisible(false)
    end
    if dataTable.Nick1 then
        self.subControl[self.subControlName[5]]:setString(dataTable.Nick1)
    else
        self.subControl[self.subControlName[5]]:setVisible(false)
    end
    if dataTable.Nick2 then
        self.subControl[self.subControlName[6]]:setString(dataTable.Nick2)
    else
        self.subControl[self.subControlName[6]]:setVisible(false)
    end
    if dataTable.Nick3 then
        self.subControl[self.subControlName[7]]:setString(dataTable.Nick3)
    else
        self.subControl[self.subControlName[7]]:setVisible(false)
    end
    ----------------分数--------------------------------------------
    if  dataTable.Record0 then
        self.subControl[self.subControlName[8]]:setString(dataTable.Record0)
    else
        self.subControl[self.subControlName[8]]:setVisible(false)
    end
    if  dataTable.Record1 then
        self.subControl[self.subControlName[9]]:setString(dataTable.Record1)
    else
        self.subControl[self.subControlName[9]]:setVisible(false)
    end
    if  dataTable.Record2 then
        self.subControl[self.subControlName[10]]:setString(dataTable.Record2)
    else
        self.subControl[self.subControlName[10]]:setVisible(false)
    end
    if  dataTable.Record3 then
        self.subControl[self.subControlName[11]]:setString(dataTable.Record3)
    else
        self.subControl[self.subControlName[11]]:setVisible(false)
    end
    ------------------------标号--------------------------------------------
    --self.subControl[self.subControlName[1]]:setString(self._cfg.index)
    
end


return CellItemRecord