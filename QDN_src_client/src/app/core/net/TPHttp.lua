--[[
	http封装
  ]]


local TPHttp = {}
local db = {}
local cookie = {}--增加cookes

--注册一个http的回调监听
function TPHttp.listeners(_tag, _success, _fail, _progress)
	if not db[_tag] then db[_tag] = {} end
	db[_tag].fail       = _fail
	db[_tag].success    = _success
	db[_tag].progress 	= _progress
end

--取消注册
function TPHttp.unlisteners(_tag)
	if db[_tag] then
		db[_tag] = nil
	end
end

--请求http
function TPHttp.request(_way, _url, _data, _listenTag, _subTag, _savaPath)
	print("TPHttp.request", _url)
	local tag = _listenTag
    --请求回调
	local function httpCallback(_event)
	    local event   = _event
	    local ok      = ( event.name == "completed" )
	    local request = event.request
	    --成功
	    if "completed" == event.name then
	    	local code = request:getResponseStatusCode()
	        if 200==code then --成功
	            local response = request:getResponseData()
		    	print("http success,respose size:",request:getResponseDataLength())
		    	local cookiestr = event.request:getCookieString()
		    	if string.len(cookiestr) >5 then
		    		cookie = network.parseCookie(cookiestr)
		    	end
		    	--保存文件
		        if _savaPath then
				    request:saveResponseData(_savaPath)
				    print("HTTP saveFile ".._savaPath.." done!")
		    	end
		    	--成功回调
		    	if db[tag] and db[tag].success then
		        	db[tag].success(response, _subTag)
		        end
	        else --失败
	            print("http请求失败，返回码: ", code)
	            local res = {}
	            res.response = request:getResponseData()
	            res.code = code.."+"
	            if db[tag] and db[tag].fail then
	            	db[tag].fail(res, _subTag)
	            end
	        end
	    --请求失败，地址错或者网络不通
	    elseif "failed" == event.name then
	    	local res = {}
            res.response = "Not Found"
            res.code = 404
            if request then
            	print("http请求失败: ",request:getErrorCode(), request:getErrorMessage())
        	end
        	-- g_SMG:removeWaitLayer()
            if db[tag] and db[tag].fail then
            	db[tag].fail(res, _subTag)
            end
	    --下载进度
		elseif "progress" == event.name then
			if db[tag] and db[tag].progress then
				db[tag].progress( event.total, event.dltotal, _subTag)
			end
	    --取消请求
	    elseif "cancelled" == event.name then
	    	print("TPHttp.request cancelled")
	    --未知情况 unknown
		else
			print("TPHttp.request unknown")
		end
	end
	--发送请求
	-- print("TPHttp _url", _url)
    local request = network.createHTTPRequest(httpCallback, _url, _way)
    if _way == "POST" then
    	request:setCookieString(network.makeCookieString(cookie))
        request:setPOSTData(_data)
 
  --       for k, v in pairs(_data) do
		-- 	request:addPOSTValue(k,v)
		-- end
    end
    -- request:setTimeout(10)
    request:start()
end

--get
function TPHttp.GET(_url, _listenTag, _subTag)
	TPHttp.request("GET", _url, nil, _listenTag, _subTag, nil)
end

--post
function TPHttp.POST(_url, _data, _listenTag, _subTag)
	TPHttp.request("POST", _url, json.encode(_data), _listenTag, _subTag, nil)
end

--dowload
function TPHttp.Download(_url, _listenTag, _subTag, _savaPath)
	TPHttp.request("GET", _url, nil, _listenTag, _subTag, _savaPath)
end

return TPHttp
