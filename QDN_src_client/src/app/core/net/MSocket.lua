--[[
MSocket SocketTCP
author: XuJian
date: 2017-6-11
]]
local net = require("framework.cc.net.init")

local MSocket = class("MSocket")

function MSocket:ctor()
	cc.GameObject.extend(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	local socket = net.SocketTCP.new()
	socket:setName("SocketTcp")
	-- socket:setTickTime(1/60)
	-- socket:setReconnTime(6)
	socket:setConnFailTime(10)

	socket:addEventListener(net.SocketTCP.EVENT_DATA, handler(self, self.receiveData))
	socket:addEventListener(net.SocketTCP.EVENT_CLOSE, handler(self, self.tcpClose))
	socket:addEventListener(net.SocketTCP.EVENT_CLOSED, handler(self, self.tcpClosed))
	socket:addEventListener(net.SocketTCP.EVENT_CONNECTED, handler(self, self.tcpConnected))
	socket:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.tcpConnectedFail))
	self.m_socketTCP = socket

	--0是新数据读取，1数据会继续往后读
	self.m_readState = 0
	--数据包
	self.m_mparsePacket = require("app.core.net.MParsePacket").new()

end

--连接
function MSocket:connect(_ip, _port)
	self.m_socketTCP:connect(_ip, _port, false)
end

--发送数据
function MSocket:sendData(_bytes)
	self.m_socketTCP:send(_bytes)
end

--接收数据
function MSocket:receiveData(event)
	local packet = self.m_mparsePacket
	local readState = self.m_readState
	if 0 == readState then --0是新数据读取
		packet:init(event.data)
	elseif 1 == readState then --1数据会继续往后读
		packet:addData(event.data)
	end
	--处理数据
	readState = g_netMgr:receive(packet)
	if 2 == readState then --2proto解析错误
		self:close() --主动断开连接
	end
	self.m_readState = readState
end

--断开连接
function MSocket:close()
	print("MSocket:close")
	self.m_readState = 0
	self.m_mparsePacket:clear()
	-- self.m_socketTCP:disconnect()
	self.m_socketTCP:close()
end

--socket

--socket断开(可加loading重连动画)
function MSocket:tcpClose()
	print("MSocket:tcpClose")
	--踢到开头界面
	-- g_SMG:toLoginScene("MSocket:tcpClose")
end

function MSocket:tcpClosed()
	print("MSocket:tcpClosed")
end

--socket连接成功调用
function MSocket:tcpConnected()
	print("MSocket:tcpConnected")
	g_msg:post(g_msgcmd.SOCKET_CONNECT_SUCCESS)
end

--socket连接失败调用(重复调用)
function MSocket:tcpConnectedFail()
	print("MSocket:tcpConnectedFail")
	g_msg:post(g_msgcmd.SOCKET_CONNECT_FAIL)
end

--socket是否连接中
function MSocket:isConnected()
	return self.m_socketTCP.isConnected
end

-- 注册消息
function MSocket:reg(_tag, _msgName, _listener)
    g_msg:reg(_tag, _msgName, _listener)
end

-- 移除注册消息
function MSocket:unreg(_tag, _msgName, _listener)
    g_msg:unreg(_tag, _msgName, _listener)
end

-- 派发事件（消息号,数据）接收时可根据msgid区分处理
function MSocket:sendEvent(_msgName, _data)
    print("MSocket:sendEvent ".._msgName.." ")
    g_msg:post(_msgName, _data)
end

return MSocket
