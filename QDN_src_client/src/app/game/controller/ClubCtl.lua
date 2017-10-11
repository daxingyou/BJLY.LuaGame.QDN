--
-- Author: Your Name
-- Date: 2017-08-28 11:52:41
--通讯协议


local ClubCtl = class("ClubCtl")

ClubCtl.eventName = {
    clubReflash = "clubReflash",
    clubSearch = "clubSearch",
    clubRecord = "clubRecord",
    clubRefresh = "clubRefresh",
    clubMembers = "getClubMembers",
}

function ClubCtl:ctor()
	self:init()
end

function ClubCtl:init()
    g_http.listeners(self.eventName.clubReflash,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.GET_CLUB_TABLE_LIST,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.QUIT_CLUB,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.REVOKE_CLUB,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.APPLY_CLUB,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.GET_CLUB,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.GET_PLAYER_CLUB,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(self.eventName.clubSearch,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(self.eventName.clubRecord,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(self.eventName.clubRefresh,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(self.eventName.clubMembers,handler(self, self.httpSuccess),handler(self, self.httpFail))
   
end

function ClubCtl:httpSuccess(_response, _tag)
    g_SMG:removeWaitLayer()
    print("_response",_tag)
    if not _response then
        print("ERROR _response no data")
        return
    end

    local ok = false
    for i=1,1 do
    	local tb = json.decode(_response)
    	printTable("GET_CLUB-00000--",tb)
        if not tb then break end
        if tb.ResultCode == -1 then
			local LayerTipError = g_UILayer.Common.LayerTipError.new(tb.ErrMsg)
			g_SMG:addLayer(LayerTipError)
            return
        end
        if g_httpTag.GET_PLAYER_CLUB == _tag then
            local layer = g_UILayer.Main.UIMyClub.new(tb.Data)
            g_SMG:addLayer(layer)
    		printTable("GET_PLAYER_CLUB---",tb)
        elseif g_httpTag.GET_CLUB == _tag then
    		printTable("GET_CLUB---",tb)
            local layer = g_UILayer.Club.ClubInfo.new(tb.Data)
            g_SMG:addLayer(layer)
        elseif g_httpTag.APPLY_CLUB == _tag then
        	self.applyHandler(tb)
        elseif g_httpTag.QUIT_CLUB == _tag then
            g_SMG:removeWaitLayer()
            g_SMG:removeLayer()
            g_SMG:removeLayer()
            g_SMG:removeLayer()
            local LayerTipError = g_UILayer.Common.LayerTipError.new(tb.Msg)
            g_SMG:addLayer(LayerTipError)
        elseif g_httpTag.REVOKE_CLUB == _tag then
        	self.revokHandler(tb)
        elseif g_httpTag.GET_CLUB_TABLE_LIST == _tag then
            printTable("GET_CLUB_TABLE_LIST---",tb)
            g_SMG:addLayer(g_UILayer.Club.ClubMain.new(tb.Data))
        elseif self.eventName.clubSearch == _tag then
            printTable("self.eventName.clubSearch",tb)
        	self.handler_search(tb.Data)
         elseif self.eventName.clubRecord == _tag then
        	--添加记录
        	local layer = g_UILayer.Main.UIClubRecord.new(tb.Data)
        	g_SMG:addLayer(layer)
        elseif self.eventName.clubReflash == _tag then
            printTable("self.eventName.clubReflash---",tb)
            g_msg:post(g_msgcmd.UI_Club_Reflash,tb.Data)
        elseif self.eventName.clubRefresh == _tag then
            self.hander_refreshClub(tb.Data)
        elseif self.eventName.clubMembers == _tag then
            self.handler_getclubmembers(tb.Data)
        end
        ok = true
    end
    --失败处理
    if not ok then
        dump(_response,"---json.decode(_response)---")
        self:httpFail({code="101", response=""}, _tag)
    end
end
function ClubCtl:getClubMembers(_args)
    self.handler_getclubmembers = _args.click_hander
    self:httpPost(g_httpTag.GET_PLAYER_CLUBMEMBERS,{clubCode = _args.clubCode},self.eventName.clubMembers,self.eventName.clubMembers)
end
function ClubCtl:httpFail(_response, _tag)
    g_SMG:removeWaitLayer()
    print("httpFail", _response, _tag)
    printTable("_response",_response)
end

function ClubCtl:getPlayerClub()
   self:httpPost(g_httpTag.GET_PLAYER_CLUB,{UserID = g_data.userSys.UserID},g_httpTag.GET_PLAYER_CLUB,g_httpTag.GET_PLAYER_CLUB)
end
function ClubCtl:rereshMyClub(_args)
	self.hander_refreshClub = _args.click_hander
	self:httpPost(g_httpTag.GET_PLAYER_CLUB,{UserID = g_data.userSys.UserID},self.eventName.clubRefresh,self.eventName.clubRefresh)
end
function ClubCtl:searchClubByClubCode(_args)
	--查询俱乐部信息
	self.handler_search = _args.clickHandle
	self.clubCode  = _args.club_code
    print("self.clubCode",self.clubCode)
	self:httpPost(g_httpTag.GET_CLUB,{clubCode = self.clubCode , ignoreUser = true},self.eventName.clubSearch,self.eventName.clubSearch)
end
function ClubCtl:httpPost(urlTag,data,responseTag,subTag)
    g_SMG:addWaitLayer()
    data.accessKey = g_data.userSys.accessKey
    data.DeviceID = g_data.userSys.openid
    data.UserID = g_data.userSys.UserID
    dump(data,"---httpPostData---")
    g_http.POST(g_GameConfig.URL .. urlTag,data,responseTag,subTag)
end

function ClubCtl:getClubInfo(clubCode)
 	self:httpPost(g_httpTag.GET_CLUB,{clubCode = clubCode},g_httpTag.GET_CLUB,g_httpTag.GET_CLUB)
end

function ClubCtl:applyClub(_args)
    local args = {clubCode = _args.code}
    self.applyHandler = _args.click_hander
    self:httpPost(g_httpTag.APPLY_CLUB,args,g_httpTag.APPLY_CLUB,g_httpTag.APPLY_CLUB)
end
function ClubCtl:quitClub(clubCode)
    local args = {clubCode = clubCode}
    self:httpPost(g_httpTag.QUIT_CLUB,args,g_httpTag.APPLY_CLUB,g_httpTag.QUIT_CLUB)
end

function ClubCtl:revokeClub(_args)
    local args = {clubCode = _args.code}
    self.revokHandler= _args.click_hander
    self:httpPost(g_httpTag.REVOKE_CLUB,args,g_httpTag.APPLY_CLUB,g_httpTag.REVOKE_CLUB)
end

function ClubCtl:getClubTableList(clubCode)
    local args = {clubCode = clubCode}
    self:httpPost(g_httpTag.GET_CLUB_TABLE_LIST,args,g_httpTag.GET_CLUB_TABLE_LIST,g_httpTag.GET_CLUB_TABLE_LIST)
end

function ClubCtl:getClubTableListReflash(clubCode)
    local args = {clubCode = clubCode}
    self:httpPost(g_httpTag.GET_CLUB_TABLE_LIST,args,self.eventName.clubReflash,self.eventName.clubReflash)
end
function ClubCtl:getRecord()
	self:httpPost(g_httpTag.GET_PLAYER_CLUB,{UserID = g_data.userSys.UserID},self.eventName.clubRecord,self.eventName.clubRecord)
end
return ClubCtl