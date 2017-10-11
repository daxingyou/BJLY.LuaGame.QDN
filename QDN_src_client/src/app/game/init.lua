
print("=============initGlobal=============")

require("app.core.ext.initExt")
require("app.common.CommonInit")
--游戏公共库
g_utils = require("app.common.utils.GameUtils")

--c2lua
g_C2LuaSystem = require("app.common.utils.C2LuaSystem")

--用户配置
g_LocalDB = require("app.common.db.LocalDB").new()

--数据中心
g_data = require("app.game.sys.DataCenter").new()

--消息号
g_msgcmd = require("app.game.msg.msgcmd")
--消息中心
g_msg = require("app.core.msg.MsgCenter").new()

--http
g_http = require("app.core.net.TPHttp")

print("=============MyApp:initNetwork=============")
--网络消息
g_netcmd = require("app.game.net.netcmd")
--网络消息管理器
g_netMgr = require("app.core.net.MMsgManager").new()
--网络中心
g_net = require("app.game.net.netCenter").new()
--pbc管理
g_pbc = require("app.core.pbc.pbc").new()

--场景管理
g_SMG = require("app.core.manager.SceneManager").new()

--牌管理
CardDefine      = require("app.common.component.CardDefine")
TileDefine      = require("app.common.component.TileDefine")

OperateType     = require("app.game.define.OperateType")
RoomDefine      = require("app.game.define.RoomDefine")
g_audioConfig   = require("app.game.config.audio_config")

--声音管理
g_audio = require("app.core.manager.audio_manager")

--http request tag
g_httpTag = require("app.game.msg.httpTag")
g_LobbyCtl = require("app.game.controller.LobbyCtl").new()
g_ClubCtl = require("app.game.controller.ClubCtl").new()
g_enumKey = require("app.game.sys.EnumKey")
g_ToLua = require("app.common.sdk.ToLua")

--j2lua
g_J2LuaSystem = require("app.common.utils.J2LuaSystem")

g_UILayer = require("app.game.ui.UIInit")
g_gcloudvoice = require("app.game.sdk.MissionGvoice").new()

g_thunder = require("app.core.loading.Thunder").new()

g_WeiXin = require("app.common.sdk.MissionWeiXin")
