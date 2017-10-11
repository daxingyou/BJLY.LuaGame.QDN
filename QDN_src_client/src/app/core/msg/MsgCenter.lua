--
-- 消息中心
-- Author: XuJian
--
local MsgCenter = class("MsgCenter")

function MsgCenter:ctor()
	self.list = {} --消息注册列表
end

--注册消息
--数据结构:  list[event][tag] -> func
function MsgCenter:reg(_tag, _event, _listener)
	local name = _tag
	print(_tag, _event, _listener)
	if type(_event) == "string" and type(_listener) == "function" then
		if not self.list[_event] then self.list[_event] = {} end
		self.list[_event][_tag] = _listener
		-- printf("[[通知中心 %s 注册 %s 成功! ]]", name, _event)
	else
		-- printf("[[通知中心 %s 注册 %s 失败! ]]", name, tostring(_event))
	end
end

--注销消息
function MsgCenter:unreg(_tag, _event)
	local name = _tag
	if type(_event) == "string" and self.list[_event] then
		self.list[_event][_tag] = nil
		-- printf("[[通知中心 %s 注销 %s 成功! ]]", name, _event)
	else
		-- printf("[[通知中心 %s 注销 %s 失败! ]]", name, tostring(_event))
	end
end

--清空中心
function MsgCenter:clear()
	self.list = {}
end

--post消息
function MsgCenter:post(_event, _data)
	assert(_event, "MsgCenter:post _event = nil")
	local target = self.list[_event]
	if not target then printf("[[通知中心 %s 不存在! ]]", _event) return end

	local msg    = { name = _event, data = _data }
	local target = self.list[ msg.name ]
	if target then
		for k,v in pairs(target) do
			printf("[[通知中心 向 %s 发送 %s 成功! ]]", k, msg.name)
			v( msg )
		end
	end
end

function MsgCenter:eventIsExit(_event,_tag)
	if self.list[_event] then
		local target = self.list[_event][_tag]
		if not target then  return false end
		return true
	else
		return false
	end
end

return MsgCenter
