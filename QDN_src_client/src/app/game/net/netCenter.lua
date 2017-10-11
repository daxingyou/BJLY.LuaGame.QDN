--
-- 网络中心
-- author: XuJian
-- date: 2017-6-17
--
-- local print = function() end
local getProto = require("app.game.net.getProto")

local netCenter = class("netCenter")

function netCenter:ctor()
	self:regEvent()
end

--清除数据
function netCenter:clear()
end

--注册事件
function netCenter:regEvent()
	print("netCenter:regEvent")
    local tempS=""
	local f = nil
	for k,v in pairs(getProto.typenames) do
		f = self[v[2]]
		if f then
			g_netMgr:reg("netCenter", k, handler(self, f))   --注册全部的指令与方法对应
		else
            if k%2==1 then
                tempS=tempS.."function netCenter:"..v[2].."(_msg)".."\nend\n"
                -- print("function netCenter:"..v.."()".."\n            end")
            end
			-- print("没有实现函数 = ", k, v)
		end
	end
    print(tempS)
end

--注销事件
function netCenter:unregEvent()
	for k,v in pairs(getProto.typenames) do
		g_netMgr:unreg("netCenter", k)
	end
end

--#登陆
function netCenter:GS2C_Login(_msg)
	printTable("_msg",_msg.data)
	if _msg.data.errorcode  == 0 then
		print("=====GS2C_Login  成功========")
		printTable("_msg",_msg.data)
		g_netMgr:send(g_netcmd.MSG_JOIN_TABLE, { table_id = g_data.roomSys.kTableID , seat_id =g_GameConfig.kSeatID } , 0)
	end	
end
--#进入房间
function netCenter:GS2C_JoinTable(_msg)
	local dt = _msg.data
	printTable("GS2C_JoinTable_Data",dt)
	if dt.errorcode == 0 then
		print("=====加入房间成功========")
		
		g_data.roomSys:updateStatus(dt.table_status)--更新桌子状态
		g_data.roomSys:joinTable(dt.banker_uid,dt.usr_info_list)
		g_data.roomSys:updateReconnect(dt)
		g_msg:post(g_msgcmd.DB_ENTER_ROOM)--加入房间
	else
		app:enterLoadingScene()
	end
end

--#离开房间
function netCenter:GS2C_LeaveTable(_msg)
	local dt = _msg.data
	if dt.errorcode == 0 then
		printTable("GS2C_LeaveTable =",dt)
		g_data.roomSys:updateStatus(dt.table_status)
		if  g_data.roomSys.m_status == RoomDefine.Status.Wait or 
			g_data.roomSys.m_status == RoomDefine.Status.End  then
			print("=====离开房间========")
			app:enterMainScene()
			g_gcloudvoice:quickteamroom(g_data.roomSys.kTableID)
		end
	end
end

--#加入桌子广播
function netCenter:GS2C_JoinTableBroadcast(_msg)
	print("=====加入桌子广播========")
	printTable("_msg",_msg.data)
	if _msg.data.errorcode == 0 then
		local data = _msg.data
		g_data.roomSys:addPlayer(data.usr_info)
		--发起刷新玩家信息通知
		g_msg:post(g_msgcmd.DB_UPDATE_PLAYER_INFO)
	end
end

--#离开桌子广播
function netCenter:GS2C_LeaveTableBroadcast(_msg)
	print("=====离开桌子广播========")
	printTable("_msg",_msg.data)
	if _msg.data.errorcode == 0 then
		g_data.roomSys:removePlayer(_msg.data)
		if _msg.data.leave_reason == 1 then
			g_gcloudvoice:quickteamroom(g_data.roomSys.kTableID)
			g_netMgr:close()
			app:enterMainScene()
		end
	end
end

--#离开断线
function netCenter:GS2C_BreakBroadcast(_msg)
	print("=====GS2C_BreakBroadcast========")
	local dt = _msg.data
	if dt.errorcode == 0 then
		print("=====断线广播========---->",dt.uid)
		g_msg:post(g_msgcmd.UI_BreakBroadcast,{uid = dt.uid, status = 0})
	end
