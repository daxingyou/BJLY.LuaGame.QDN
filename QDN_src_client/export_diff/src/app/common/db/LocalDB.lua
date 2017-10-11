--[[
  LocalDB.lua
  存储本地数据 
  数据编码格式:
  local data = { a=1,b=2,c=3}
  local secretKey = "123"
  1.先将data转换成json串s, 然后s 和 secretKey 连接成字符串 c
  2.再将c计算md5得到值hash
  3.再次以格式 { h = hash, s = s } 编码json 形成 contents
  4.将contents进行base64加密
]]
local LocalDB = class( "LocalDB" )

local safeGameState = require("app.core.safeGameState").new()

--数据文件秘钥(不变化)
local DATA_SER_KEY = "8c58b2972e48adfef2a6523c13a736a1"

--构造函数
function LocalDB:ctor()
    self:init()

    local function gameStateCallFunc(parameters)
      return parameters
    end

    safeGameState:init( gameStateCallFunc, "LocalDB", DATA_SER_KEY )

    local path = safeGameState:getsafeGameStatePath()
    if not cc.FileUtils:getInstance():isFileExist( path ) then
       print("[[ 创建LocalDB ]]")
       safeGameState:save( self.db )
    end

    --加载
    self:load()
end

--初始化config表
function LocalDB:init()
     -- all lower key string---都是小写
     self.db = {
        clientversion   = "1.1.6", -- 客户端版本号
        accesstoken     = "",--微信token
        openid          = "",--openid
        bgmstate        = 1, --背景音乐是否打开
        bgvalume        = 100, --背景音乐大小
        soundstate      = 1, --音效是否打开
        soundvalume     = 100, --音效大小
        activityimglist = {},--活动图片列表
        language_type   = "normal",
        tablestyle      = 1, --麻将牌样式
        tablestylebg    = 1, --桌布样式
    ------------以下是记录房间创建信息----------
     ismengangmulti2_jp = 1, --锦屏闷杠X2
     numofplayer_jp     = 4 ,--玩家人数
     isliangfang_jp     = 0 ,--不两房
     roundnum_jp        = 4 ,--4局
     
     numofplayer_lp     = 4, --玩家人数
     isliangfang_lp     = 0, --不两房
     roundnum_lp        = 4, --4局
     isdingmai_lp       = 0 ,--不定买
     numofdingmai_lp    = 1 ,--默认定1分
     isdeathlight_lp    = 0 ,--默认不见光死

     ismengangmulti2_tz = 1 ,--天柱闷杠X2
     numofplayer_tz     = 4 ,--玩家人数
     isliangfang_tz     = 0 ,--不两房
     roundnum_tz        = 4 ,--4局  
     tableregion        = 2 ,--默认是锦屏的房间
     supplementprice_tz = 1 ,
     rules     = {}
    }
end

--数据存储
function LocalDB:save(_key , _value)

    if not _key or not _value then
        assert( nil, "LocalDB save key or value is nil! ")
        return
    end

    local key = string.lower( _key )
    self.db[ key ] = _value

    print( "LocalDB save:",_key,_value )
    safeGameState:save( self.db )
end

--数据读取
function LocalDB:read(_key)
    if not _key then
        assert( nil, "LocalDB read key is nil!" )
        return
    end
    local key = string.lower( _key )

    return  self.db[ key ]
end

--数据加载
function LocalDB:load()
    self:init()
    local data = safeGameState:load().values.values
    for k,v in pairs(self.db) do
        if data[k] then
           self.db[k] = data[k]
        end
    end
    safeGameState:save( self.db )
end

return LocalDB
