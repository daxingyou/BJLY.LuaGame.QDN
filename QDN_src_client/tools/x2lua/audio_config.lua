local audio_config = {}

local card={
	[1] = { ["name"]="一万",["man_native"]="wan1_man_d.mp3",["woman_native"]="wan1_woman_d.mp3",["man_common"]="wan1_man_p.mp3",["woman_common"]="wan1_woman_p.mp3", },
	[2] = { ["name"]="二万",["man_native"]="wan2_man_d.mp3",["woman_native"]="wan2_woman_d.mp3",["man_common"]="wan2_man_p.mp3",["woman_common"]="wan2_woman_p.mp3", },
	[3] = { ["name"]="三万",["man_native"]="wan3_man_d.mp3",["woman_native"]="wan3_woman_d.mp3",["man_common"]="wan3_man_p.mp3",["woman_common"]="wan3_woman_p.mp3", },
	[4] = { ["name"]="四万",["man_native"]="wan4_man_d.mp3",["woman_native"]="wan4_woman_d.mp3",["man_common"]="wan4_man_p.mp3",["woman_common"]="wan4_woman_p.mp3", },
	[5] = { ["name"]="五万",["man_native"]="wan5_man_d.mp3",["woman_native"]="wan5_woman_d.mp3",["man_common"]="wan5_man_p.mp3",["woman_common"]="wan5_woman_p.mp3", },
	[6] = { ["name"]="六万",["man_native"]="wan6_man_d.mp3",["woman_native"]="wan6_woman_d.mp3",["man_common"]="wan6_man_p.mp3",["woman_common"]="wan6_woman_p.mp3", },
	[7] = { ["name"]="七万",["man_native"]="wan7_man_d.mp3",["woman_native"]="wan7_woman_d.mp3",["man_common"]="wan7_man_p.mp3",["woman_common"]="wan7_woman_p.mp3", },
	[8] = { ["name"]="八万",["man_native"]="wan8_man_d.mp3",["woman_native"]="wan8_woman_d.mp3",["man_common"]="wan8_man_p.mp3",["woman_common"]="wan8_woman_p.mp3", },
	[9] = { ["name"]="九万",["man_native"]="wan9_man_d.mp3",["woman_native"]="wan9_woman_d.mp3",["man_common"]="wan9_man_p.mp3",["woman_common"]="wan9_woman_p.mp3", },
	[17] = { ["name"]="一条",["man_native"]="tiao1_man_d.mp3",["woman_native"]="tiao1_woman_d.mp3",["man_common"]="tiao1_man_p.mp3",["woman_common"]="tiao1_woman_p.mp3", },
	[18] = { ["name"]="二条",["man_native"]="tiao2_man_d.mp3",["woman_native"]="tiao2_woman_d.mp3",["man_common"]="tiao2_man_p.mp3",["woman_common"]="tiao2_woman_p.mp3", },
	[19] = { ["name"]="三条",["man_native"]="tiao3_man_d.mp3",["woman_native"]="tiao3_woman_d.mp3",["man_common"]="tiao3_man_p.mp3",["woman_common"]="tiao3_woman_p.mp3", },
	[20] = { ["name"]="四条",["man_native"]="tiao4_man_d.mp3",["woman_native"]="tiao4_woman_d.mp3",["man_common"]="tiao4_man_p.mp3",["woman_common"]="tiao4_woman_p.mp3", },
	[21] = { ["name"]="五条",["man_native"]="tiao5_man_d.mp3",["woman_native"]="tiao5_woman_d.mp3",["man_common"]="tiao5_man_p.mp3",["woman_common"]="tiao5_woman_p.mp3", },
	[22] = { ["name"]="六条",["man_native"]="tiao6_man_d.mp3",["woman_native"]="tiao6_woman_d.mp3",["man_common"]="tiao6_man_p.mp3",["woman_common"]="tiao6_woman_p.mp3", },
	[23] = { ["name"]="七条",["man_native"]="tiao7_man_d.mp3",["woman_native"]="tiao7_woman_d.mp3",["man_common"]="tiao7_man_p.mp3",["woman_common"]="tiao7_woman_p.mp3", },
	[24] = { ["name"]="八条",["man_native"]="tiao8_man_d.mp3",["woman_native"]="tiao8_woman_d.mp3",["man_common"]="tiao8_man_p.mp3",["woman_common"]="tiao8_woman_p.mp3", },
	[25] = { ["name"]="九条",["man_native"]="tiao9_man_d.mp3",["woman_native"]="tiao9_woman_d.mp3",["man_common"]="tiao9_man_p.mp3",["woman_common"]="tiao9_woman_p.mp3", },
	[33] = { ["name"]="一筒",["man_native"]="tong1_man_d.mp3",["woman_native"]="tong1_woman_d.mp3",["man_common"]="tong1_man_p.mp3",["woman_common"]="tong1_woman_p.mp3", },
	[34] = { ["name"]="二筒",["man_native"]="tong2_man_d.mp3",["woman_native"]="tong2_woman_d.mp3",["man_common"]="tong2_man_p.mp3",["woman_common"]="tong2_woman_p.mp3", },
	[35] = { ["name"]="三筒",["man_native"]="tong3_man_d.mp3",["woman_native"]="tong3_woman_d.mp3",["man_common"]="tong3_man_p.mp3",["woman_common"]="tong3_woman_p.mp3", },
	[36] = { ["name"]="四筒",["man_native"]="tong4_man_d.mp3",["woman_native"]="tong4_woman_d.mp3",["man_common"]="tong4_man_p.mp3",["woman_common"]="tong4_woman_p.mp3", },
	[37] = { ["name"]="五筒",["man_native"]="tong5_man_d.mp3",["woman_native"]="tong5_woman_d.mp3",["man_common"]="tong5_man_p.mp3",["woman_common"]="tong5_woman_p.mp3", },
	[38] = { ["name"]="六筒",["man_native"]="tong6_man_d.mp3",["woman_native"]="tong6_woman_d.mp3",["man_common"]="tong6_man_p.mp3",["woman_common"]="tong6_woman_p.mp3", },
	[39] = { ["name"]="七筒",["man_native"]="tong7_man_d.mp3",["woman_native"]="tong7_woman_d.mp3",["man_common"]="tong7_man_p.mp3",["woman_common"]="tong7_woman_p.mp3", },
	[40] = { ["name"]="八筒",["man_native"]="tong8_man_d.mp3",["woman_native"]="tong8_woman_d.mp3",["man_common"]="tong8_man_p.mp3",["woman_common"]="tong8_woman_p.mp3", },
	[41] = { ["name"]="九筒",["man_native"]="tong9_man_d.mp3",["woman_native"]="tong9_woman_d.mp3",["man_common"]="tong9_man_p.mp3",["woman_common"]="tong9_woman_p.mp3", },
}
audio_config.card = card