end

--#离线回来
function netCenter:GS2C_BreakBackBroadcast(_msg)
	local dt = _msg.data
	if dt.errorcode == 0 then
		print("=====断线广播========---->",dt)
		g_msg:post(g_msgcmd.UI_BreakBroadcast,{uid = dt.break_uid, status = 1})
	end
end

--#--准备
function netCenter:GS2C_Ready(_msg)
	print("=====GS2C_Ready========")
	printTable("_msg",_msg.data)
end

--#--准备广播
function netCenter:GS2C_ReadyBroadcast(_msg)
	printTable("=====准备广播-GS2C_ReadyBroadcast========",_msg.data)
	local dt = _msg.data
	if dt.errorcode == 0 then
		g_msg:post(g_msgcmd.DB_ReadyBroadcast,{uid = dt.uid})--游戏开始
	end
end

--#--解散房间询问广播
function netCenter:GS2C_DismissAskBroadcast(_msg)
	local dt = _msg.data
	if dt.errorcode == 0 then
		print("=====解散房间询问广播========")
		printTable("_msg",_msg.data)
		g_msg:post(g_msgcmd.DB_DismissAskBroadcast,{uid = dt.ask_uid})--游戏开始
	end
end


--#--解散回答响应
function netCenter:GS2C_DismissAnswer(_msg)
	print("=====GS2C_DismissAnswer========")
	printTable("_msg",_msg.data)
end

--解散房间广播
function netCenter:GS2C_DismissAnswerBroadcast(_msg)
	local dt = _msg.data
	if dt.errorcode == 0 then
		print("=====解散房间回答========")
		printTable("_msg",_msg.data)
		g_msg:post(g_msgcmd.UI_DismissAnswerBroadcast,{uid = dt.uid,is_agree = dt.is_agree})--游戏开始
	end
end

--解散房间广播
function netCenter:GS2C_DismissBroadcast(_msg)
	local dt = _msg.data
	if dt.errorcode == 0 then
		print("=====解散房间成功========")
		g_msg:post(g_msgcmd.UI_DismissBroadcast,{is_dismiss = dt.is_dismiss})
		g_gcloudvoice:closespeaker()
		g_gcloudvoice:quickteamroom(g_data.roomSys.kTableID)
	end
end

--获取玩家信息 胜率
function netCenter:GS2C_GetJuCnt(_msg)
	local dt = _msg.data
	if dt.errorcode == 0 then
		g_data.roomSys:updateJuCnt(dt)
	end
end

 --总分数
function netCenter:GS2C_ResultTotalBroadcast(_msg)
	--接受到总结算的广播了 要把数据给存起来
	local dt = _msg.data
	if dt.errorcode == 0 then
		g_data.roomSys.m_status = RoomDefine.Status.End -- 结算
 		g_data.reportSys:updataFinalReport(dt.result_list)
 		--要把桌号和是否是俱乐部显示出来
 		g_data.roomSys.kTableID  = dt.resultTableId
 		g_data.roomSys.ClubName  = dt.resultClubName
 		g_data.roomSys.ClubCode  = dt.resultClubCode
 		--退出语音房间
        g_gcloudvoice:quickteamroom(g_data.roomSys.kTableID)
        g_netMgr:close() --结算 断开
	end
end

--pk广播
function netCenter:GS2C_ResultPKBroadcast(_msg)
	print("=====GS2C_ResultPKBroadcast========")
	printTable("_msg",_msg.data)
end

--游戏一局开始广播
function netCenter:GS2C_RoundStartBroadcast(_msg)
	print("=====GS2C_RoundStartBroadcast 游戏开始========")
	printTable("_msg",_msg.data)
	local dt = _msg.data
	if dt.errorcode == 0 then
		g_data.roomSys.m_status = RoomDefine.Status.Doing --游戏开始
		g_data.roomSys:updateRoomInfo(dt)
		g_msg:post(g_msgcmd.DB_PLAY_GAME_START)--游戏开始
	end
