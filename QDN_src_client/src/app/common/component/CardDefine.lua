local CardDefine = {}

CardDefine.direction = {
	bottom 	= 1,
	right 	= 2,
	top 	= 3,
	left 	= 4
}

CardDefine.type = {
	shoupai  = 1,
	chupai   = 2,
	pengpai  = 3,
	gangpai  = 4,
}

CardDefine.card_bg = {
	[CardDefine.direction.bottom] = {"green_mj_bg1.png", "blue_mj_bg1.png"},
	[CardDefine.direction.right]  = {"green_mj_bg3.png", "blue_mj_bg3.png"},
	[CardDefine.direction.top]    = {"green_mj_bg1.png", "blue_mj_bg1.png"},
	[CardDefine.direction.left]   = {"green_mj_bg3.png", "blue_mj_bg3.png"}	
}

CardDefine.hand_bg = {
	[CardDefine.direction.bottom] = {"green_mj_bg4.png", "blue_mj_bg4.png"},
	[CardDefine.direction.right]  = {"green_mj_bg7.png", "blue_mj_bg7.png"},
	[CardDefine.direction.top]    = {"green_mj_bg4.png", "blue_mj_bg4.png"},
	[CardDefine.direction.left]   = {"green_mj_bg7.png", "blue_mj_bg7.png"}	
}

CardDefine.card_bg_kong = {
	[CardDefine.direction.bottom] = {"green_mj_bg4.png", "blue_mj_bg4.png"},
	[CardDefine.direction.right]  = {"green_mj_bg6.png", "blue_mj_bg6.png"},
	[CardDefine.direction.top]    = {"green_mj_bg4.png", "blue_mj_bg4.png"},
	[CardDefine.direction.left]   = {"green_mj_bg6.png", "blue_mj_bg6.png"}	
}

CardDefine.card_bg_4_6 = {
	[CardDefine.direction.bottom] = {"green_mj_bg3.png", "blue_mj_bg3.png"},
	[CardDefine.direction.right]  = {"green_mj_bg1.png", "blue_mj_bg1.png"},
	[CardDefine.direction.top]    = {"green_mj_bg3.png", "blue_mj_bg3.png"},
	[CardDefine.direction.left]   = {"green_mj_bg1.png", "blue_mj_bg1.png"}	
}

CardDefine.card_ji_bg = {
	[CardDefine.direction.bottom] = {"green_mj_bg3.png", "blue_mj_bg3.png"},
	[CardDefine.direction.right]  = {"green_mj_bg1.png", "blue_mj_bg1.png"},
	[CardDefine.direction.top]    = {"green_mj_bg3.png", "blue_mj_bg3.png"},
	[CardDefine.direction.left]   = {"green_mj_bg1.png", "blue_mj_bg1.png"}	
}

CardDefine.CardItemGroupDirection = {
	[CardDefine.direction.bottom] = display.LEFT_TO_RIGHT,
	[CardDefine.direction.right]  = display.BOTTOM_TO_TOP,
	[CardDefine.direction.top]    = display.RIGHT_TO_LEFT,
	[CardDefine.direction.left]   = display.TOP_TO_BOTTOM	
}

CardDefine.CardItem = {
 	[CardDefine.direction.bottom] = "app.common.component.sprites.CardItemBottom",
    [CardDefine.direction.right]  = "app.common.component.sprites.CardItemRight",
    [CardDefine.direction.top]    = "app.common.component.sprites.CardItemTop",
    [CardDefine.direction.left]   = "app.common.component.sprites.CardItemLeft",
}


CardDefine.cardValue = {
	--万
	w1    = 1,
	w2    = 2,
	w3    = 3,
	w4    = 4,
	w5    = 5,
	w6    = 6,
	w7    = 7,
	w8    = 8,
	w9    = 9,

	--条
	tiao1 = 17,
	tiao2 = 18,
	tiao3 = 19,
	tiao4 = 20,
	tiao5 = 21,
	tiao6 = 22,
	tiao7 = 23,
	tiao8 = 24,
	tiao9 = 25,
	--筒
	tong1 = 33,
	tong2 = 34,
	tong3 = 35,
	tong4 = 36,
	tong5 = 37,
	tong6 = 38,
	tong7 = 39,
	tong8 = 40,
	tong9 = 41,

	dong  = 141,
	nan   = 142,
	xi    = 143,
	bei   = 144,
	zhong = 145,
	fa    = 146,
	bai   = 147,
	cchun = 151,
	cxia  = 152,
	cqiu  = 153,
	cdong = 154,
	cmei  = 155,
	clan  = 156,
	czhu  = 157,
	cju   = 158,
}

