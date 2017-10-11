--[[
MMsgManager 消息管理器
author: XuJian
date: 2017-6-21
]]

local mcreatePacket = require("app.core.net.MCreatePacket")

local DATA_DEBUG = false --数据调试
local WRITE_TEST = false --是否对网络数据写测试文件
local TEST_PATH = device.writablePath.."nettest.db"

local WAIT_SHOW_TIME = 0.3 --网络等待显示延迟

local MMsgManager = class("MMsgManager")

function MMsgManager:ctor()
    if g_GameConfig.LOCAL_DEBUG then return end
    self.m_socket = require("app.core.net.MSocket").new()
    self.m_retMsgIds = {} --每次返回的消息ID总列（可多个）
    self.m_notWaitList = {} --创建一个不需要等待层的列表

      --反转数字到命令名
    local netcmd = {}
    for k,v in pairs(g_netcmd) do
        netcmd[v] = k
    end
    self.m_netcmd = netcmd
    self.index = 0
end

--连接游戏服务器
function MMsgManager:connectGameServer(_Addr,_Port)
    print("========连接游戏服务器========")
    self.m_socket:connect(g_GameConfig.kServerAddr, g_GameConfig.kServerPort)
end

--发送数据∂
function MMsgManager:send(_msgId, _data, _waitDelay)
    if g_GameConfig.LOCAL_DEBUG then
        return
    end
    --检测网络状态
    local ok = self:checkNetwork()
    if ok then
        self.index = self.index + 1
        local __buf = mcreatePacket:createPacket(_msgId, self:__encodeData(_msgId, _data))
        self.m_socket:sendData(__buf:getPack())
        self:__sendDone(_msgId, _waitDelay) --发送成功
    end
end

--接收数据
function MMsgManager:receive(mparsePacket)

    local x = 1
    local isEnd = false
    local len = 0
    local msgId = 0
    local bufLen = 0
    -- local buf  = ""
    local serverVersion

    local HEAD_0 = ""
    local HEAD_1 = ""
    local HEAD_2 = ""
    local HEAD_3 = ""
    local protoVersion = ""
    local accesskey
   
    while mparsePacket:getAvailable() <= mparsePacket:getPacketSize() do
 
        --第一段数据 解包 
        -- 目前 如果有第二段数据  则处理  --有粘包，需要判断包可读长度
        -- if x == 1 then 
        HEAD_0 = mparsePacket:readByte()
        HEAD_1 = mparsePacket:readByte()
        HEAD_2 = mparsePacket:readByte()
        HEAD_3 = mparsePacket:readByte()
        protoVersion = mparsePacket:readByte()
        local flag = mparsePacket:readByte()
        serverVersion = mparsePacket:readInt()
        local index = mparsePacket:readInt()
        --读取消息长度
        bufLen = mparsePacket:readInt() -4
        ---这个真的是消息号
        msgId = mparsePacket:readInt()
        print("接收成功 msgId =",msgId)
        accesskey = mparsePacket:readStringBytes(32)
        
        --粘包
        if bufLen > mparsePacket:getAvailable() then
            return 1
        end
        local buf,pLen = mparsePacket:readStringBytes(bufLen)

         --效验协议号
        if not self:__validMsgId(msgId) then
            print("无效的msgId", msgId)
        else
             --得到pbc解析为table
            local protobuf = self:__decodeData(msgId, buf, pLen)
            
            if not protobuf then
                print("解析protobuf错误，返回为nil")
                return 2
            end
            --分发事件
            self:__sendReceive(msgId, protobuf)

             --已处理的协议集
             table.insert(self.m_retMsgIds, msgId)
        end

        --本轮处理结束
        if 0 == mparsePacket:getAvailable() then
            isEnd = true
            break
        end
        x = x + 1
    end
    if isEnd then
        self:__receiveDone(self.m_retMsgIds)
        self.m_retMsgIds = {}
    end

    return 0
end

-- 注册消息
function MMsgManager:reg(_tag, _msgId, _listener)
    g_msg:reg(_tag, self:__getNetMsgName(_msgId), _listener)
end

-- 移除注册消息
function MMsgManager:unreg(_tag, _msgId, _listener)
    g_msg:unreg(_tag, self:__getNetMsgName(_msgId), _listener)
end

-- 收到消息派发事件（消息号,数据）接收时可根据msgid区分处理
function MMsgManager:__sendReceive(_msgId, _data)
    local k = self:__getNetMsgName(_msgId)
    g_msg:post(k, _data)
    --移除等待层
    -- g_SMG:removeWaitLayer()
end

--是否连接中
function MMsgManager:isConnected()
    if not self.m_socket then return false end
    return self.m_socket:isConnected()
end

--断开连接
function MMsgManager:close()
    if self:isConnected() then
        self.m_socket:close()
    end
end

--检测网络连接状态
function MMsgManager:checkNetwork()
    local r = false
    for i=1,3 do
        -- print("checkNetwork state", network.getInternetConnectionStatus(), cc.kCCNetworkStatusNotReachable)
        if cc.kCCNetworkStatusNotReachable ~= network.getInternetConnectionStatus() then
            r = true
            break
        end
    end
    if not r then
        -- g_SMG:removeWaitLayer()
        -- --弹出提示
        -- local dialog = require("app.scenes.DialogLayer").new({
        --         title = g_lang:getLocalString("network_error"),
        --         tip = g_lang:getLocalString("network_tip3"),
        --         type = 1,
        --         scale = 1,
        --         action = 1
        --     })
        -- dialog:setListen(function(_event, _data)
        --     if "ON_OK" == _event then
        --         g_SMG:toLoginScene("MMsgManager:checkNetwork")
        --     end
        -- end)
    end
    return r
end

--组包 protobuf
function MMsgManager:__encodeData(_msgId, _data)
    if nil == _data then
        return nil
    end
    local r = g_pbc:encode(_msgId, _data)
    return r
end

--解包 return protobuf table
function MMsgManager:__decodeData(_msgId, _data, _len)
    return g_pbc:decode(_msgId, _data, _len)
end


--组合网络消息
function MMsgManager:__getNetMsgName(_msgId)
    return "NETMSG_"..tostring(_msgId)
end

--发送成功
function MMsgManager:__sendDone(_msgId, _waitDelay)
    --显示等待层
    local waitDelay = _waitDelay or WAIT_SHOW_TIME
    if waitDelay > 0 then
        g_SMG:addWaitLayer(waitDelay)
    else
        --不显示等待层的处理
        local qid = _msgId+1 --请求响应协议都是+1
        local qn = self.m_notWaitList[qid]
        if qn then
            self.m_notWaitList[qid] = qn + 1
        else
            self.m_notWaitList[qid] = 1
        end
    end
end

--一轮接收处理完毕
function MMsgManager:__receiveDone(_msgIds)
    local flg = false
    for i,v in ipairs(_msgIds) do
        local qn = self.m_notWaitList[v]
        if qn then
            qn = qn - 1
            if qn > 0 then
                self.m_notWaitList[v] = qn
            else
                self.m_notWaitList[v] = nil
            end
        else
            flg = true
        end
    end
    --移除等待层
    if flg then
        g_SMG:removeWaitLayer()
    end
end

--效验msgid
function MMsgManager:__validMsgId(_msgId)
    local v = self.m_netcmd[_msgId]
    if v then
        return true
    end
    return false
end

return MMsgManager
