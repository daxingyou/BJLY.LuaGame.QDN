

TileHandMoveHeight = 15
TilePadingRight    = 100
TilePadingLeft     = 100
TilePadingTop      = 100
TilePadingBottom   = 100

Direction_RightX   = display.width -171
Direction_RightY   = 115

Direction_LeftX    = 140
Direction_LeftY	   = 140

Direction_TopX     = 360
Direction_TopY     = display.height - 150

Direction_BottomX  = 150
Direction_BottomY  = 45


--ccb 麻将的 长宽高 属性
TileProperty = {
	height         = 152,
	width          = 98,
	content_height = 152,
	content_width  = 122,
	padding_x      = (122 - 98)/2,
	padding_y      = (152 - 98)/2,

	--左右牌 有重叠 减去重叠的值
	cover_height = 64,
	stand_height = 44,
	open_height  = 74,
}

TileDefine = {}
TileDefine.eTile = {
	Tile_Invaid = 255,
	Tile_Wan_1  = 1,
	Tile_Wan_2  = 2,
	Tile_Wan_3  = 3,
	Tile_Wan_4  = 4,
	Tile_Wan_5  = 5,
	Tile_Wan_6  = 6,
	Tile_Wan_7  = 7,
	Tile_Wan_8  = 8,
	Tile_Wan_9  = 9,

	Tile_Tiao_1 = 17,
	Tile_Tiao_2 = 18,
	Tile_Tiao_3 = 19,
	Tile_Tiao_4 = 20,
	Tile_Tiao_5 = 21,
	Tile_Tiao_6 = 22,
	Tile_Tiao_7 = 23,
	Tile_Tiao_8 = 24,
	Tile_Tiao_9 = 25,

	Tile_Tong_1 = 33,
	Tile_Tong_2 = 34,
	Tile_Tong_3 = 35,
	Tile_Tong_4 = 36,
	Tile_Tong_5 = 37,
	Tile_Tong_6 = 38,
	Tile_Tong_7 = 39,
	Tile_Tong_8 = 40,
	Tile_Tong_9 = 41,

	Tile_Zhong  = 141,
	Tile_Fa     = 142,
	Tile_Bai    = 143,
	Tile_East   = 144,
	Tile_South  = 145,
	Tile_West   = 146,
	Tile_North  = 147,
	Tile_Spring = 148,
	Tile_Summer = 149,
	Tile_Autumn = 150,
	Tile_Winter = 151,

	Tile_PlumBlossom   = 152,--梅
	Tile_Orchid        = 153,--兰
	Tile_Bamboo        = 154,--竹
	Tile_Chrysanthemum = 155,--菊	
}

TileDefine.enum = {

	[TileDefine.eTile.Tile_Wan_1]    = {"一万","mj_1.png","sound/wan1_man_d.mp3", "sfx/woman/yiwan.mp3"},
	[TileDefine.eTile.Tile_Wan_2]    = {"二万","mj_2.png","sound/wan2_man_d.mp3", "sfx/woman/erwan.mp3"},
	[TileDefine.eTile.Tile_Wan_3]    = {"三万","mj_3.png","sound/wan3_man_d.mp3", "sfx/woman/sanwan.mp3"},
	[TileDefine.eTile.Tile_Wan_4]    = {"四万","mj_4.png","sound/wan4_man_d.mp3", "sfx/woman/siwan.mp3"},
	[TileDefine.eTile.Tile_Wan_5]    = {"五万","mj_5.png","sound/wan5_man_d.mp3", "sfx/woman/wuwan.mp3"},
	[TileDefine.eTile.Tile_Wan_6]    = {"六万","mj_6.png","sound/wan6_man_d.mp3", "sfx/woman/liuwan.mp3"},
	[TileDefine.eTile.Tile_Wan_7]    = {"七万","mj_7.png","sound/wan7_man_d.mp3", "sfx/woman/qiwan.mp3"},
	[TileDefine.eTile.Tile_Wan_8]    = {"八万","mj_8.png","sound/wan8_man_d.mp3", "sfx/woman/bawan.mp3"},
	[TileDefine.eTile.Tile_Wan_9]    = {"九万","mj_9.png","sound/wan9_man_d.mp3", "sfx/woman/jiuwan.mp3"},
	
	[TileDefine.eTile.Tile_Tiao_1] = {"一条","mj_11.png","sound/tiao1_man_d.mp3", "sfx/woman/yitiao.mp3"},
	[TileDefine.eTile.Tile_Tiao_2] = {"二条","mj_12.png","sound/tiao2_man_d.mp3", "sfx/woman/ertiao.mp3"},
	[TileDefine.eTile.Tile_Tiao_3] = {"三条","mj_13.png","sound/tiao3_man_d.mp3", "sfx/woman/santiao.mp3"},
	[TileDefine.eTile.Tile_Tiao_4] = {"四条","mj_14.png","sound/tiao4_man_d.mp3", "sfx/woman/sitiao.mp3"},
	[TileDefine.eTile.Tile_Tiao_5] = {"五条","mj_15.png","sound/tiao5_man_d.mp3", "sfx/woman/wutiao.mp3"},
	[TileDefine.eTile.Tile_Tiao_6] = {"六条","mj_16.png","sound/tiao6_man_d.mp3", "sfx/woman/liutiao.mp3"},
	[TileDefine.eTile.Tile_Tiao_7] = {"七条","mj_17.png","sound/tiao7_man_d.mp3", "sfx/woman/qitiao.mp3"},
	[TileDefine.eTile.Tile_Tiao_8] = {"八条","mj_18.png","sound/tiao8_man_d.mp3", "sfx/woman/batiao.mp3"},
	[TileDefine.eTile.Tile_Tiao_9] = {"九条","mj_19.png","sound/tiao9_man_d.mp3", "sfx/woman/jiutiao.mp3"},
	
	[TileDefine.eTile.Tile_Tong_1] = {"一筒","mj_21.png","sound/tong1_man_d.mp3", "sfx/woman/yibing.mp3"},
	[TileDefine.eTile.Tile_Tong_2] = {"二筒","mj_22.png","sound/tong2_man_d.mp3", "sfx/woman/erbing.mp3"},
	[TileDefine.eTile.Tile_Tong_3] = {"三筒","mj_23.png","sound/tong3_man_d.mp3", "sfx/woman/sanbing.mp3"},
	[TileDefine.eTile.Tile_Tong_4] = {"四筒","mj_24.png","sound/tong4_man_d.mp3", "sfx/woman/sibing.mp3"},
	[TileDefine.eTile.Tile_Tong_5] = {"五筒","mj_25.png","sound/tong5_man_d.mp3", "sfx/woman/wubing.mp3"},
	[TileDefine.eTile.Tile_Tong_6] = {"六筒","mj_26.png","sound/tong6_man_d.mp3", "sfx/woman/liubing.mp3"},
	[TileDefine.eTile.Tile_Tong_7] = {"七筒","mj_27.png","sound/tong7_man_d.mp3", "sfx/woman/qibing.mp3"},
	[TileDefine.eTile.Tile_Tong_8] = {"八筒","mj_28.png","sound/tong8_man_d.mp3", "sfx/woman/babing.mp3"},
	[TileDefine.eTile.Tile_Tong_9] = {"九筒","mj_29.png","sound/tong9_man_d.mp3", "sfx/woman/jiubing.mp3"}	
}

