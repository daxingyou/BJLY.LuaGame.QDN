--[[
    --回馈界面
]]--
local ccbFile = "csb/ItemCellCsd/ItemCellChat.csb"

local m = class("ItemCellChat", function()
    return cc.Layer:create()
end)

function m:ctor(_cfg)
    self._txt = _cfg.txt
    self._index = _cfg.index
    self._clickHandle = _cfg.clickHandle
    self:initUI()
end

 --初始化ui
function m:initUI()
    self:loadCCB()
end

--加载ui文件
function m:loadCCB()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    self:setContentSize(_UI:getContentSize())

    local txt_word = _UI:getChildByName("txt_word")
    txt_word:setString(self._txt)
    g_utils.setCellButtonClick(self,handler(self,self.onBtnClick))
end

function m:onBtnClick( _sender ) 
    if self._clickHandle then
        self._clickHandle(self._index)
    end
end



return m