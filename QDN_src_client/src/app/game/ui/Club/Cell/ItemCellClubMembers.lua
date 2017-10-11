--
-- Author: Your Name
-- Date: 2017-08-28 15:07:38
--

local ccbFile = "csb/ItemCellCsd/CellItemMember.csb"
local ItemCellClubMembers = class("ItemCellClubMembers", function()
    return cc.Layer:create()
end)




function ItemCellClubMembers:ctor(_cfg)
    self._tableInfo = _cfg
	self:init()
    if self.scheduler_tick == nil then
       self.scheduler_tick = self:schedule(function() self:updateHeadImg(0.1) end, 0.1)
    end
end

function ItemCellClubMembers:init()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)

    self:setContentSize(_UI:getContentSize())



    self.spHead = _UI:getChildByName("spriteHead1")
    self.name = _UI:getChildByName("txtName1")
    self.data = _UI:getChildByName("txtName1_0")
      

    self.name:setString(self._tableInfo.nickName)
    self.data:setString(self._tableInfo.lastLoginDate)

end

function ItemCellClubMembers:updateHeadImg(dt)
        --下载头像
    local path = device.writablePath..self._tableInfo.userId..".png"

    if FileUtils.file_exists(path) == true then--已经存在就直接复制 
            self.spHead:setTexture(path)         
            self.spHead:setScale(57/self.spHead:getContentSize().width)
    else
        if string.len(self._tableInfo.headUrl)  >= 10 then
            g_http.Download(self._tableInfo.headUrl,tostring(self._tableInfo.headUrl),tostring(self._tableInfo.userId),path)
        end
    end  
end

function ItemCellClubMembers:onCleanup()
    if self.scheduler_tick then
        self:stopAction(self.scheduler_tick)
        self.scheduler_tick = nil
    end 
end



return ItemCellClubMembers