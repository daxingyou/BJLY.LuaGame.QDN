
local WeiXin = require("app.common.sdk.MissionWeiXin")
local CallNative = require("app.common.sdk.CallNative")

local m = {}

m.shareType = {
	friendCircle = 1,
	friendQun = 0,
}

function m:copyTxt(strTxt)
	local args = {strTxt}
    if "ios" == device.platform then
        return my.TPFunction:copyText(strTxt)
    elseif "android" == device.platform then
		return CallNative:copyTxt(strTxt)
    elseif "windows" == device.platform then
    
    end
end
function m:getAppVersion()
	local ok,version 
    if "ios" == device.platform then
        version = my.TPFunction:getVersion()
    elseif "android" == device.platform then		
		ok,version = CallNative:getAppVersion()
    elseif "windows" == device.platform then
    
    end
    return version
end
function m:printScreen(name)
    local size = cc.Director:getInstance():getWinSize()
    local screen = cc.RenderTexture:create(size.width,size.height,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,gl.DEPTH24_STENCIL8_OES)
    local scene = cc.Director:getInstance():getRunningScene()
    screen:begin()
    scene:visit()
    screen:endToLua()
    screen:saveToFile(name,cc.IMAGE_FORMAT_JPEG,false)
end
function m:printScreenNoSave()
    local size = cc.Director:getInstance():getWinSize()
    local screen = cc.RenderTexture:create(size.width,size.height,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,gl.DEPTH24_STENCIL8_OES)
    local scene = cc.Director:getInstance():getRunningScene()
    screen:begin()
    scene:visit()
    screen:endToLua()
    local texture = screen:getSprite():getTexture()
    return texture
end

function m:getBatteryValue()
	local power = 0.2
    if "ios" == device.platform then
    	power = my.TPFunction:getPower()
    elseif "android" == device.platform then
		power = CallNative:getBatteryPercent()
		power = string.format("%.2f",power)
    elseif "windows" == device.platform then
    end
    return power
end


function m:loginWeiXin()
    if "ios" == device.platform then
        my.TPFunction:sendAuthWeiXin()
    elseif "android" == device.platform then
		WeiXin:loginWeiXin()
    elseif "windows" == device.platform then

    end
end

function m:shareImageWX(_imgPath,_type)
    if "ios" == device.platform then
        my.TPFunction:shareWithWeixinImg("",_imgPath,_type)
    elseif "android" == device.platform then
		WeiXin:shareImageWX(_imgPath,_type)
    elseif "windows" == device.platform then

    end
end

function m:shareTextWX(_txt,_type)
    if "ios" == device.platform then
        my.TPFunction:shareWithWeixinTxt("","",desc,_type)
    elseif "android" == device.platform then
		WeiXin:shareTextWX(_txt,_type)
    elseif "windows" == device.platform then

    end
end

function m:shareUrlWX(url,title,desc,_type)
    if "ios" == device.platform then
        my.TPFunction:shareWithWeixinTxt(url,title,desc,_type)
    elseif "android" == device.platform then
		WeiXin:shareUrlWX(url,title,desc,_type)
    elseif "windows" == device.platform then

    end
end

function m:popDialog(_msg)
    my.TPFunction:messageBox("脚本错误，请截图给程序！", _msg)
end







return m