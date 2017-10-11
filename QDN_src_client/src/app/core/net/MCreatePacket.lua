--[[
MCreatePacket 解包过程 二段式协议 head(消息头) protobuf (消息内容) 
author: XuJian
date: 2017-6-21
]]
local array=require("framework.cc.utils.ByteArray")

local MCreatePacket=class("MCreatePacket")

--初始化byteArray
function MCreatePacket:initStream()
	self._bf=nil
	self._bf=array.new(array.ENDIAN_BIG)

	local bf
	-- MarqueeData.annoucementTab[#MarqueeData.annoucementTab+1] = {}
end

function MCreatePacket:writeShort(value)
	if  value==nil then return end
	self._bf:writeShort(value)
end

--把protobuf(消息体)写进byteArray
function MCreatePacket:writeStringBytes(value)
	if  value==nil then return end
	self._bf:writeStringBytes(value)
end
--组包,返回byteArray
function MCreatePacket:closeStream()
	local __buf=array.new(array.ENDIAN_BIG)
	local __bodyLen=self._bf:getLen()

	-- local _head = array.new(array.ENDIAN_BIG)
	-- _head::writeShort(54)

	__buf:writeShort(__bodyLen+54)--先把长度写进byteArray
	-- __buf:writeBytes(_head)
	__buf:writeBytes(self._bf)----把(msgId,protobuf)写进byteArray
	return __buf
end

--封装包头
function MCreatePacket:crthead(__msgid,value)
	local __buf = array.new(array.ENDIAN_BIG)

	local len = string.len(value)
	__buf:writeByte(78) --HEAD_0  --- TODO
	__buf:writeByte(37) --HEAD_1  --- TODO
	__buf:writeByte(38) --HEAD_2  --- TODO
	__buf:writeByte(48) --HEAD_3  --- TODO
	__buf:writeByte(10) --ProtoVersion  --- TODO
	__buf:writeByte(0)  --flag  --- TODO
	__buf:writeInt(0)  --ServerVersion  --- TODO
	__buf:writeInt(g_netMgr.index)  --index  --- TODO
	__buf:writeInt(len+4) --len --- 此为protobuf的长度
	__buf:writeInt(__msgid)  --opcode --- 消息号
	__buf:writeStringBytes(g_data.userSys.accessKey) --accessID
	
	--与服务器 对应 保证54字节长度
	local bufSize = 54
	local __x = bufSize - __buf:getLen()
	for i=1,__x do
		-- create a metadata description: data index(8~4bit 0~248(0xF8,b11111000)) + data type(3~1bit 0~7(b00000111))
		__buf:writeByte(0)
		-- __buf:writeByte( bit.bor(bit.lshift(i-1, 3), _DATA_TYPE[__fmt:sub(i,i)]) )
	end
	return __buf
end

--封装包体
function MCreatePacket:crtbody(value)
	local __buf = array.new(array.ENDIAN_BIG)
	__buf:writeStringBytes(value)
	return __buf
end

--封包
function MCreatePacket:createPacket(__msgid, value)
	local __buf = array.new(array.ENDIAN_BIG)
	local __head = self:crthead(__msgid,value)
	local __body = self:crtbody(value)
	__buf:writeBytes(__head)
	__buf:writeBytes(__body)
	return __buf
end

return MCreatePacket