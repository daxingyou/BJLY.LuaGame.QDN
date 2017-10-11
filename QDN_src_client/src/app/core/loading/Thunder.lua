--
-- Author: dhd
-- 下载管理器
--

local scheduler = require("framework.scheduler")

local TASK_UPDATE_TIME = 0.1 --定时器检测时间(秒)
local RECONNECT_MAX = 3	--重连次数限制，超过以后开始进入休眠
local RECONNECT_PAUSE_TIME = 20	--重试休眠时间(秒)
local DOWNLOAD_FOLDER_PATH = device.writablePath.."download/"

local TASK_AUTO_ID = 1000 --任务自增ID头
--任务3状态
local STATE = {
	WAIT = 0,
	START = 1,
	RUN = 2,
	END = 3,
}

local Thunder = class("Thunder")

Thunder.TASK_WAIT = "THUNDER_TASK_WAIT"
Thunder.TASK_STATE = "THUNDER_TASK_STATE"
Thunder.TASK_RUN = "THUNDER_TASK_RUN"
Thunder.TASK_END = "THUNDER_TASK_END"

function Thunder:ctor()
	self.m_taskScheduler = nil
	self.m_head = nil
	self.m_tasks = {}
	self.m_notifys = {}
	self.totalTask =0

end

--启动定时器
function Thunder:start()
	if self.m_taskScheduler then return end
	print("Thunder:start")
	--定时器任务
	local __updateTask = function()
		--取头结点任务
		local head = self.m_tasks[1]
		self.m_head = head

		if not head then
			return
		end
		--任务状态处理
		if STATE.WAIT == head.state then --等待中，切换到开始
			--任务休眠
			if head.pause_time > 0 then
				head.pause_time = head.pause_time - 1
				self:moveTaskLast(head)

			else
				head.state = STATE.START
			end

		elseif STATE.START == head.state then --开始下载
			self:post(Thunder.TASK_STATE)
			local _url = head.url.."/update.manifest"
			self:_HTTP(_url,head.tag,handler(self,self.unManifest))
			head.state = STATE.RUN

		elseif STATE.RUN == head.state then --下载中，对外推送进度
			self:post(Thunder.TASK_RUN)

		elseif STATE.END == head.state then --结束了，移除任务
			self:post(Thunder.TASK_END)
			self:save()  --todo
			table.remove(self.m_tasks, 1)
			--如果都没有任务了，自动停止
			print("#self.m_tasks = ",#self.m_tasks)
			if 0 == #self.m_tasks then

				self:stop()
			end
		end
	end
	--启动
	self.m_taskScheduler = scheduler.scheduleGlobal(__updateTask, TASK_UPDATE_TIME)
end

function Thunder:_HTTP(_url, filename, _SuccessCallback)

	local request = network.createHTTPRequest(
		function(event)
			if event.name == "completed" then
				local request = event.request
				local code = request:getResponseStatusCode()
				if 200 == code then
					print("Thunder:_HTTP SuccessCallback")
					_SuccessCallback(event,filename)
				else
					print("Thunder:_HTTP errorcode", code)
				end
			elseif event.name == "inprogress" then
				
			elseif event.name == "failed" then
				print("Thunder:_HTTP failde")

			end
	end, _url, "GET")
	request:setTimeout(60)
	request:start()
end


--获取 Manifest 成功
function Thunder:unManifest(event,filename)
	local request = event.request
	local str = request:getResponseString()

	-- 缓存远程更新列表 
	self.remoteListSrc = str
	local ver_endPos    = string.find(str, '\n')
	local ver_str       = string.sub(str, 1, ver_endPos - 1)
	self.m_head.version = string.split(ver_str, ':')[2]

	-- 删掉 version
	local remain_str = string.sub(str, ver_endPos + 1)
	local ver_name_endPos = string.find(remain_str, '\n')
	local ver_name_str = string.sub(remain_str, 1, ver_name_endPos - 1)
	self.m_head.version_name = string.split(ver_name_str, ':')[2]

	-- 删掉 version_name
	remain_str = string.sub(remain_str, ver_name_endPos + 1)

	local cdn_url_endPos = string.find(remain_str, '\n')
	local cdn_url_str = string.sub(remain_str, 1, cdn_url_endPos - 1)

	-- 第一个:位置
	local head_url_pos = string.find(cdn_url_str, ':')
	self.m_head.cdn_url = string.sub(cdn_url_str, head_url_pos + 1)

	local list_str	  = string.sub(remain_str, cdn_url_endPos + 1)

	self.m_head.needDowns = loadstring(list_str)()
	self.m_head.kbmax       =  #self.m_head.needDowns

	self:update()
end

function Thunder:update()

	local tabel = self.m_head.needDowns[1]

	if not tabel then
		self.m_head.state = STATE.END  --结束
		return
	end
	local name = tabel.name
	
	local url  = self.m_head.url.."/"..name
	self:_HTTP(url,name,handler(self,self.update_Success))
end

--递归下载
function Thunder:update_Success(event, name)
	self.m_head.downs[name] = event.request:getResponseData()
	self.m_head.kbnum = self.m_head.kbnum +1
	table.remove(self.m_head.needDowns, 1)
	self:update()
end

function Thunder:save()
	for k, v in pairs(self.m_head.downs) do
		self:checkDir(DOWNLOAD_FOLDER_PATH, k)
		self:saveFile(DOWNLOAD_FOLDER_PATH, k, v)
	end
	-- 保存版本号
	self:updateVersion(self.m_head.version, self.m_head.version_name)
end


-- 延时重启
function Thunder:reload()
	local loaded = table.keys( package.loaded )
    for k,v in pairs(loaded) do
        if string.find(v,"app.")    == 1  then
            print(v)
            package.loaded[ v ] = nil
        end
    end
    collectgarbage("collect")
    package.loaded["main"] = nil
    require("main")
end	

function Thunder:checkDir(path, name)
	 local FileUtils = cc.FileUtils:getInstance()
    --资源主目录
    
	local dirList = string.split(name, '/')
	local dirListLen = #dirList - 1
	local destPath = path
	for i = 1, dirListLen do
		destPath = destPath .. dirList[i] ..'/'
		if not FileUtils:isFileExist(destPath) then
			FileUtils:createDirectory(destPath)
			-- io.mkdir(destPath)
		end
	end
end

function Thunder:saveFile(path, name, content)
	io.writefile(path .. name, content)
end

--更新版本号
function Thunder:updateVersion(versioncode, versionname)
	
	local clientVersion = g_LocalDB:save("clientversion", versionname) 
	-- ConfigUtil:setVersion_code(globalval.versionCode)
	-- ConfigUtil:setVersion_name(globalval.version)
end

--停止
function Thunder:stop()
	print("Thunder:stop")
	if self.m_taskScheduler then scheduler.unscheduleGlobal(self.m_taskScheduler) end
	self.m_taskScheduler = nil
	self:unregAllNotice()

	scheduler.performWithDelayGlobal(handler(self, self.reload), 0.2)
end

--添加任务(任务标识)
function Thunder:addTask(_tag, _url)

	if not _tag or not _url  then return end

	local task = {}
	self.totalTask = self.totalTask + 1
	--自增长ID
	TASK_AUTO_ID = TASK_AUTO_ID + 1
	task.id = TASK_AUTO_ID
	--外部传递值
	task.tag = _tag
	task.version_name = _tag
	task.url = _url
	--任务状态
	task.state = STATE.WAIT
	task.kbnum = 1 --已下载字节数
	task.kbmax = 0 --最大字节数

	task.recount = 0 --任务重试次数
	task.pause_time = 0 --休眠时间
	task.downs ={}

	table.insert(self.m_tasks, task)
	self:start()
	return task
end

--取任务
function Thunder:getTask(_tag, _url)
	for i,v in ipairs(self.m_tasks) do
		if v.tag == _tag and v.url == _url then
			return v
		end
	end
	return nil
end

--删除任务
function Thunder:delTask(_id)
	for i,v in ipairs(self.m_tasks) do
		if v.id == _id then
			table.remove(self.m_tasks, i)
			break
		end
	end
end

--移动任务到末尾
function Thunder:moveTaskLast(_task)
	if not _task then return end
	self:delTask(_task.id)
	table.insert(self.m_tasks, _task)
end

--取任务集合
function Thunder:getTaskList(_tag)
	local list = {}
	for i,v in ipairs(self.m_tasks) do
		if v.tag == _tag then
			table.insert(list, v)
		end
	end
	return list
end

--添加通知对象 待优化
function Thunder:regNotice(_tag, _fun)

	self.m_notifys[_tag] = _fun
end

--移除通知对象
function Thunder:unregNotice(_tag)
	self.m_notifys[_tag] = nil
end

--推送任务通知
function Thunder:post(_event)
	local tag = self.m_head.tag
	for k,v in pairs(self.m_notifys) do
		-- if k == tag then
		v(_event, self.m_head)
		-- 	break
		-- end
	end
end

--移除所有通知对象
function Thunder:unregAllNotice()
	self.m_notifys = {}
end

return Thunder
