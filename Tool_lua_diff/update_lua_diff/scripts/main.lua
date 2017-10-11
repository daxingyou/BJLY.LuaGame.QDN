
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

require("framework.init")

root_dir = "/Users/WorkSpace/laiya_tianzhu_src_client/tools/quick/"

-- 分支目录 通过分支比较产生差异化
branch_dir = "/Users/WorkSpace/MasterSelf/laiya_tianzhu_src_client/"

proj_dir = "/Users/WorkSpace/laiya_tianzhu_src_client/"

project_name = "laiya_tianzhu_src_client"
--发布版本号(发布的文件会在主目录+版本号的目录下)
ver = "1"
--显示在界面上的版本号
ver_name_base = "1.1"
ver_name = ""

cdn_url = "http://d.laiyagame.com/jinping/res/"

--luajit编译脚本
luajit_compile = root_dir .. "bin/compile_scripts"

if device.platform == "windows" then
	luajit_compile = luajit_compile .. ".bat"
end

if device.platform == "mac" then
	luajit_compile = luajit_compile .. ".sh"
end

--项目所在目录
-- proj_dir=""

--项目发布总目录
proj_publish = ""

-- 版本差异目录
export_diff   = ""

--发布文件目录
export_dir = ""

-- 编译后的代码存放路径
codeexport_dir = ""


-- ek_key = "r98fj&3urn42^#s"
ek_key = "L@Y#G^^"

ek_es  = "LAIYAGAME"

function genEnv(verCode,projectName)
	project_name = projectName
	--发布版本号(发布的文件会在主目录+版本号的目录下)
	ver = verCode
	--显示在界面上的版本号
	ver_name = ver_name_base .. "." .. ver
	--项目所在目录
	-- proj_dir = root_dir .. "projects/" .. project_name .. "/"
	--项目发布总目录
	proj_publish = proj_dir .. "export_vn/"
	-- 版本差异目录
	export_diff   = proj_dir .. "export_diff/"
	--发布文件目录
	export_dir = proj_publish ..  ver .. "/"
	-- 编译后的代码存放路径
	codeexport_dir = export_dir .. "src"
end

require("app.MyApp").new():run()
