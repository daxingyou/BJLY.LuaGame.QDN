
-- 操作代码
local RoomDefine = {}

--房间状态
RoomDefine.Status = {
    Wait        = 0, --等待 未开局
    Doing       = 1, --进行中
    End         = 2, --结束
    RoundReport = 3, --一局计算
    FinalReport = 4, ---总结算
}

--房间玩牌状态
RoomDefine.UI_State = {
    NULL          = -1,
    Wait          = 0,
    Doing         = 1, --牌局中
    RoundReport   = 3,
    FinalReport   = 4,
    Video         = 8, --录像
    -- Doing       = 1, --进行中
    -- End         = 2, --结束
    -- RoundReport = 3, --一局计算
    -- FinalReport = 4, ---总结算
}


RoomDefine.Rule = {
    room_4   = 1, --4人房--
    room_3D  = 2, --三丁房
    room_2D  = 3, --2丁房
    room_3D2 = 4,--三丁2房
    room_2D2 = 5, --2丁2房
}

RoomDefine.RuleText = { 
    [RoomDefine.Rule.room_4]   = "四人房", 
    [RoomDefine.Rule.room_3D]  = "三丁拐",
    [RoomDefine.Rule.room_2D]  = "二丁拐",
    [RoomDefine.Rule.room_3D2] = "三丁两房",
    [RoomDefine.Rule.room_2D2] = "二丁两房",
}

RoomDefine.room_text = { 
    [RoomDefine.Rule.room_4]   = "room_text_4.png", 
    [RoomDefine.Rule.room_3D]  = "room_text_3D.png",
    [RoomDefine.Rule.room_2D]  = "room_text_2D.png",
    [RoomDefine.Rule.room_3D2] = "room_text_3D2.png",
    [RoomDefine.Rule.room_2D2] = "room_text_2D2.png",
}
RoomDefine.region = { 
    jinping  = "text_jinping.png", 
    liping   = "text_liping.png",
    tianzhu  = "text_tianzhu.png",
}

RoomDefine.Direction = { 
    [RoomDefine.Rule.room_4]   = "directionTo4", 
    [RoomDefine.Rule.room_3D]  = "directionTo3",
    [RoomDefine.Rule.room_2D]  = "directionTo2",
    [RoomDefine.Rule.room_3D2] = "directionTo3",
    [RoomDefine.Rule.room_2D2] = "directionTo2",
}

RoomDefine.PlayOutCard = { 
    [RoomDefine.Rule.room_4]   = "node_outcard_4", 
    [RoomDefine.Rule.room_3D]  = "node_outcard_3",
    [RoomDefine.Rule.room_2D]  = "node_outcard_2",
    [RoomDefine.Rule.room_3D2] = "node_outcard_3",
    [RoomDefine.Rule.room_2D2] = "node_outcard_2",
}

--暂时这样  待优化
RoomDefine.Ji_node = { 
    [RoomDefine.Rule.room_4]   = "node_ji_4", 
    [RoomDefine.Rule.room_3D]  = "node_ji_3",
    [RoomDefine.Rule.room_2D]  = "node_ji_2",
    [RoomDefine.Rule.room_3D2] = "node_ji_3",
    [RoomDefine.Rule.room_2D2] = "node_ji_2",
}

--暂时这样  待优化
RoomDefine.HeadPosition = { 
    [CardDefine.direction.bottom]   = {80,273}, 
    [CardDefine.direction.top]      = {1000,644},
    [CardDefine.direction.left]     = {85,442},
    [CardDefine.direction.right]    = {1192,440},
}

return RoomDefine