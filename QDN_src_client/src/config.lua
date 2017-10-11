
--分支测试---

-- 0 正式版本 1测试版本（只弹错误提示） 2开发版本（所有错误信息)
DEBUG = 0

-- display FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- design resolution
CONFIG_SCREEN_WIDTH  = 640
CONFIG_SCREEN_HEIGHT = 960

--[[ 非debug模式下,重写print,不输出任何信息 ]]
if 0 == DEBUG then
    function print(...)
    end
end


-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"
-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
