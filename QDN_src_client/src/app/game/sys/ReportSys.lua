--
-- 结算系统 管理结算数据
--

local ReportSys = class("ReportSys")

function ReportSys:ctor()
	self.m_finalReport = {}
	self.isPopfinalReport = false
end

-- "result_list" = {
--      1 = {
--          "total_fen" = 0
--          "uid"       = 100133
--      }
--      2 = {
--          "total_fen" = 0
		-- score_round             = 2
--          "uid"       = 100153
--      }
--  }
--总结算
function ReportSys:updataFinalReport(_value)
	printTable("_value",_value)
	self.m_finalReport = {}
	for k,v in pairs(_value) do
		self.m_finalReport[k] = v
	end
	if self.isPopfinalReport then
		g_msg:post(g_msgcmd.DB_FinalReport)
	end
end


-- "details" = {
--          "result_list" = {
--              1 = {
--                  "uid" = 100133
--              }
--              2 = {
--                  "uid" = 100153
--              }
--          }
--      }
--      "errorcode"       = 0
--      "fanpaiji_cardid" = 0
--      "is_huangzhuang"  = 1
--      "result_list" = {
--          1 = {
--              "hand_cards" = {
--                  1  = 1
--              }
--				"hu_cardid"     = 22
--				"hupai_fangshi" = 1 - - 1自摸 2点炮 3放热跑 4杠上花 5抢杠胡（有杠上花就没有自摸）
--              "hupai_type"  = 0
--              "ji_num"      = 2
--              "total_gold"  = 1012
--              "uid"         = 100133
--              "win_fan_cnt" = 0
--          }
function ReportSys:updataRoundReport(_value)
	printTable("_value-------",_value)
	self.m_roundReport = {}
	for k,v in pairs(_value) do
		self.m_roundReport[k] = v
	end
	self.isPopfinalReport = false
end

--根据用户UID获取结算手牌
function ReportSys:getRoundReportByUID(_uid)
	local  result = self.m_roundReport.result_list
	for k,v in pairs(result) do
		if v.uid == _uid then
			return  v 
		end
	end 
	return {}
end

function ReportSys:getRoundReport( ... )
	return self.m_roundReport
end
function ReportSys:getFinalReport()
	return self.m_finalReport
end
function ReportSys:getFinalReportByUid(_uid)
	for k,v in pairs(self.m_finalReport) do
		if v.uid == _uid then
			return v 
		end
	end
	return {}
end


return ReportSys
