
local m = {}

m.settingUIKey = {
	
}

m.key = {
	activityImgList = "activityImgList",--{}
}

m.CustomEventKey = {
	Laba = "Laba",
	UpdateHeadInfo = "UpdateHeadInfo",
}


m.Chat = {
	Emoji_Tag_Start = 100,  --[101,102,...,199]
	CommonLanguage_Tag_Start = 200, --[201,202,...,299]
	comLanguage = {
	    "菩萨、菩萨来个卡卡！",
	    "麻将有首歌，上碰下自摸！",
	    "你当慢老火啊掰！",
	    "老板来噶咯！",
	    "你这咚挡水岩，我一颗都摸不到!",
	    "这个胡得有点没好意思噶！",
	    "鬼仔，你当会打牌啊！",
	    "该出手时就出手，杠上开花有没有！ ",
	},
	emoji_num = {8,3,2,9,6,6,4,5,9,4,3,4},
	enoji_path_format = "res/RoomScene/srcRes/emoji/emoji_%d_%d.png"
}

return m -- g_enumKey