CardDefine.enum = {
	[CardDefine.cardValue.w1]    = {"一万","mj_1.png","sound/wan1_man_d.mp3", "sfx/woman/yiwan.mp3"},
	[CardDefine.cardValue.w2]    = {"二万","mj_2.png","sound/wan2_man_d.mp3", "sfx/woman/erwan.mp3"},
	[CardDefine.cardValue.w3]    = {"三万","mj_3.png","sound/wan3_man_d.mp3", "sfx/woman/sanwan.mp3"},
	[CardDefine.cardValue.w4]    = {"四万","mj_4.png","sound/wan4_man_d.mp3", "sfx/woman/siwan.mp3"},
	[CardDefine.cardValue.w5]    = {"五万","mj_5.png","sound/wan5_man_d.mp3", "sfx/woman/wuwan.mp3"},
	[CardDefine.cardValue.w6]    = {"六万","mj_6.png","sound/wan6_man_d.mp3", "sfx/woman/liuwan.mp3"},
	[CardDefine.cardValue.w7]    = {"七万","mj_7.png","sound/wan7_man_d.mp3", "sfx/woman/qiwan.mp3"},
	[CardDefine.cardValue.w8]    = {"八万","mj_8.png","sound/wan8_man_d.mp3", "sfx/woman/bawan.mp3"},
	[CardDefine.cardValue.w9]    = {"九万","mj_9.png","sound/wan9_man_d.mp3", "sfx/woman/jiuwan.mp3"},
	[CardDefine.cardValue.tiao1] = {"一条","mj_11.png","sound/tiao1_man_d.mp3", "sfx/woman/yitiao.mp3"},
	[CardDefine.cardValue.tiao2] = {"二条","mj_12.png","sound/tiao2_man_d.mp3", "sfx/woman/ertiao.mp3"},
	[CardDefine.cardValue.tiao3] = {"三条","mj_13.png","sound/tiao3_man_d.mp3", "sfx/woman/santiao.mp3"},
	[CardDefine.cardValue.tiao4] = {"四条","mj_14.png","sound/tiao4_man_d.mp3", "sfx/woman/sitiao.mp3"},
	[CardDefine.cardValue.tiao5] = {"五条","mj_15.png","sound/tiao5_man_d.mp3", "sfx/woman/wutiao.mp3"},
	[CardDefine.cardValue.tiao6] = {"六条","mj_16.png","sound/tiao6_man_d.mp3", "sfx/woman/liutiao.mp3"},
	[CardDefine.cardValue.tiao7] = {"七条","mj_17.png","sound/tiao7_man_d.mp3", "sfx/woman/qitiao.mp3"},
	[CardDefine.cardValue.tiao8] = {"八条","mj_18.png","sound/tiao8_man_d.mp3", "sfx/woman/batiao.mp3"},
	[CardDefine.cardValue.tiao9] = {"九条","mj_19.png","sound/tiao9_man_d.mp3", "sfx/woman/jiutiao.mp3"},
	[CardDefine.cardValue.tong1] = {"一筒","mj_21.png","sound/tong1_man_d.mp3", "sfx/woman/yibing.mp3"},
	[CardDefine.cardValue.tong2] = {"二筒","mj_22.png","sound/tong2_man_d.mp3", "sfx/woman/erbing.mp3"},
	[CardDefine.cardValue.tong3] = {"三筒","mj_23.png","sound/tong3_man_d.mp3", "sfx/woman/sanbing.mp3"},
	[CardDefine.cardValue.tong4] = {"四筒","mj_24.png","sound/tong4_man_d.mp3", "sfx/woman/sibing.mp3"},
	[CardDefine.cardValue.tong5] = {"五筒","mj_25.png","sound/tong5_man_d.mp3", "sfx/woman/wubing.mp3"},
	[CardDefine.cardValue.tong6] = {"六筒","mj_26.png","sound/tong6_man_d.mp3", "sfx/woman/liubing.mp3"},
	[CardDefine.cardValue.tong7] = {"七筒","mj_27.png","sound/tong7_man_d.mp3", "sfx/woman/qibing.mp3"},
	[CardDefine.cardValue.tong8] = {"八筒","mj_28.png","sound/tong8_man_d.mp3", "sfx/woman/babing.mp3"},
	[CardDefine.cardValue.tong9] = {"九筒","mj_29.png","sound/tong9_man_d.mp3", "sfx/woman/jiubing.mp3"}	
}

CardDefine.AllcardType  = {
	{1,2,3,4,5,6,6,7,8,9},
	{17,18,19,20,21,22,23,24,25},
	{33,34,35,36,37,38,39,40,41}
}

--操作行为 2中吃，3右吃，4碰，5杠，6明搂，7胡) 
CardDefine.operateType  = {
	Deal          = 1, -- 发牌
	Draw          = 2, -- 摸牌
	Pass          = 3,
	Pong          = 4, -- 碰
	Kong          = 5, -- 杠
	Ready         = 6, --6明搂
	Hu            = 7, -- 胡牌
}


return CardDefine