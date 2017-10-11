--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/CellItemMsg.csb"

local CellItemMsg = class("CellItemMsg", function()
    return cc.Layer:create()
end)

function CellItemMsg:ctor(_cfg)
    self._cfg = _cfg
    self:initUI() 
end

 --初始化ui
function CellItemMsg:initUI()
    self:loadCCB()
end

--加载ui文件
function CellItemMsg:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    self:setContentSize(_UI:getContentSize())
   
    self._mapCtlNameValue = {
        txt_dateTime = "createTime",
        txt_msgTitle = "title",
        txt_msgContent = "content",
        id = "id",
    }

    self._subControl = {}
    for k,v in pairs(self._mapCtlNameValue) do
        print(k,v)
        local _ctl = _UI:getChildByName(k)
        if _ctl then
            _ctl:setString(self._cfg[v])
        end
        self._subControl[k] = _ctl
    end
    g_utils.setButtonClick(self._subControl["txt_msgContent"],handler(self,self.onBtnClick))
    self._subControl["txt_msgContent"]:setSwallowTouches(false)
end

function CellItemMsg:onBtnClick( _sender )
    local s_name = _sender:getName()
    if self.clickHandle then
        self.clickHandle(self._cfg.id)
    end
end

function CellItemMsg:setClickHandle( clickHandle)
    self.clickHandle = clickHandle
end

return CellItemMsg