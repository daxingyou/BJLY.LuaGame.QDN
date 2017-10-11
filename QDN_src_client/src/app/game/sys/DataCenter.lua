--
-- 数据中心
--

local DataCenter = class("DataCenter")

function DataCenter:ctor()
	self:initModule()
end

--清除数据
function DataCenter:clear()
    self:initModule()
end

--初始化对象
function DataCenter:initModule()

	self.userSys        = require("app.game.sys.UserSys").new()
	self.roomSys 		= require("app.game.sys.RoomSys").new()
	self.reportSys 		= require("app.game.sys.ReportSys").new()
	self.cardSys 		= require("app.game.sys.CardSys").new()

	print("DataCenter:initModule")
end
return DataCenter