end

--游戏一局结算广播
function netCenter:GS2C_RoundResultBroadcast(_msg)
	local dt = _msg.data
	printTable("=====GS2C_RoundResultBroadcast===一局结算========",dt)
	if dt.errorcode == 0 then
		
		g_data.roomSys:updateRoundScore(dt.result_list)
		g_data.reportSys:updataRoundReport(dt)
		g_msg:post(g_msgcmd.DB_RoundResultBroadcast)
	end
end

--系统发单张牌请求
function netCenter:GS2C_DispatchBroadcast(_msg)
	print("=====GS2C_DispatchBroadcast========")
	local dt = _msg.data
	printTable("_msg",dt)

	if dt.errorcode == 0 then
		print("发牌给玩家  uid = ",dt.dispatch_uid,"牌 =",dt.card)
		g_data.roomSys:updateLeft_cnt(dt.left_cnt)
		g_msg:post(g_msgcmd.DB_PLAY_ADD_CARD,{uid = dt.dispatch_uid,card = dt.card})
		g_msg:post(g_msgcmd.UI_UPDATE_ARROW,{uid =dt.dispatch_uid})
		--在派发一个 剩余牌数事件
	end
end

--出牌成功
function netCenter:GS2C_Out(_msg)
	 print("=====GS2C_Out-下行========")
	local dt = _msg.data
	if dt.errorcode == 0 then
		print("=====GS2C_Out-出牌成功========")
	elseif dt.errorcode == 13 then
		print("=====GS2C_Out-服务器延迟========")
        g_msg:post(g_msgcmd.UI_Rest_Card_State)
    elseif dt.errorcode == 5 then
		print("=====GS2C_Outm错误onSocketFail========")
        g_msg:post(g_msgcmd.UI_Rest_Card_State)
    else
    	print("=====GS2C_Out-未知========",dt.errorcode)
	end
end
--出牌广播
function netCenter:GS2C_OutBroadcast(_msg)
	print("=====GS2C_OutBroadcast-出牌广播========")
	local dt = _msg.data
	printTable("_msg",dt)
	if dt.errorcode == 0 then
		g_msg:post(g_msgcmd.DB_PLAY_OUT_CARD,{type=2,eTile = dt.card , cardEnum = dt.card, uid = dt.out_uid , chargeChickenType = dt.ji_type})
	end
end
 --操作询问广播
function netCenter:GS2C_OperateAskBroadcast(_msg)
	print("=====GS2C_OperateAskBroadcast========")
	local dt = _msg.data
	printTable("_msg",dt)
	if dt.errorcode == 0 then
		g_msg:post(g_msgcmd.DB_PLAY_OPERATE_ASK,{op =dt})  
	end
end

--操作结果广播
function netCenter:GS2C_OperateResultBroadcast(_msg)
	print("=====GS2C_OperateResultBroadcast========")
	local dt = _msg.data
	printTable("_msg",dt)
	if dt.errorcode == 0 then
		g_msg:post(g_msgcmd.DB_PLAY_OPERATE_Result,{op =dt})
		g_msg:post(g_msgcmd.UI_UPDATE_ARROW,{uid =dt.operate_uid})
	end
end

--操作结果
function netCenter:GS2C_Operate(_msg)
	print("=====GS2C_Operate========")
	printTable("_msg",_msg.data)
	local dt = _msg.data
	if dt.errorcode == 0 then
		if dt.operate_code == nil or dt.operate_code == 0 then
			g_msg:post(g_msgcmd.DB_PLAY_OPERATE_Pass,{op =dt})
		end
	elseif dt.errorcode == 30 then
		g_utils.showTipLabel("等待其他玩家操作!")
	end
end

--明搂请求
function netCenter:GS2C_Minglou(_msg)
	print("=====GS2C_Minglou========")
	printTable("_msg",_msg.data)
end

