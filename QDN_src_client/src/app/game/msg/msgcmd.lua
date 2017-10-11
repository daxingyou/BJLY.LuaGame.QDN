--
-- Author: XuJian
--
local msgcmd = {}
local m = msgcmd

m.ENTER_BACKGROUND = "ENTER_BACKGROUND"	--退到后台
m.ENTER_FOREGROUND = "ENTER_FOREGROUND"	--从后台返回游戏


m.SOCKET_CONNECT_SUCCESS	= "SOCKET_CONNECT_SUCCESS" --socket连接成功
m.SOCKET_CONNECT_FAIL		= "SOCKET_CONNECT_FAIL"	 --socket连接失败
m.SOCKET_RECONNECT			= "SOCKET_RECONNECT"	     --socket重新连接
m.DB_ROOM_UPDATE_PLAYER     = "DB_ROOM_UPDATE_PLAYER" --房间信息改变

m.DB_UPDATE_USER_INFO       = "DB_UPDATE_USER_INFO"   --用户信息变更
m.DB_ENTER_ROOM       		= "DB_ENTER_ROOM"   --加入房间
m.DB_LEAVE_TABLE_BROADCAST  = "DB_LEAVE_TABLE_BROADCAST" --离开房间

m.DB_UPDATE_CARD  			= "DB_UPDATE_CARD"--牌信息变化
m.UI_AskDingQueBroadcast    = "UI_AskDingQueBroadcast" --定缺
--刷新房间用户信息
m.DB_UPDATE_PLAYER_INFO     = "DB_UPDATE_PLAYER_INFO" --定缺
m.DB_PLAY_GAME_START     	= "DB_PLAY_GAME_START" --牌局开始
m.DB_PLAY_ADD_CARD     		= "DB_PLAY_ADD_CARD" --牌局开始
m.DB_PLAY_OUT_CARD			= "DB_PLAY_OUT_CARD" --出牌成功
m.DB_PLAY_OPERATE_ASK		= "DB_PLAY_OPERATE_ASK" --操作询问
m.DB_PLAY_OPERATE_Result	= "DB_PLAY_OPERATE_Result" --操作结果
m.DB_PLAY_OPERATE_Pass		= "DB_PLAY_OPERATE_Pass"
m.DB_Left_CNT				= "DB_Left_CNT" --牌数变化
m.UI_UPDATE_ARROW			= "UI_UPDATE_ARROW"
m.DB_RoundResultBroadcast	= "DB_RoundResultBroadcast" --牌局结束
m.DB_ResultTotalBroadcast	= "DB_ResultTotalBroadcast" --牌局结束
m.DB_ReadyBroadcast			= "DB_ReadyBroadcast" --准备广播
m.UI_MinglouAsk			    = "UI_MinglouAsk" --
m.DB_DismissAskBroadcast	= "DB_DismissAskBroadcast" --解散房间询问
m.UI_DismissAnswerBroadcast = "UI_DismissAnswerBroadcast"
m.UI_DismissBroadcast       = "UI_DismissBroadcast"
m.DB_FinalReport			= "DB_FinalReport" --总结算
m.UI_BreakBroadcast			= "UI_BreakBroadcast" --断线广播

m.UI_ChatBroadcast          = "UI_ChatBroadcast" --[_type= 1 or 2],1:表情聊天广播,2:自定义聊天
m.UI_Banker_Change			= "UI_Banker_Change"
m.UI_DingQue_Success		= "UI_DingQue_Success"
m.UI_Chicken_Change			= "UI_Chicken_Change"

m.UI_VOICE_LOGIN            = "UI_VOICE_LOGIN"--加入语音室广播
m.UI_VOICE_State            = "UI_VOICE_State"--加入语音室广播

m.UI_ROUND_SCORE_State      = "UI_ROUND_SCORE_State"--加入语音室广播
m.UI_Rest_Card_State        = "UI_Rest_Card_State"--重置打牌
m.UI_DingQue_END            = "UI_DingQue_END"--重置打牌

m.UI_MinglouBroadcast		= "UI_MinglouBroadcast" --听牌广播
m.UI_Setting_Change		    = "UI_Setting_Change" --听牌广播
m.UI_OUT_TILE		        = "UI_OUT_TILE" --打牌通知
m.UI_Selected_Tile          = "UI_Selected_Tile" --俱乐部刷新


m.UI_Club_Reflash           = "UI_Club_Reflash" --俱乐部刷新

return msgcmd
