--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/CellitemRecordDetail.csb"

local CellitemRecordDetail = class("CellitemRecordDetail", function()
    return cc.Layer:create()
end)

function CellitemRecordDetail:ctor(_cfg)
    self._cfg = _cfg
    self.index = _cfg.index
    print("selfidnex=======",self.index)
    self:initUI() 
end

 --初始化ui
function CellitemRecordDetail:initUI()
    self.subControlName = {"tx_num","tx_roomid"}
    self.subControl = {}
    self:loadCCB()
end

--加载ui文件
function CellitemRecordDetail:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    self:setContentSize(_UI:getContentSize())
    self.buton=_UI:getChildByName("Button_1")

    for i =1 ,#self.subControlName do
        local  _name = self.subControlName[i]
        local _ctl = self.buton:getChildByName(_name)

        self.subControl[_name] = _ctl

    end
    self.bankerNick = self.buton:getChildByName("tx_roomid_0") 
    if self._cfg then
        self:setData(self._cfg)
    end
    self.button_click=_UI:getChildByName("Button_34")

    g_utils.setButtonClick(self.button_click,handler(self,self.onBtnClick))
    
  
end

function CellitemRecordDetail:onBtnClick( _sender )
    print("clickbt_index------------------------------------------",self.index)
    --根据传过来的局数和roomid初始化次级历史界面
    if self.clickHandle then
        self.clickHandle(self.index)
    end
end

function CellitemRecordDetail:setClickHandle( clickHandle)
    self.clickHandle = clickHandle
end


function CellitemRecordDetail:setData( dataTable )
    dump(dataTable,"----------dasfasf======777==",self._cfg)
    if dataTable.RoomID then
        self.subControl[self.subControlName[2]]:setString(dataTable.RoomID)
    end
    ------------------------标号--------------------------------------------
    --self.subControl[self.subControlName[1]]:setString(dataTable.index)
    local title_name = {"第一局","第二局","第三局","第四局","第五局","第六局","第七局","第八局",

    }
    self.subControl[self.subControlName[1]]:setString(title_name[dataTable.index])
    -------房主昵称-----------------------------------------------------
    if dataTable.bankerNickList ~=nil then
        self.bankerNick:setString(dataTable.bankerNickList[dataTable.index])
    end
end


return CellitemRecordDetail