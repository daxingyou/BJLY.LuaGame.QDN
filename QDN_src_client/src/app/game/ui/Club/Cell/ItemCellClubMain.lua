--
-- Author: Your Name
-- Date: 2017-08-28 15:07:38
--

local ccbFile = "csb/ItemCellCsd/CellItemClubRoom.csb"
local M = class("ItemCellClubMain", function()
    return cc.Layer:create()
end)

local STATE = {
    NoCardingNoSelf = 1,
    NoCardingSelf = 2,
    CardingNoSelf = 3,
    CardingSelf = 4,
}


function M:ctor(_cfg)
    self._tableInfo = _cfg
	self._playerHead = {}
	self._playerName = {}
	self._playerWait = {}
	self:init()
    if self.scheduler_tick == nil then
       self.scheduler_tick = self:schedule(function() self:updateHeadImg(0.1) end, 0.1)
    end
end

function M:init()
    local _UI = cc.uiloader:load(ccbFile)
    _UI:addTo(self)
    self:setContentSize(_UI:getContentSize())

    for i=1,4 do
    	self._playerHead[i] = _UI:getChildByName("spriteHead" .. i)
    	self._playerName[i] = _UI:getChildByName("txtName" .. i)
    	self._playerWait[i] = _UI:getChildByName("txtWaitPlayer" .. i)
        if i > self._tableInfo.user_limit then
            self._playerHead[i]:setVisible(false)
            self._playerName[i]:setVisible(false)
            self._playerWait[i]:setVisible(false)
        elseif i > table.getn(self._tableInfo.user_info) then
            self._playerName[i]:setVisible(false)
        else
            self._playerWait[i]:setVisible(false)
            self._playerName[i]:setString(self._tableInfo.user_info[i]["nick_name"])
            self._playerHead[i]:setTag(self._tableInfo.user_info[i]["user_id"])
        end
    end

    _UI:getChildByName("txtRoomID"):setString("房间号：" .. self._tableInfo.table_id)
    local txtRuleName = _UI:getChildByName("txtRuleName")
    local value = self._tableInfo.region_label .. "/" .. self._tableInfo.table_type_label
    txtRuleName:setString(value)
    local txtRuleValue = _UI:getChildByName("txtRuleValue")
    value = self._tableInfo.round_num_label
    if string.len(self._tableInfo.death_by_light_label) > 0 then
        value = value .. "/" .. self._tableInfo.death_by_light_label
    end
    if string.len(self._tableInfo.gang_label) > 0 then
        value = value .. "/" .. self._tableInfo.gang_label
    end
    if string.len(self._tableInfo.additional_label) > 0 then
        value = value .. "/" .. self._tableInfo.additional_label
    end
    if string.len(self._tableInfo.supplement_price_label) > 0 then
        value = value .. "/" .. self._tableInfo.supplement_price_label
    end
    txtRuleValue:setString(value)

    --下载头像
    for i= 1 ,#self._tableInfo.user_info do
        local path = device.writablePath..self._tableInfo.user_info[i].user_id..".png"
        if FileUtils.file_exists(path) == true then--已经存在就直接复制
            for j=1,#self._playerHead do
                if self._playerHead[j]:getTag() == self._tableInfo.user_info[i].user_id then
                    self._playerHead[j]:setTexture(path)
                    self._playerHead[j]:setScale(77.0/self._playerHead[j]:getContentSize().width)
                end
            end
        else
            if string.len(self._tableInfo.user_info[i].user_face_img_url)  >= 10 then
               g_http.Download(self._tableInfo.user_info[i].user_face_img_url,tostring(self._tableInfo.user_info[i].user_id),tostring(self._tableInfo.user_info[i].user_id),path)
            end
        end    
    end
    self._state = STATE.NoCardingNoSelf

    local isInRoom = false
    for i= 1 ,#self._tableInfo.user_info do
        if self._tableInfo.user_info[i].user_id == g_data.userSys.UserID then
            isInRoom = true
            break
        end
    end
    -- table_status 0未开始 1开始了
    if self._tableInfo.table_status == 0 then
        if isInRoom then
            self._state = STATE.NoCardingSelf
        else
            self._state = STATE.NoCardingNoSelf
        end
    else
        if isInRoom then
            self._state = STATE.CardingSelf
        else
            self._state = STATE.CardingNoSelf
        end
    end

    local btnJoinRoom = _UI:getChildByName("btnJoinRoom")
    g_utils.setButtonClick(btnJoinRoom,handler(self,self.onBtnClick))

    local txtCarding = _UI:getChildByName("txtCarding")
    if self._state == STATE.NoCardingSelf or self._state == STATE.CardingSelf then
        btnJoinRoom:loadTextures("res/srcRes/LobbyScene/btn_fhfj.png","res/srcRes/LobbyScene/btn_fhfj.png","res/srcRes/LobbyScene/btn_fhfj.png")
        txtCarding:setVisible(false)
    elseif self._state == STATE.NoCardingNoSelf then
        txtCarding:setVisible(false)
    elseif self._state == STATE.CardingNoSelf then
        btnJoinRoom:setVisible(false)
    end

end

function M:onBtnClick(_sender)
    local s_name = _sender:getName()
    if s_name == "btnJoinRoom" then
        if self._state == STATE.NoCardingNoSelf then
            g_SMG:addWaitLayer()
            local tableID = self._tableInfo.table_id
            g_LobbyCtl:enterRoom(tableID)
        else
            local returnRoom = require("app.game.ui.room.ReturnRoom").new()
            returnRoom:addTo(self)
        end
    end
end

function M:updateHeadImg(dt)
    for i= 1 ,#self._tableInfo.user_info do
        local path = device.writablePath..self._tableInfo.user_info[i].user_id..".png"
        if FileUtils.file_exists(path) == true then--已经存在就直接复制
            for j=1,#self._playerHead do
                if self._playerHead[j]:getTag() == self._tableInfo.user_info[i].user_id then
                    self._playerHead[j]:setTexture(path)
                    self._playerHead[j]:setScale(77.0/self._playerHead[j]:getContentSize().width)
                end
            end
        end   
    end
end

function M:onCleanup()
    print("cleanup------")
    if self.scheduler_tick then
        self:stopAction(self.scheduler_tick)
        self.scheduler_tick = nil
    end 
end



return M