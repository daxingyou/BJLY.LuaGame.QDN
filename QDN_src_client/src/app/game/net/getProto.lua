--[[
getProto 根据msgId得到protoBuf table
author: XuJian
]]


local getProto = {}
-- 需要注册的pb
local pbfiles = {
  "command.pb",
}

-- msgId转typename
local typenames = {
	[g_netcmd.MSG_PING_PONG]       		    = {"C2GS_PingPong","GS2C_PingPong"},--#心跳
	[g_netcmd.MSG_LOGIN]       			    = {"C2GS_Login","GS2C_Login"},--#登陆
	[g_netcmd.MSG_JOIN_TABLE] 			    = {"C2GS_JoinTable","GS2C_JoinTable"},--加入房间
	[g_netcmd.MSG_LEAVE_TABLE] 			    = {"C2GS_LeaveTable","GS2C_LeaveTable"}, --离开房间
	[g_netcmd.MSG_JOIN_TABLE_BROADCAST]     = {"C2GS_JoinTableBroadcast","GS2C_JoinTableBroadcast"}, --加入桌子广播
	[g_netcmd.MSG_LEAVE_TABLE_BROADCAST] 	= {"C2GS_LeaveTableBroadcast","GS2C_LeaveTableBroadcast"}, --离开桌子广播
	[g_netcmd.MSG_BREAK_BROADCAST]      	= {"C2GS_BreakBroadcast","GS2C_BreakBroadcast"}, --离开断线广播
	[g_netcmd.MSG_BREAK_BACK_BROADCAST] 	= {"C2GS_BreakBackBroadcast","GS2C_BreakBackBroadcast"}, --离开重连广播
	[g_netcmd.MSG_READY]  				 	= {"C2GS_Ready","GS2C_Ready"}, --准备
	[g_netcmd.MSG_READY_BROADCAST]  	    = {"C2GS_ReadyBroadcast","GS2C_ReadyBroadcast"}, --广播
	[g_netcmd.MSG_DISMISS_ASK_BROADCAST]    = {"C2GS_DismissAskBroadcast","GS2C_DismissAskBroadcast"}, --解散房间询问广播
	[g_netcmd.MSG_DISMISS_ANSWER]  		    = {"C2GS_DismissAnswer","GS2C_DismissAnswer"}, --解散回答响应
	[g_netcmd.MSG_DISMISS_ANSWER_BROADCAST] = {"C2GS_DismissAnswerBroadcast","GS2C_DismissAnswerBroadcast"}, --解散回答广播
	[g_netcmd.MSG_DISMISS_BROADCAST]        = {"C2GS_DismissBroadcast","GS2C_DismissBroadcast"}, --解散回答广播
	[g_netcmd.MSG_GET_JU_CNT]        		= {"C2GS_GetJuCnt","GS2C_GetJuCnt"}, --局数准备响应
	-- [g_netcmd.MSG_GET_RESULT_DETAIL]        = {"C2GS_GetJuCnt","GS2C_GetJuCnt"}, --算分详情
	[g_netcmd.MSG_RESULT_TOTAL]        		= {"C2GS_ResultTotalBroadcast","GS2C_ResultTotalBroadcast"}, --总分数
	[g_netcmd.MSG_RESULT_PK]        		= {"C2GS_ResultPKBroadcast","GS2C_ResultPKBroadcast"}, --pk广播
	[g_netcmd.MSG_DINGQUE_ANSWER]        	= {"C2GS_AskDingQueBroadcast","GS2C_AskDingQueBroadcast"}, --定缺
	[g_netcmd.MSG_DINGQUE_ASK_BROADCAST]    = {"C2GS_DingQue","GS2C_DingQue"},--定缺回应
	[g_netcmd.MSG_DINGQUE_ANSWER_BROADCAST] = {"C2GS_DingQueBroadcast","GS2C_DingQueBroadcast"}, --定缺回应广播



	[g_netcmd.MSG_ROUND_START_BROADCAST]    = {"C2GS_RoundStartBroadcast","GS2C_RoundStartBroadcast"}, --游戏一局开始广播
	[g_netcmd.MSG_ROUND_RESULT_BROADCAST]   = {"C2GS_RoundResultBroadcast","GS2C_RoundResultBroadcast"}, --游戏一局结算广播
	[g_netcmd.MSG_DISPATCH_BROADCAST]  		= {"C2GS_DispatchBroadcast","GS2C_DispatchBroadcast"}, --游戏一局结算广播
	[g_netcmd.MSG_OUT]  					= {"C2GS_Out","GS2C_Out"}, --游戏一局结算广播
	[g_netcmd.MSG_OUT_BROADCAST]  			= {"C2GS_OutBroadcast","GS2C_OutBroadcast"}, --出牌广播
	[g_netcmd.MSG_OPERATE_ASK_BROADCAST]  	= {"C2GS_OperateAskBroadcast","GS2C_OperateAskBroadcast"}, --操作询问广播
	[g_netcmd.MSG_OPERATE_RESULT_BROADCAST] = {"C2GS_OperateResultBroadcast","GS2C_OperateResultBroadcast"}, --操作结果广播
	[g_netcmd.MSG_OPERATE]				    = {"C2GS_Operate","GS2C_Operate"}, --操作结果广播
	[g_netcmd.MSG_MINGLOU]				    = {"C2GS_Minglou","GS2C_Minglou"}, --明搂请求
	[g_netcmd.MSG_MINGLOU_BROADCAST]		= {"C2GS_MinglouBroadcast","GS2C_MinglouBroadcast"}, --明搂广播
	[g_netcmd.MSG_MINGLOU_ASK]				= {"C2GS_MinglouAsk","GS2C_MinglouAsk"}, --搂询问可选牌请求 
	[g_netcmd.MSG_CHAT]						= {"C2GS_Chat","GS2C_Chat"}, --聊天
	[g_netcmd.MSG_CHAT_BROADCAST]			= {"C2GS_ChatBroadcast","GS2C_ChatBroadcast"}, --聊天广播
	-- [g_netcmd.MSG_HISTORY_BROADCAST]		= {"C2GS_ChatBroadcast","GS2C_ChatBroadcast"}, --历史广播
	[g_netcmd.MSG_VOICE_TALK]				= {"C2GS_VoiceTalk","GS2C_VoiceTalk"}, --聊天广播
	[g_netcmd.MSG_VOICE_TALK_BROADCAST]	    = {"C2GS_VoiceTalkBroadcast","GS2C_VoiceTalkBroadcast"}, --聊天广播
	[g_netcmd.MSG_CHAT_CUSTOM]	   			= {"C2GS_ChatCustom","GS2C_ChatCustom"}, --聊天
	[g_netcmd.MSG_CHAT_CUSTOM_BROADCAST]	= {"C2GS_ChatCustomBroadcast","GS2C_ChatCustomBroadcast"}, --聊天广播
	[g_netcmd.MSG_VOICE_LOGIN]	            = {"C2GS_GVoiceLogin","GS2C_GVoiceLogin"}, --玩家加入房间
	[g_netcmd.MSG_VOICE_LOGIN_BROADCAST]	= {"G2GS_GVoiceLoginBroadcast","GS2C_GVoiceLoginBroadcast"}, --玩家加入房间广播
}	

getProto.pbfiles = pbfiles
getProto.typenames = typenames

return getProto