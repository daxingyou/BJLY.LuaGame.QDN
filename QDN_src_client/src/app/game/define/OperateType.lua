
-- 操作代码
local OperateType = {}

OperateType.pong      		= 1 --碰
OperateType.Left_kong  		= 2--左杠
OperateType.Right_kong 		= 3
OperateType.Mid_kong   		= 4
OperateType.Fill_kong 		= 5--补杠
OperateType.Self_kong 		= 6--暗杠
OperateType.Ready     		= 7--听
OperateType.Hu        		= 8--胡
OperateType.Left_pong  		= 9 --左碰
OperateType.Mid_pong   		= 10 --中碰
OperateType.Right_pong 		= 11 
OperateType.ChargeChicken 	= 12 --冲锋鸡
OperateType.DutyChicken 	= 13 --责任鸡

OperateType.Hu_TYPE_1       = 101--胡
OperateType.Hu_TYPE_2       = 102--大对子
OperateType.Hu_TYPE_3       = 103--七小对
OperateType.Hu_TYPE_4       = 104--龙七对
OperateType.Hu_TYPE_5       = 105--清一色
OperateType.Hu_TYPE_6       = 106--清七对
OperateType.Hu_TYPE_7       = 107--清大对
OperateType.Hu_TYPE_8       = 108--青龙背
OperateType.Hu_DianPao      = 109--点炮
OperateType.Hu_TYPE_9       = 110--自摸  -需要自己判断

OperateType.Kong_TYPE_1     = 201--杠上开花
OperateType.Kong_TYPE_2     = 202--热炮
OperateType.Kong_TYPE_3     = 203--抢杠胡

OperateType.Animation_Res = {

	[OperateType.pong]      		= "effect_peng_up.png", --碰
	[OperateType.Left_kong]  		= "effect_gang_up.png",--左杠
	[OperateType.Right_kong] 		= "effect_gang_up.png",
	[OperateType.Mid_kong]   		= "effect_gang_up.png",
	[OperateType.Fill_kong] 		= "effect_gang_up.png",--补杠
	[OperateType.Self_kong] 		= "effect_gang_up.png",--暗杠
	[OperateType.Ready]     		= "effect_ting_up.png",--听
	[OperateType.Hu]        		= "effect_hu_up.png",--胡
	[OperateType.Left_pong]  		= "effect_peng_up.png", --左碰
	[OperateType.Mid_pong]   		= "effect_peng_up.png", --中碰
	[OperateType.Right_pong] 		= "effect_peng_up.png",

	[OperateType.Hu_TYPE_1] 		= "effect_hu_up.png", 
	[OperateType.Hu_TYPE_2] 		= "effect_daduizi.png",
	[OperateType.Hu_TYPE_3] 		= "effect_qixiaodui.png", 
	[OperateType.Hu_TYPE_4] 		= "effect_longqidui.png", 
	[OperateType.Hu_TYPE_5] 		= "effect_qingyise.png", 
	[OperateType.Hu_TYPE_6] 		= "effect_qingqidui.png", 
	[OperateType.Hu_TYPE_7] 		= "effect_qingdadui.png", 
	[OperateType.Hu_TYPE_8] 		= "effect_qinglongqibei.png",
	[OperateType.Hu_TYPE_9] 		= "effect_zimo.png",

	[OperateType.Kong_TYPE_1] 		= "effect_gangshangkaihua.png", 
	[OperateType.Kong_TYPE_2] 		= "effect_repao.png", 
	[OperateType.Kong_TYPE_3] 		= "effect_qiangganghu.png",

	[OperateType.Hu_DianPao] 		= "effect_qiangganghu.png", 
}

OperateType.Animation_Res_2 = {

	[OperateType.pong]      		= "effect_peng_ecptoma.png", --碰
	[OperateType.Left_kong]  		= "effect_gang_ecptoma.png",--左杠
	[OperateType.Right_kong] 		= "effect_gang_ecptoma.png",
	[OperateType.Mid_kong]   		= "effect_gang_ecptoma.png",
	[OperateType.Fill_kong] 		= "effect_gang_ecptoma.png",--补杠
	[OperateType.Self_kong] 		= "effect_gang_ecptoma.png",--暗杠
	[OperateType.Ready]     		= "effect_ting_ecptoma.png",--听
	[OperateType.Hu]        		= "effect_hu_ecptoma.png",--胡
	[OperateType.Left_pong]  		= "effect_peng_ecptoma.png", --左碰
	[OperateType.Mid_pong]   		= "effect_peng_ecptoma.png", --中碰
	[OperateType.Right_pong] 		= "effect_peng_ecptoma.png", 


	[OperateType.Hu_TYPE_1] 		= "effect_hu_up.png", 
	[OperateType.Hu_TYPE_2] 		= "effect_daduizi.png",
	[OperateType.Hu_TYPE_3] 		= "effect_qixiaodui.png", 
	[OperateType.Hu_TYPE_4] 		= "effect_longqidui.png", 
	[OperateType.Hu_TYPE_5] 		= "effect_qingyise.png", 
	[OperateType.Hu_TYPE_6] 		= "effect_qingqidui.png", 
	[OperateType.Hu_TYPE_7] 		= "effect_qingdadui.png", 
	[OperateType.Hu_TYPE_8] 		= "effect_qinglongqibei.png",

	[OperateType.Kong_TYPE_1] 		= "effect_gangshangkaihua.png", 
	[OperateType.Kong_TYPE_2] 		= "effect_repao.png", 
	[OperateType.Kong_TYPE_3] 		= "effect_qiangganghu.png", 
}

OperateType.Functions = {

	[OperateType.pong]       = "pong",
	[OperateType.Left_pong]  = "pong",
	[OperateType.Mid_pong]   = "pong",
	[OperateType.Right_pong] = "pong",
    [OperateType.Left_kong]  = "kong",
    [OperateType.Right_kong] = "kong",
    [OperateType.Mid_kong]   = "kong",
    [OperateType.Fill_kong]  = "kong",
    [OperateType.Self_kong]  = "kong",
    [OperateType.Hu]         = "hu",
}

return OperateType