LockTileType =
{
	LockTileType_Normal		= 0,	-- 没锁 小于等于这个数的枚举都可打出去
	LockTileType_Lock		= 1		-- 锁牌
}

TileDirection = 
{
	Direction_Bottom	= 1,	
	Direction_Right		= 2,	
	Direction_Top       = 3,
	Direction_Left		= 4,
}

TileState = 
{
	TileType_Cover		= 1,	--盖
	TileType_Stand		= 2,		-- 技能锁 不能打出去 不能吃碰杠
	TileType_Open		= 3,
}

TileDefine.Stand_bg = {
	[TileDirection.Direction_Bottom] = {"green_mj_bg2.png", "blue_mj_bg2.png"},
	[TileDirection.Direction_Right]  = {"green_mj_bg7.png", "blue_mj_bg7.png"},
	[TileDirection.Direction_Top]    = {"green_mj_bg5.png", "blue_mj_bg5.png"},
	[TileDirection.Direction_Left]   = {"green_mj_bg7.png", "blue_mj_bg7.png"}	
}

TileDefine.Cover_bg = {
	[TileDirection.Direction_Bottom] = {"green_mj_bg4.png", "blue_mj_bg4.png"},
	[TileDirection.Direction_Right]  = {"green_mj_bg6.png", "blue_mj_bg6.png"},
	[TileDirection.Direction_Top]    = {"green_mj_bg4.png", "blue_mj_bg4.png"},
	[TileDirection.Direction_Left]   = {"green_mj_bg6.png", "blue_mj_bg6.png"}	
}

TileDefine.Open_bg = {
	[TileDirection.Direction_Bottom] = {"green_mj_bg1.png", "blue_mj_bg1.png"},
	[TileDirection.Direction_Right]  = {"green_mj_bg3.png", "blue_mj_bg3.png"},
	[TileDirection.Direction_Top]    = {"green_mj_bg1.png", "blue_mj_bg1.png"},
	[TileDirection.Direction_Left]   = {"green_mj_bg3.png", "blue_mj_bg3.png"}	
}

TileDefine.Stand_ccp = {
	[TileDirection.Direction_Bottom] = {61, 68},
	[TileDirection.Direction_Right]  = {0, 0},
	[TileDirection.Direction_Top]    = {0, 0},
	[TileDirection.Direction_Left]   = {0, 0}	
}

TileDefine.Open_ccp = {
	[TileDirection.Direction_Bottom] = {61, 83},
	[TileDirection.Direction_Right]  = {61, 90},
	[TileDirection.Direction_Top]    = {61, 83},
	[TileDirection.Direction_Left]   = {61, 90}	
}

TileDefine.Scale = {
	[TileDirection.Direction_Bottom] = 0.7,
	[TileDirection.Direction_Right]  = 0.5,
	[TileDirection.Direction_Top]    = 0.35,
	[TileDirection.Direction_Left]   = 0.5,	
}




return TileDefine