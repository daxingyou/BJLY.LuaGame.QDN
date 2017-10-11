--
-- 用户系统信息
--

local UserSys = class("UserSys")

function UserSys:ctor()
	self.id 				= 0     --玩家ID
	self.coins 				= 0  	--现有钻石数量
	self.avatar 			= ""    --玩家头像
	self.continue_days 		= 1 --连续登陆天数
	self.isdelegate         = 0 --玩家是否是代理 是否有代理的权限
	self.firstLogin         = 0 --玩家是否是当天首次登陆
	self.roomState			= 0
end


--更新Player数据
function UserSys:updateWXInfo(_data)
	if not _data  then return { } end
	printTable("updateWXInfo::::::", _data)
	
	for k,v in pairs(_data) do --把player k,v赋值到当前系统中
		self[k] = v
	end
	local clientVersion = g_LocalDB:read("clientversion")
	
	self.userInfo = {
            version = clientVersion, --暂时没有用
            WeiChatID = self.openid,
            WeiChatNick = self.nickname,
            WeiChatFaceAddress = self.headimgurl,
            Sex = self.sex,
            IsNetChange = false,}
	return self.userInfo
end

--更新Player数据
function UserSys:updateServerInfo(_data)
	if not _data  then return { } end
	printTable("updateServerInfo::::::", _data)

	for k,v in pairs(_data) do --把player k,v赋值到当前系统中
		self[k] = v
	end
	g_msg:post(g_msgcmd.DB_UPDATE_USER_INFO,{User={UserID=self.UserID}})
end

function UserSys:getUserId()
	return self.id
end

--增加指定金币
function UserSys:addCoins(_coins)
	self:setCoins(self.coins + _coins)
end

--获取筹码
function UserSys:getCoins()
	return self.coins
end

--设置金币数 --房卡
function UserSys:setCoins(_num)
	if _num < 0 then _num = 0 end
	self.coins = _num
end

--是否自己
function UserSys:isMyId(_id)
	if _id == self.id then
		return true
	end
	return false
end

function UserSys:setKeyValue(key,value)
	self[key .. ''] = value
end

function UserSys:getValueByKey(key)
	return self[key .. '']
end

--保存联系信息和喇叭
function UserSys:saveContentInfo(_data)
	printTable("data_________=======",_data)
	for k,v in pairs(_data) do
		self[k] = v
	end
	local d = {
		buyCard = {
			"LaiyajpCZ",
		},
		feedback = "lpmj001",
		joinAgent = {
			"",""
		},
		support = {
			""
		},
		cc = "",
		shareWxCircleContent = "",
	}
	return d
end

return UserSys
