local m = {}
local _n = {}

m.GameType = {
    TianZhu = 1,
    LiPing = 2,
    JingPing = 3,
}

m.Config = {
    appName = "来呀黔东南麻将",
    shareUrl = "http://d.laiyagame.com/qdn/download.html",
}

m.shareType = {
	friendCircle = 1,
	friendQun = 0,
}

_n.loginWeiXinSig = {
	javaClassName = "com/base/lua/WXHelper",
	javaMethodName = "LoginWX",
	javaMethodSig = "()V",
}
function m:loginWeiXin()
	local args = {}
    if "ios" == device.platform then
    elseif "android" == device.platform then
		local ok,res = luaj.callStaticMethod(_n.loginWeiXinSig.javaClassName,_n.loginWeiXinSig.javaMethodName,args,_n.loginWeiXinSig.javaMethodSig)
		print("-----loginWeiXin-----",ok,res)
		return ok	
    elseif "windows" == device.platform then
    
    end
end

_n.shareImageWXSig = {
	javaClassName = "com/base/lua/WXHelper",
	javaMethodName = "ShareImageWX",
	javaMethodSig = "(Ljava/lang/String;I)V",
}
function m:shareImageWX(_imgPath,_type)
	local args = {_imgPath,_type}
    if "ios" == device.platform then
    elseif "android" == device.platform then
		local ok,res = luaj.callStaticMethod(_n.shareImageWXSig.javaClassName,_n.shareImageWXSig.javaMethodName,args,_n.shareImageWXSig.javaMethodSig)
		print("-----shareImageWX-----",ok,res)
		return ok	
    elseif "windows" == device.platform then
    
    end
end

_n.shareTextWXSig = {
	javaClassName = "com/base/lua/WXHelper",
	javaMethodName = "ShareTextWX",
	javaMethodSig = "(Ljava/lang/String;I)V",
}
function m:shareTextWX(_txt,_type)
	local args = {_txt,_type}
    if "ios" == device.platform then
    elseif "android" == device.platform then
		local ok,res = luaj.callStaticMethod(_n.shareTextWXSig.javaClassName,_n.shareTextWXSig.javaMethodName,args,_n.shareTextWXSig.javaMethodSig)
		print("-----loginWeiXin-----",ok,res)
		return ok	
    elseif "windows" == device.platform then
    
    end
end

_n.shareUrlWXSig = {
	javaClassName = "com/base/lua/WXHelper",
	javaMethodName = "ShareUrlWX",
	javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V",
}
function m:shareUrlWX(url,title,desc,_type)
	local args = {url,title,desc,_type}
    if "ios" == device.platform then
    elseif "android" == device.platform then
		local ok,res = luaj.callStaticMethod(_n.shareUrlWXSig.javaClassName,_n.shareUrlWXSig.javaMethodName,args,_n.shareUrlWXSig.javaMethodSig)
		print("-----shareUrlWX-----",ok,res)
		return ok	
    elseif "windows" == device.platform then
    
    end
end
function m:shareMainWeixinCircle()
	--分享朋友圈
    local shareDes =g_data.userSys.shareWxCircleContent --"最正宗的天柱麻将,好友约局神器,快来一起加入吧!邀请码:%s,记得要绑定我呦!"
    local share_des = "100%正宗黔东南玩法，好友约局神器，邀请码%s，点击下载快来加入！"
    if shareDes == nil or shareDes == "" then
        shareDes = "100%正宗黔东南玩法，好友约局神器，邀请码"..g_data.userSys.InviteCode.."，点击下载快来加入！" --string.format(share_des,g_data.userSys.InviteCode or 0)
    end
    g_ToLua:shareUrlWX(self.Config.shareUrl,shareDes,shareDes,g_ToLua.shareType.friendCircle)
end
function m:shareMainWeixinByType(_type)
	print("zoule2222222222222222222")
	local shareDes =g_data.userSys.shareWxCircleContent --"最正宗的天柱麻将,好友约局神器,快来一起加入吧!邀请码:%s,记得要绑定我呦!"
    local share_des = "100%正宗黔东南玩法，好友约局神器，邀请码%s，点击下载快来加入！"
    if shareDes == nil or shareDes == "" then
            shareDes = "100%正宗黔东南玩法，好友约局神器，邀请码"..g_data.userSys.InviteCode.."，点击下载快来加入！"
    end
    if _type == g_ToLua.shareType.friendCircle then
        g_ToLua:shareUrlWX(self.Config.shareUrl,shareDes,shareDes,_type)
    else
        g_ToLua:shareUrlWX(self.Config.shareUrl,self.Config.appName,shareDes,_type)
    end
end

return m
