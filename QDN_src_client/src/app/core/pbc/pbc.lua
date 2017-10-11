--
-- Author: XuJian
-- Date: 2015-02-15 14:37:16
--
local protobuf = require("app.core.pbc.protobuf")
local getProto = require("app.game.net.getProto")

-- 类名空间
local PB_NAMESPACE = "pb."
--- 需要注册的pb
local pbfiles = getProto.pbfiles
-- msgId转typename
local typenames = getProto.typenames
local pbc = class("pbc")

function pbc:ctor()
	self:regPB()
end

--注册pb文件
local function pbc_regfile(_fp)
	print("pbc_regfile", _fp)
	local buf = cc.FileUtils:getInstance():getStringFromFile(_fp)
	protobuf.register(buf)
end

--循环解析pbc
local function pbc_decode(_out)
	-- printTable("pbc_decode", _out, 10)
	local out = _out
	local function _(_out)
		local out = _out
		if not out then print("data error!") return end
		for k,v in pairs(out) do
			-- print("out", k, v)
			if type(v) == "table" then
				if type(v[1]) == "string" and string.find(v[1], "pb.") == 1 then
					-- print(v[1],v[2])
					if v[2] then
						out[k] = protobuf.decode(v[1], v[2])
						_(out[k])
					end
				else
					_(v)
				end
			end
		end
	end
	return _(out)
end

--注册游戏pb文件
function pbc:regPB()
	print("-----注册pb文件开始-----")
	for i,v in ipairs(pbfiles) do
		print(i,v)
		pbc_regfile(v)
	end
	print("-----注册pb文件完成-----")
end

--解码数据
function pbc:decode(_msgId, _data, _len)
	-- 获取pb类型名
    local typename = typenames[_msgId][2]
    if not typename then
    	print("ERROR 获取不到对应的pbc类")
    	return nil
    end

    --解析数据
    local out,err = protobuf.decode(PB_NAMESPACE..typename, _data, _len)
	if "table" == type(out) then
		setmetatable(out, nil)
    	pbc_decode(out)
		return out
	else
		print("pbc:decode error:", err)
	end
	return nil
end

--编码数据
function pbc:encode(_msgId, _data)
	-- 获取pb类型名
    local typename = typenames[_msgId][1]
    if not typename then
    	print("ERROR 获取不到对应的pbc类")
    	return nil
    end
    --组包数据
    local out = protobuf.encode(PB_NAMESPACE..typename, _data)
    return out
end

return pbc
