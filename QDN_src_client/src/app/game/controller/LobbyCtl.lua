--[[

]]

local m = class("LobbyCtl")
local n = {
	listenerTag = "LobbyCtl",
    loadActivityImg = "loadActivityImg",
    updateGoldNum = "updateGoldNum",
    shareWxCircle = "shareWxCircle",
}

function m:ctor()		
	self.subUIName = {
		UIActivity = "UIActivity",
		UIAddCard = "UIAddCard",
		UIBinding ="UIBinding",
		UIFeedback ="UIFeedback",
		UIJoinRoom ="UIJoinRoom",
		UICreateRoom ="UICreateRoom",
		UIMessage ="UIMessage",
		UIRecord ="UIRecord",
		UIRecordDetail ="UIRecordDetail",
		UIRule ="UIRule",
		UISelfInfo ="UISelfInfo",
		UISetting ="UISetting",
		UIShare ="UIShare",
	}
    self._needLoadImgNum = 0
    self._needLoadImgSum = 0
	self:init()
end

function m:init()
	g_http.listeners(self.subUIName.UISelfInfo,handler(self, self.httpSuccess),handler(self, self.httpFail))   
	g_http.listeners(self.subUIName.UIMessage,handler(self, self.httpSuccess),handler(self, self.httpFail))   
	g_http.listeners(self.subUIName.UIRecord,handler(self, self.httpSuccess),handler(self, self.httpFail))  
	g_http.listeners(self.subUIName.UIRecordDetail,handler(self, self.httpSuccess),handler(self, self.httpFail))
	g_http.listeners(g_httpTag.GET_CONTACT_INFO,handler(self, self.httpSuccess),handler(self, self.httpFail))
	g_http.listeners(g_httpTag.GET_ACTIVITY_PICLIST,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(n.loadActivityImg,handler(self, self.httpSuccessLoadImg),handler(self, self.httpFail))
    g_http.listeners(n.updateGoldNum,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(n.shareWxCircle,handler(self, self.httpSuccess),handler(self, self.httpFail))
    g_http.listeners(g_httpTag.ENTER_ROOM,handler(self, self.httpSuccess),handler(self, self.httpFail))
end
function m:httpSuccess(_response, _tag)
    print("_response",_tag)
    if not _response then
        print("ERROR _response no data")
        return
    end

    local ok = false
    for i=1,1 do
    	local tb = json.decode(_response)
        if not tb then break end
        if tb.ResultCode == -1 then
            g_SMG:removeWaitLayer()
        	print("----tb.--",tb.ResultCode)
            if _tag ~= self.subUIName.UIRecord then
                self:showErrorTxt(tb.ErrMsg)
             else
                local norecordLayer = g_UILayer.Main.UINoRecordLayer.new()
                norecordLayer:showNoRecordView()
                g_SMG:addLayer(norecordLayer)
            end
        	
            return
        end
        if self.subUIName.UISelfInfo == _tag then
        	tb.IP = g_data.userSys.IP
        	tb.InviteCode = g_data.userSys.InviteCode
        	tb.Nick = g_data.userSys.nickname
        	tb.UserID = g_data.userSys.UserID
            tb.headIconPath = device.writablePath .. g_data.userSys.UserID .. ".png"
        	g_SMG:addLayerByName(g_UILayer.Main.UISelfInfo.new(tb))
        elseif self.subUIName.UIMessage == _tag then
            g_SMG:addLayer(g_UILayer.Main.UIMessage.new(tb))
        elseif self.subUIName.UIRecord == _tag then
        	g_SMG:addLayer(g_UILayer.Main.UIRecord.new(tb))
        elseif self.subUIName.UIRecordDetail == _tag then
            -- g_SMG:addLayer(g_UILayer.Main.UIMessage.new(tb))
        elseif g_httpTag.GET_CONTACT_INFO == _tag then
        	g_data.userSys:saveContentInfo(tb.Data)
        	g_msg:post(g_enumKey.CustomEventKey.Laba,g_data.userSys.speakerContent)
        elseif n.updateGoldNum == _tag then
            local _data = {goldNum = tb.BigGold}
            g_msg:post(g_enumKey.CustomEventKey.UpdateHeadInfo,_data)
        elseif g_httpTag.GET_ACTIVITY_PICLIST == _tag then
        	local picList = {}
        	for k,v in ipairs(tb.Data) do
        		if type(v) == "table" then
        			table.insert(picList,v["picUrl"])
    			end
        	end
            self:managerActivityPic(picList)
        elseif n.shareWxCircle == _tag then
            dump(tb,"----shareWxCircle----")
        elseif g_httpTag.ENTER_ROOM == _tag then
            dump(tb,"----ENTER_ROOM----")
            g_SMG:removeWaitLayer()
            g_GameConfig.kServerAddr = tb.Host
            g_GameConfig.kServerPort = tb.Port
            g_data.roomSys.kTableID  = tb.TableID
            g_GameConfig.kSeatID     = tb.SeatID

            tb.roomId = g_data.roomSys.kTableID
            g_data.roomSys.Owner     = tb.Owner
            g_data.roomSys:updateGameRule(tb)
            g_netMgr:connectGameServer()
        end
        ok = true
    end
    --失败处理
    if not ok then
        dump(_response,"---json.decode(_response)---")
        print(_response,"======")
        self:httpFail({code="101", response=""}, _tag)
    end
end
function m:httpFail(_response, _tag)
    g_SMG:removeWaitLayer()
    print("httpFail", _response, _tag)
    printTable("_response",_response)
end

function m:showErrorTxt(errorTxt)
	local LayerTipError = g_UILayer.Common.LayerTipError.new(errorTxt)
	g_SMG:addLayer(LayerTipError)
end

function m:showUIWithNetData(subUIName)
	print("-----subUIName=-",subUIName)
	if subUIName == self.subUIName.UIMessage then
        self:httpPost(g_httpTag.GET_PLAYER_MESSAGE,{},subUIName,subUIName)
	elseif subUIName == self.subUIName.UIRecord then
        self:httpPost(g_httpTag.GET_HISTORY,{},subUIName,subUIName)
	elseif subUIName == self.subUIName.UISelfInfo then
        self:httpPost(g_httpTag.GET_JU_CNT,{},subUIName,subUIName)
    end
end

function m:httpPost(urlTag,data,responseTag,subTag)
    data.accessKey = g_data.userSys.accessKey
    data.DeviceID = g_data.userSys.openid
    data.UserID = g_data.userSys.UserID
    dump(data,"---httpPostData---")
    g_http.POST(g_GameConfig.URL .. urlTag,data,responseTag,subTag)
end

function m:showUIWithLocalData(subUIName)
	print("-----showUIWithLocalData=-",subUIName)
	if subUIName == self.subUIName.UIActivity then
        local activityimglist = g_LocalDB:read("activityimglist")
        self:_showActivityView(#activityimglist)
	elseif subUIName == self.subUIName.UIAddCard then
        g_SMG:addLayer(g_UILayer.Main.UIAddCard.new())

	elseif subUIName == self.subUIName.UIBinding then
		local data = {
			wdtgy = g_data.userSys.PromoterID, --我的推广员ID
			tjryqm = g_data.userSys.RefereeID --推荐人邀请码
		}
        g_SMG:addLayer(g_UILayer.Main.UIBinding.new(data))

	elseif subUIName == self.subUIName.UIFeedback then
        g_SMG:addLayer(g_UILayer.Main.UIFeedback.new(g_data.userSys.feedback or "lpmj001"))
	elseif subUIName == self.subUIName.UISetting then
        g_SMG:addLayer(g_UILayer.Main.UISetting.new(g_UILayer.Main.UISetting.showBtnType.btn_logout))
	end
end
function  m:showRewardLayer()
    g_SMG:addLayer(g_UILayer.Main.UILayerReward.new())
end
function m:showHistoryDetailLayer(TableID,Round)
    self:httpPost(g_httpTag.GET_HISTORY_DETAIL,{TableID=TableID,Round=Round},self.subUIName.UIRecordDetail,self.subUIName.UIRecordDetail)
end

function m:getContactInfo()
	if g_data.userSys.buyCard and g_data.userSys.speakerContent then
		g_msg:post("Laba",g_data.userSys.speakerContent)
	else
    	self:httpPost(g_httpTag.GET_CONTACT_INFO,{},g_httpTag.GET_CONTACT_INFO,g_httpTag.GET_CONTACT_INFO)
	end
end

function m:getActivityPicList()
   self:httpPost(g_httpTag.GET_ACTIVITY_PICLIST,{},g_httpTag.GET_ACTIVITY_PICLIST,g_httpTag.GET_ACTIVITY_PICLIST)
end

function m:managerActivityPic(picList)   
    local localPicList = g_LocalDB:read("activityimglist")
    local same = table.ArrayCompare(picList,localPicList)
    local isExist = true
    if same == true then
        --已经下载了,判断文件是否存在
        for i,v in ipairs(picList) do
            local p = device.writablePath .. "ActivityPic_" .. i .. ".png"
            if FileUtils.file_exists(p) == false then
                isExist = false
                break
            end
        end
    end
    if same == false or isExist == false then
        self._needLoadImgNum = 0
        self._needLoadImgSum = #picList
        g_LocalDB:save("activityimglist",picList)
 
        for i,v in ipairs(picList) do
            local path = device.writablePath .. "ActivityPic_" .. i .. ".png"
            g_http.Download(v,n.loadActivityImg,n.loadActivityImg,path)
        end
    else
        if g_data.userSys.firstLogin == 1 then
            if g_GameConfig.isiOSAppCheck == false then
                g_SMG:addLayerByName(g_UILayer.Main.UILayerReward.new(1,#picList))
            end
        else
           self:_showActivityView(#picList)
        end
        
    end
end
function m:httpSuccessLoadImg(_response, _tag)
    if n.loadActivityImg == _tag then
        self._needLoadImgNum = self._needLoadImgNum + 1
        if self._needLoadImgNum >= self._needLoadImgSum then
            self:_showActivityView(self._needLoadImgSum)
        end
    end
end

function m:_showActivityView(num)
    if g_GameConfig.Game_State == g_GameConfig.GS.Main and g_SMG:getLayersNum() == 0 and g_GameConfig.isiOSAppCheck == false then
        local pathList = {}
        for i=1,num do
            local p = device.writablePath .. "ActivityPic_" .. i .. ".png"
            table.insert(pathList,p)
        end
        g_SMG:addLayerByName(g_UILayer.Main.UIActivity.new(pathList))
    end
end

function m:updateGoldNum()
    self:httpPost(g_httpTag.GET_JU_CNT,{},n.updateGoldNum,n.updateGoldNum)
end
function m:WeiXinShareCircle()
    print("herrrrrrrrrrrrr",g_httpTag.SHARE_WX_CIRCLE,n.shareWxCircle)
    self:httpPost(g_httpTag.SHARE_WX_CIRCLE,{},n.shareWxCircle, n.shareWxCircle)
end

function m:enterRoom(roomId)
    self:httpPost(g_httpTag.ENTER_ROOM,{RoomID = roomId},g_httpTag.ENTER_ROOM, g_httpTag.ENTER_ROOM)
end

function m:saveRoomInfo(roomInfo)
    local str = ""
    if roomInfo.clubName and string.len(roomInfo.clubName) > 0 then
        str = "俱乐部:" .. roomInfo.clubName .. " "
    end

    if roomInfo.region == "jinping" then
        str = str .. "锦屏麻将"
    elseif roomInfo.region == "liping" then
        str = str .. "黎平麻将"
    elseif roomInfo.region == "tianzhu" then
        str = str .. "天柱麻将"
    end
    if roomInfo.roomId then
        str = str .. " 房间号：" .. roomInfo.roomId
    elseif roomInfo.TableID then
        str = str .. " 房间号：" .. roomInfo.TableID
    end
    str = str .. " " .. roomInfo.RoundLimit .. "局"
    str = str .. " " .. RoomDefine.RuleText[roomInfo.PlayRule]
    if roomInfo.region ~= "tianzhu" then
        if roomInfo.IsMenGangMulti2 == 1 then
            str = str .. " 闷杠X2"
        elseif roomInfo.IsMenGangMulti2 == 0 then
            str = str .. " 自杠X2"
        end
    end

    if roomInfo.DeathByLight == 1 then
        str = str .. " 见光死"
    end

    if roomInfo.Additional and roomInfo.Additional > 0 then
        str = str .. " 订卖+"..roomInfo.Additional.."分"
    end

    if roomInfo.supplementPriceFlag and roomInfo.supplementPriceFlag == 1 then
        str = str .. " 补差价"
    end

    if roomInfo.ReplaceTable == 1 then --代开房间

    end
    printTable("saveRoomInfo",roomInfo)
    print("saveRoomInfo   ",str)
    return str
end

function m:getDelRoomRuleInfoStr(roomInfo)
    local str = roomInfo.region_label
    str = str .. " 房间号：" .. roomInfo.table_id
    str = str .. " " .. roomInfo.round_num  --局
    str = str .. " " .. roomInfo.table_type --几人房
    str = str .. " " .. roomInfo.additional_label --见光死
    str = str .. " " .. roomInfo.death_by_light_label --订卖
    str = str .. " " .. roomInfo.supplement_price_label --补差价
    str = str .. " " .. roomInfo.gang --闷杠X2、自杠X2

    printTable("getDelRoomRuleInfoStr",roomInfo)
    print("getDelRoomRuleInfoStr  ",str)
    return str
end

return m
