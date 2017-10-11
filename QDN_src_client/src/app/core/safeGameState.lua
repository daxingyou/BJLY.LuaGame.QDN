--本地存储的加密文件
local safeGameState = class( "safeGameState" )

safeGameState.ERROR_INVALID_FILE_CONTENTS = -1
safeGameState.ERROR_HASH_MISS_MATCH       = -2
safeGameState.ERROR_STATE_FILE_NOT_FOUND  = -3

local crypto = require(cc.PACKAGE_NAME .. ".crypto")
local json   = require(cc.PACKAGE_NAME .. ".json")

function safeGameState:init(eventListener_, stateFilename_, secretKey_)
    if type(eventListener_) ~= "function" then
        echoError("safeGameState:init() - invalid self.eventListener")
        return false
    end

    self.eventListener = eventListener_

    if type(stateFilename_) == "string" then
        self.stateFilename = stateFilename_
    end

    if type(secretKey_) == "string" then
        self.secretKey = secretKey_
    end

    self.eventListener({
        name     = "init",
        filename = self:getsafeGameStatePath(),
        encode   = type(self.secretKey) == "string"
    })

    return true
end

function safeGameState:load(_strData)

    local function isEncodedContents_(contents)
        return string.sub(contents, 1, string.len(self.encodeSign)) == self.encodeSign
    end

    local function decode_(fileContents)
        local contents = string.sub(fileContents, string.len(self.encodeSign) + 1)
        local j = json.decode(contents)

        if type(j) ~= "table" then
            echoError("safeGameState:decode_() - invalid contents")
            return {errorCode = safeGameState.ERROR_INVALID_FILE_CONTENTS}
        end

        local hash,s = j.h, j.s
        local testHash = crypto.md5(s..self.secretKey)

        if testHash ~= hash then
            echoError("safeGameState:decode_() - hash miss match")
            return {errorCode = safeGameState.ERROR_HASH_MISS_MATCH}
        end

        local values = json.decode(s)

        if type(values) ~= "table" then
            echoError("safeGameState:decode_() - invalid state data")
            return {errorCode = safeGameState.ERROR_INVALID_FILE_CONTENTS}
        end

        return {values = values}
    end

    local contents = nil
    if _strData == nil then

        local filename = self:getsafeGameStatePath()

        if not io.exists(filename) then
            printf("safeGameState:load() - file \"%s\" not found", filename)
            return self.eventListener({name = "load", errorCode = safeGameState.ERROR_STATE_FILE_NOT_FOUND})
        end

        contents = io.readfile(filename)
        printf("safeGameState:load() - get values from \"%s\"", filename)
    else
        printf("safeGameState:load() with function!!!")
        contents = _strData
    end

	--解密
    local len=0
    contents=crypto.decodeBase64(contents,string.len(contents),len)

    local values
    local encode = false

    if self.secretKey and isEncodedContents_(contents) then
        local d = decode_(contents)
        if d.errorCode then
            return self.eventListener({name = "load", errorCode = d.errorCode})
        end

        values = d.values
        encode = true
    else
        values = json.decode(contents)
        if type(values) ~= "table" then
            echoError("safeGameState:load() - invalid data")
            return self.eventListener({name = "load", errorCode = safeGameState.ERROR_INVALID_FILE_CONTENTS})
        end
    end

    return self.eventListener({
        name   = "load",
        values = values,
        encode = encode,
        time   = os.time()
    })
end

  
--返回保存是否成功结果及保存存档字符串
function safeGameState:save(newValues)

    local function encode_(values)
        -- printTable("sssssss1", values)
        local s = json.encode(values)
        -- printTable("sssssss2", s)
        -- print(s)
        local hash = crypto.md5(s..self.secretKey)

        local contents = json.encode({h = hash, s = s})

        return crypto.encodeBase64(self.encodeSign..contents,string.len(self.encodeSign..contents)) --数据加密
    end


    local values = self.eventListener({
        name   = "save",
        values = newValues,
        encode = type(self.secretKey) == "string"
    })
    if type(values) ~= "table" then
        echoError("safeGameState:save() - listener return invalid data")
        return false
    end

    local filename = self:getsafeGameStatePath()
    local ret = false
    local saveStr = ""
    if self.secretKey then
        saveStr = encode_(values)
        ret = io.writefile(filename, saveStr)
    else
        saveStr = json.encode(values)
        if type(s) == "string" then
            ret = io.writefile(filename, saveStr)
        end
    end

    printf("safeGameState:save() - update file \"%s\"", filename)
    return ret,saveStr
end

function safeGameState:getsafeGameStatePath()
    return string.gsub(device.writablePath, "[\\\\/]+$", "") .. "/" .. self.stateFilename
end

function safeGameState:ctor()
    self.encodeSign    = "=QP="
    self.stateFilename = "state.txt"
    self.eventListener = nil
    self.secretKey     = nil
end

return safeGameState
