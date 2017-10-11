--[[
MParsePacket 解包过程 二段式协议 head(消息头) protobuf (消息内容) protobuf()
author: XuJian
date: 2017-6-11
]]
local array = require("framework.cc.utils.ByteArray")

local MParsePacket = class("MParsePacket")

function MParsePacket:ctor()
end

--初始化packet到bytearray
function MParsePacket:init(data)
	self._bf = nil
	self._bf = array.new(array.ENDIAN_BIG)
	if data then
		self._bf:writeBuf(data)
	end
	self._bf:setPos(1)
	-- print("receiveData=="..self._bf:toString(16))
end

--增加数据
function MParsePacket:addData(_data)
	print("MParsePacket:addData")
	if self._bf then
		local pos = self._bf:getPos()
		self._bf:setPos(self._bf:getLen()+1)
		self._bf:writeBuf(_data)
		self._bf:setPos(pos)
	end
end

function MParsePacket:setPos(__pos)
	self._bf:setPos(pos)
	return self._bf
end

--packet到当前消息的总长度
-- function MParsePacket:setMessageLength(length)
-- 	self._len=self._len+length
-- end

--整个packet的长度
function MParsePacket:getPacketSize()
	return self._bf:getLen()
end

--读取到当前packet的位置
function MParsePacket:getPos()
	return self._bf:getPos()
end

--未读数据长度
function MParsePacket:getAvailable()
	return self._bf:getAvailable()
end

--读取两个字节
function MParsePacket:readShort()
	return self._bf:readShort()
end

--读取字节
function MParsePacket:readStringBytes(_len)
	return self._bf:readStringBytes(_len)
	-- return self._bf:readStringBytes(self._len-self._bf:getPos()+1)
end

--后退多少字节
function MParsePacket:backPos(_len)
	self._bf:setPos(self._bf:getPos() - _len)
end

--清空
function MParsePacket:clear()
	self:init(nil)
end

--读取protobuf内容
-- function MParsePacket:readStringBytes()
-- 	print("MParsePacket:readStringBytes", self._len, self._bf:getPos()+1)
-- 	return self._bf:readStringBytes(self._len-self._bf:getPos()+1)
-- end

--读取protobuf内容
-- function MParsePacket:readProtoData()
-- 	local len = self._len-self._bf:getPos()+1
-- 	return self._bf:readBuf(len),len
-- end

-- function MParsePacket:readString()
-- 	return MParsePacket._bf:readString()
-- end

function MParsePacket:readByte()
	return self._bf:readByte()
end
function MParsePacket:readInt()
	return self._bf:readInt()
end

-- function MParsePacket:readFloat()
-- 	return MParsePacket._bf:readFloat()
-- end
return MParsePacket