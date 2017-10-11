--
-- 房间信息系统，用户进入房间后，各玩家信息的管理,本地用户的数据也在房间中进行广播，比如金典版本中的total win数据。
--
--

local CardSys = class("CardSys")

function CardSys:ctor()
	self:initData()
end

function CardSys:initData()
	self.index = 10101
end

function CardSys:getIndex()
	self.index = self.index  +1
	return self.index
end

return CardSys