local operate={
	[1] = { ["name"]="碰",["man_native"]="man_peng_d.mp3",["woman_native"]="woman_peng_d.mp3",["man_common"]="man_peng_p.mp3",["woman_common"]="woman_peng_p.mp3", },
	[2] = { ["name"]="左杠",["man_native"]="man_minggang_d.mp3",["woman_native"]="woman_minggang_d.mp3",["man_common"]="man_minggang_p.mp3",["woman_common"]="woman_minggang_p.mp3", },
	[3] = { ["name"]="右杠",["man_native"]="man_minggang_d.mp3",["woman_native"]="woman_minggang_d.mp3",["man_common"]="man_minggang_p.mp3",["woman_common"]="woman_minggang_p.mp3", },
	[4] = { ["name"]="中杠",["man_native"]="man_minggang_d.mp3",["woman_native"]="woman_minggang_d.mp3",["man_common"]="man_minggang_p.mp3",["woman_common"]="woman_minggang_p.mp3", },
	[5] = { ["name"]="补杠",["man_native"]="man_bugang_d.mp3",["woman_native"]="woman_bugang_d.mp3",["man_common"]="man_bugang_p.mp3",["woman_common"]="woman_bugang_p.mp3", },
	[6] = { ["name"]="暗杠",["man_native"]="man_angang_d.mp3",["woman_native"]="woman_angang_d.mp3",["man_common"]="man_angang_p.mp3",["woman_common"]="woman_angang_p.mp3", },
	[7] = { ["name"]="听",["man_native"]="man_tianting_d.mp3",["woman_native"]="woman_tianting_d.mp3",["man_common"]="man_tianting_p.mp3",["woman_common"]="woman_tianting_p.mp3", },
	[8] = { ["name"]="胡",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[9] = { ["name"]="左碰",["man_native"]="man_peng_d.mp3",["woman_native"]="woman_peng_d.mp3",["man_common"]="man_peng_p.mp3",["woman_common"]="woman_peng_p.mp3", },
	[10] = { ["name"]="中碰",["man_native"]="man_peng_d.mp3",["woman_native"]="woman_peng_d.mp3",["man_common"]="man_peng_p.mp3",["woman_common"]="woman_peng_p.mp3", },
	[11] = { ["name"]="右碰",["man_native"]="man_peng_d.mp3",["woman_native"]="woman_peng_d.mp3",["man_common"]="man_peng_p.mp3",["woman_common"]="woman_peng_p.mp3", },
	[12] = { ["name"]="冲锋鸡",["man_native"]="man_chongfengji_d.mp3",["woman_native"]="woman_chongfengji_d.mp3",["man_common"]="man_chongfengji_p.mp3",["woman_common"]="woman_chongfengji_p.mp3", },
	[13] = { ["name"]="责任鸡",["man_native"]="man_zerenji_d.mp3",["woman_native"]="woman_zerenji_d.mp3",["man_common"]="man_zerenji_p.mp3",["woman_common"]="woman_zerenji_p.mp3", },
	[101] = { ["name"]="普通胡",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[102] = { ["name"]="大对子",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[103] = { ["name"]="七对",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[104] = { ["name"]="龙七对",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[105] = { ["name"]="清一色",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[106] = { ["name"]="清七对",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[107] = { ["name"]="清大对",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[108] = { ["name"]="青龙背",["man_native"]="man_hupai_d.mp3",["woman_native"]="woman_hupai_d.mp3",["man_common"]="man_hupai_p.mp3",["woman_common"]="woman_hupai_p.mp3", },
	[109] = { ["name"]="点炮",["man_native"]="man_dianpao_d.mp3",["woman_native"]="woman_dianpao_d.mp3",["man_common"]="man_dianpao_p.mp3",["woman_common"]="woman_dianpao_p.mp3", },
	[110] = { ["name"]="自摸",["man_native"]="man_zimo_d.mp3",["woman_native"]="woman_zimo_d.mp3",["man_common"]="man_zimo_p.mp3",["woman_common"]="woman_zimo_p.mp3", },
	[201] = { ["name"]="杠上开花",["man_native"]="man_gangkai_d.mp3",["woman_native"]="woman_gangkai_d.mp3",["man_common"]="man_gangkai_p.mp3",["woman_common"]="woman_gangkai_p.mp3", },
	[202] = { ["name"]="热跑",["man_native"]="man_repao_d.mp3",["woman_native"]="woman_repao_d.mp3",["man_common"]="man_repao_p.mp3",["woman_common"]="woman_repao_p.mp3", },
	[203] = { ["name"]="抢杠胡",["man_native"]="man_qianggang_d.mp3",["woman_native"]="woman_qianggang_d.mp3",["man_common"]="man_qianggang_p.mp3",["woman_common"]="woman_qianggang_p.mp3", },
}
audio_config.operate = operate

local music={
	["dlyy"] = { ["name"]="背景音乐1",["path"]="dlyy.mp3", },
	["yxyy"] = { ["name"]="背景音乐2",["path"]="yxyy.mp3", },
}
audio_config.music = music

local sound={
	["alarm"] = { ["name"]="钟表倒计时",["path"]="alarm.mp3", },
	["tiletouch"] = { ["name"]="牌点击",["path"]="tiletouch.mp3", },
	["tiletake"] = { ["name"]="发牌",["path"]="tiletake.mp3", },
}
audio_config.sound = sound

return audio_config