--明搂请求
function netCenter:GS2C_MinglouBroadcast(_msg)
	print("=====GS2C_MinglouBroadcast========")
	printTable("_msg",_msg.data)
	local dt = _msg.data
	if dt.errorcode == 0 then
		g_msg:post(g_msgcmd.UI_MinglouBroadcast,{ uid =dt.minglou_uid})
	end
	
end

--明搂请求
function netCenter:GS2C_MinglouAsk(_msg)
	print("=====GS2C_MinglouAsk========")
	printTable("_msg",_msg.data)
	local dt = _msg.data
	if dt.errorcode == 0 then
		if dt.operate_code == nil then
			g_msg:post(g_msgcmd.UI_MinglouAsk,{ can =dt.can_discard_cards})
		end
	end
end

--聊天请求
function netCenter:GS2C_Chat(_msg)
	print("=====GS2C_Chat========")
	printTable("_msg",_msg.data)
end

--聊天广播
function netCenter:GS2C_ChatBroadcast(_msg)
	print("=====GS2C_ChatBroadcast========")
	printTable("_msg",_msg.data)	
	if _msg.data.errorcode == 0 then
		-- g_msg:post(g_msgcmd.UI_ChatBroadcast,{_type = 1,data = _msg.data})  
		_msg.data._type = 1
		g_msg:post(g_msgcmd.UI_ChatBroadcast,_msg.data)
	end
end

--语音响应
function netCenter:GS2C_VoiceTalk(_msg)
	print("=====GS2C_VoiceTalk========")
	printTable("_msg",_msg.data)
end

--语音响应广播
function netCenter:GS2C_VoiceTalkBroadcast(_msg)
	print("=====GS2C_VoiceTalkBroadcast========")
	printTable("_msg",_msg.data)
end

----聊天
function netCenter:GS2C_ChatCustom(_msg)
	print("=====GS2C_ChatCustom========")
	printTable("_msg",_msg.data)
end

------聊天广播
function netCenter:GS2C_ChatCustomBroadcast(_msg)
	print("=====GS2C_ChatCustomBroadcast========")
	printTable("_msg",_msg.data)
	if _msg.data.errorcode == 0 then
		-- g_msg:post(g_msgcmd.UI_ChatBroadcast,{_type = 2,data = _msg.data})
		_msg.data._type = 2
		g_msg:post(g_msgcmd.UI_ChatBroadcast,_msg.data)
	end
end

------定缺成功
function netCenter:GS2C_DingQue(_msg)
	local dt = _msg.data
	printTable("_msg",dt)
	if dt.errorcode == 0 then
		g_msg:post(g_msgcmd.UI_AskDingQueBroadcast,{DQType = "success" ,data =dt})  
	end
end

------定缺发起
function netCenter:GS2C_AskDingQueBroadcast(_msg)
	print("=====定缺发起========")
	printTable("_msg",_msg.data)
	if _msg.data.errorcode == 0 then
		g_msg:post(g_msgcmd.UI_AskDingQueBroadcast,{ DQType = "ask"})
	end
end

------定缺回应广播
function netCenter:GS2C_DingQueBroadcast(_msg)
	print("=====定缺回应广播========")
	local dt = _msg.data
	printTable("_msg",dt)
	if dt.errorcode == 0 then
		g_data.roomSys:updateQingQueInfo(dt)
		g_msg:post(g_msgcmd.UI_AskDingQueBroadcast,{DQType = "broadcast" ,uid =dt.ui})  
	end
end

------心跳
function netCenter:GS2C_PingPong(_msg)
	local dt = _msg.data
	if dt.errorcode == 0 then
		g_data.roomSys.m_HeartBeatCount = 0
	end
end

--#--语音登录广播
function netCenter:GS2C_GVoiceLoginBroadcast(_msg)
	local dt = _msg.data
	if dt.errorcode == 0 then
		print("=====GS2C_GVoiceLoginBroadcast========")
		printTable("_msg",_msg.data)
		g_msg:post(g_msgcmd.UI_VOICE_LOGIN,dt)--加入语音室
	end
end

return netCenter
