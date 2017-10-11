--[[
netcmd 消息协议号
author: XuJian
date: 2017-6-17
company:topgame
]]


local netcmd = {}
--#####消息协议号#####
--
--心跳
netcmd.MSG_PING_PONG =1 
--#登陆
netcmd.MSG_LOGIN = 2
netcmd.MSG_JOIN_TABLE = 3
--加入房间广播
netcmd.MSG_JOIN_TABLE_BROADCAST = 4
--#离开房间
netcmd.MSG_LEAVE_TABLE = 5
--离开广播
netcmd.MSG_LEAVE_TABLE_BROADCAST = 6
--断线广播
netcmd.MSG_BREAK_BROADCAST = 7
--断线重连广播
netcmd.MSG_BREAK_BACK_BROADCAST = 8
--准备
netcmd.MSG_READY = 9
--准备广播
netcmd.MSG_READY_BROADCAST = 10
--游戏已经开始，请求解散房间给其他人的询问广播
netcmd.MSG_DISMISS_ASK_BROADCAST = 12
--游戏已经开始，其他人的回应
netcmd.MSG_DISMISS_ANSWER = 13
--游戏已经开始，其他人的回应广播		
netcmd.MSG_DISMISS_ANSWER_BROADCAST = 14
--游戏已经开始，正式解散房间	
netcmd.MSG_DISMISS_BROADCAST = 15
--获得局数	
netcmd.MSG_GET_JU_CNT = 16
--获得算分详情		
netcmd.MSG_GET_RESULT_DETAIL = 17
--总分数		
netcmd.MSG_RESULT_TOTAL = 18
--每局PK广播		
netcmd.MSG_RESULT_PK = 19
--定缺
netcmd.MSG_DINGQUE_ANSWER = 20
--定缺
netcmd.MSG_DINGQUE_ASK_BROADCAST = 21
netcmd.MSG_DINGQUE_ANSWER_BROADCAST	= 22;	--定缺回应广播



--一局开始广播	
netcmd.MSG_ROUND_START_BROADCAST = 101
--一一局结算广播	
netcmd.MSG_ROUND_RESULT_BROADCAST = 102
--系统发出一张牌给一个玩家广播			
netcmd.MSG_DISPATCH_BROADCAST = 103
--出牌		
netcmd.MSG_OUT = 104
--出牌广播		
netcmd.MSG_OUT_BROADCAST = 105
--操作询问（碰杠胡）		
netcmd.MSG_OPERATE_ASK_BROADCAST = 106
--操作结果（碰杠胡）		
netcmd.MSG_OPERATE_RESULT_BROADCAST = 107
--操作
netcmd.MSG_OPERATE = 108
--明搂
netcmd.MSG_MINGLOU = 110
--听牌广播
netcmd.MSG_MINGLOU_BROADCAST = 111
--听牌询问可丢弃的牌数组
netcmd.MSG_MINGLOU_ASK = 112
--聊天
netcmd.MSG_CHAT = 120
--聊天广播
netcmd.MSG_CHAT_BROADCAST = 121
--历史广播
netcmd.MSG_HISTORY_BROADCAST = 122
--语音聊天
netcmd.MSG_VOICE_TALK = 123
--语音聊天	
netcmd.MSG_VOICE_TALK_BROADCAST = 124
--输入聊天	
netcmd.MSG_CHAT_CUSTOM = 125
--输入聊天广播	
netcmd.MSG_CHAT_CUSTOM_BROADCAST = 126
--语音请求	
netcmd.MSG_VOICE_LOGIN = 127
--语音广播
netcmd.MSG_VOICE_LOGIN_BROADCAST = 128
--==============================--
--==============================--


return netcmd