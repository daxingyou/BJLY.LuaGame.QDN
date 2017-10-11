local MissionGvoice = class("MissionGvoice")
local Scheduler = require("framework.scheduler")
function MissionGvoice:ctor()		
	    self.Gvoice = my.GcloudVoiceInstance:getinstance()
      self.scheduler_tick = nil
end
function MissionGvoice:initGvoice()
	     self.Gvoice:setAppinfo("1977074008","132d276c6c21dc8cf64b2e2317aed287",g_data.userSys.openid)
       self.Gvoice:initEngine()
       self.Gvoice:setGvoiceModel(0)
       if self.scheduler_tick then
          Scheduler.unscheduleGlobal(self.scheduler_tick)
          self.scheduler_tick = nil
       end
       self.scheduler_tick = Scheduler.scheduleGlobal( function() self:tick(0.25) end, 0.25)
end
function MissionGvoice:openspeaker()
	self.Gvoice:opemspeaker()
end
function MissionGvoice:closespeaker()
  self.Gvoice:closespeaker()
end
function MissionGvoice:jointeamroom(roomid)
	self.Gvoice:jointeamroom(roomid)
end
function MissionGvoice:quickteamroom(roomid)
    self.Gvoice:quickteamroom(roomid)
end
function MissionGvoice:openmic()
	self.Gvoice:openmic()
end
function MissionGvoice:closemic()
	self.Gvoice:closemic()
end
function MissionGvoice:tick( ft )
    local Gvoice_ = my.GcloudVoiceInstance:getinstance()
    Gvoice_:pollEngine()
end

return MissionGvoice
