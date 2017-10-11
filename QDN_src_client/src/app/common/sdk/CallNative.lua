


local m = {}
m.copyTxtSig = {
	javaClassName = "com/laiya/game/tianzhuMJ/AppActivity",
	javaMethodName = "CopyText",
	javaMethodSig = "(Ljava/lang/String;)Z",
}
m.appVersion = {
	javaClassName = "com/laiya/game/tianzhuMJ/AppActivity",
	javaMethodName = "getAppVersion",
	javaMethodSig = "()Ljava/lang/String;"
}

m.batteryPercent = {
	javaClassName = "com/laiya/game/tianzhuMJ/AppActivity",
	javaMethodName = "getBatteryPercent",
	javaMethodSig = "()F"
}

function m:copyTxt(strTxt)
	local args = {strTxt}
    if "ios" == device.platform then
    elseif "android" == device.platform then
		local ok,res = luaj.callStaticMethod(self.copyTxtSig.javaClassName,self.copyTxtSig.javaMethodName,args,self.copyTxtSig.javaMethodSig)
		return ok	
    elseif "windows" == device.platform then
    
    end
end
function m:getAppVersion()
    if "ios" == device.platform then
    elseif "android" == device.platform then		
		local ok,vesion = luaj.callStaticMethod(self.appVersion.javaClassName,self.appVersion.javaMethodName,{},self.appVersion.javaMethodSig)
		return ok,vesion
    elseif "windows" == device.platform then
    
    end
end

function m:getBatteryPercent()
    if "ios" == device.platform then
    elseif "android" == device.platform then		
		local ok,res = luaj.callStaticMethod(self.batteryPercent.javaClassName,self.batteryPercent.javaMethodName,{},self.batteryPercent.javaMethodSig)
		-- res = res or 0.2
		-- res = string.format("%.2f",res*100) .. '%'
		return res
    elseif "windows" == device.platform then
    
    end
end

return m