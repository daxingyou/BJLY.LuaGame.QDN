local function hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
    return s
end

local function readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

local function checkDirOK( path )
    require "lfs"
    local oldpath = lfs.currentdir()
    CCLuaLog("old path------> "..oldpath)

     if lfs.chdir(path) then
        lfs.chdir(oldpath)
        CCLuaLog("path check OK------> "..path)
        return true
     end

     if lfs.mkdir(path) then
        CCLuaLog("path create OK------> "..path)
        return true
     end
end

local function checkCacheDirOK( root_dir, path )
    path = string.gsub(string.trim(path), "\\", "/")
    local info = io.pathinfo(path)
    local dirs = string.split(info.dirname, "/")
    local sdir = root_dir
    if not checkDirOK(sdir) then return false end
    for i = 1, #dirs do
        if string.sub(sdir, -1, -2) ~= "/" then sdir = sdir .. "/" end
        sdir = sdir .. dirs[i]
        if not checkDirOK(sdir) then
            return false
        end
    end
    return true
end

require "lfs"

function findindir (path, wefind, r_table, intofolder)
    if not io.exists(path) then
        return
    end
    for file in lfs.dir(path) do
        --print("======aaaa",path,file)
        if file ~= "." and file ~= ".." and file ~= ".DS_Store" and file ~= ".svn" then
            local f = path..'/'..file
            local attr = lfs.attributes (f)
            --assert (type(attr) == "table")
            if attr.mode == "directory" and intofolder then
                findindir (f, wefind, r_table, intofolder)
            else
                if string.find(f, wefind) ~= nil then
                    --print("/t "..f)
                    table.insert(r_table, f)
                end
            end
        end
    end
end

local function checkDirOK( path )
    require "lfs"
    local oldpath = lfs.currentdir()
    if lfs.chdir( path ) then
        lfs.chdir( oldpath )
        return true
    end

    if lfs.mkdir( path ) then
        ---print("创建文件夹成功~")
        return true
    end
end

MakeFileList = {}

--脚本目录
local scriptDir = proj_dir .. "scripts" --export_dir .. "scripts"
--资源目录
local resDir = proj_dir .. "res"--export_dir .. "res"
--输出目录
--local outputDir = "ver" .. ver .. "_" .. os.date("%Y%m%d%H%M%S") .. "/"

function MakeFileList:run()
    if not checkDirOK( proj_publish ) then 
        print( "MakeFileList:run() return false " .. proj_publish )
        return false 
    end

    if not checkDirOK( proj_publish .. ver ) then 
        print( "MakeFileList:run() return false " .. proj_publish .. ver )
        return false 
    end

    -- 检查是否需要导出差异文件
    if 0 < string.len(branch_dir) then
        print("------- 导出差异文件 ----------",os.clock())
        -- 重置目录
        scriptDir = export_diff .. "src"
        resDir    = export_diff .. "res"
        
        self:mkdiff()        

        proj_dir  = export_diff
    end

    print("======= 过程时间较长，请耐心等候进度完成的提示 ===========",export_dir,scriptDir,resDir)
    
    print("------- 统计文件 ----------",os.clock())
    local input_scripts_table = {}
    local input_res_table = {}
    -- 把路径..文件名,啥的读到input_table表中
    findindir(scriptDir, ".", input_scripts_table, true)
    findindir(resDir, ".", input_res_table, true)

    --压缩json
    --composeJson(input_scripts_table)
    --composeJson(input_res_table)

    --dump( input_scripts_table )
    --dump( input_res_table )

    print("------- 生成文件Md5码 ----------",os.clock())
    --所有文件列表
    local allFiles = {}
    local pthlen = string.len(proj_dir)+1
    --print( "=========pthlen", pthlen )
    for i, v in ipairs(input_scripts_table) do -- 遍历所有的文件
        local data = readFile(v) -- 读取这个文件的内容
        local ms = crypto.md5(hex(data or "")) or "" --        
        local nfn = string.trim(string.sub(v, pthlen)) -- 去掉绝对路径
        nfn = string.gsub(nfn, "\\", "/")
        table.insert(allFiles, {name=nfn, code = ms, len=string.len(data)})
        --print("文件名字==",nfn,"md5code==",ms,"大小",string.len(data))
    end
    local pthlen = string.len(proj_dir)+1
    --print( "=========pthlen", pthlen )
    for i, v in ipairs(input_res_table) do -- 遍历所有的文件
        local data = readFile(v) -- 读取这个文件的内容
        local ms = crypto.md5(hex(data or "")) or "" --        
        local nfn = string.trim(string.sub(v, pthlen)) -- 去掉绝对路径
        nfn = string.gsub(nfn, "\\", "/")
        table.insert(allFiles, {name=nfn, code = ms, len=string.len(data)})
        
        --print("文件名字==",nfn,"md5code==",ms,"大小",string.len(data))
    end
    
    -----------------------------------------------------------------------------------
    --导出所有源文件列表
    --dump( allFiles )
    output( allFiles, "update.manifest" ) -- 保存文件到update.manifest.src中

    print("------- 编译脚本文件 ----------",os.clock())
    compileFile()


    print("======= 全部工作完成，您可以关闭程序了 ===========",os.clock())
end

function copyFiles()
    --xcopy e:\*.* d: /s /h /d /y
    local cmd = "xcopy " .. scriptDir .. "/*.* " .. export_dir .. " /s /e"
    os.execute(cmd)
    cmd = "xcopy " .. resDir .. " " .. export_dir .. " /s /h /d /y"
    os.execute(cmd)
end

function composeJson(files)
    for i = 1, #files do
        if string.sub(files[i], -5, -1) == ".json" then
            local content = readFile(files[i])
            if content then
                local str = json.encode(json.decode(content))
                io.writefile(files[i], str)
            end
        end
    end
    print("compile json completed!")
end

function output(allFiles, filename)
    --local manifest = {}
    --manifest.ver = ver
    --manifest.filelist = allFiles
    --版本号
    local manifest = "version:" .. ver .. "\n"
    manifest = manifest .. "version_name:" .. ver_name .. "\n"
    --cdn_url
    manifest = manifest .. "cdn_url:" .. cdn_url .. "\n"
    manifest = manifest .. "local m={"
    --文件列表

    for i = 1, #allFiles do
        manifest = manifest .. "\n\t{name=\"" .. allFiles[i].name .. "\"}"
        if i < #allFiles then
            manifest = manifest .. ","
        end
    end

    manifest = manifest .. "\n}"
    manifest = manifest .. "\nreturn m"
    --print("=====================保存数据", export_dir .. filename, manifest )
    local xx = io.writefile( export_dir .. filename, manifest )
    --print( "==========保存数据结果", xx )
end

function campare(old_file, allFiles)
    local files = {}
    local oldFiles = dofile(old_file).stage
    for i = 1, #allFiles do
        if not campareFile(oldFiles, allFiles[i]) then
            table.insert(files, allFiles[i])
        end
    end
    dump(files, "files------------>")
    for i = 1, #files do
        copyFile(files[i])
    end
    return files
end

function campareFile(stage, file)
    local b = false;
    for i = 1, #stage do
        if stage[i].name == file.name then
            if stage[i].code == file.code then
                b = true
            end
            break
        end
    end
    return b
end

function copyFile(file)
    local filename = file.name
    local f = io.open(proj_dir .. filename, "rb") 
    local content = f:read "*a"
    f:close()
    checkCacheDirOK(export_dir, filename)
    f = io.open(export_dir .. filename, "wb")
    f:write(content) 
    f:close()
end

function compileFile()
    --重命名源文件
    local cmd = luajit_compile .. " -m files"
    cmd = cmd .. " -i " .. "/Users/WorkSpace/laiya_tianzhu_src_client/export_diff/src"
    cmd = cmd .. " -o " .. codeexport_dir
    cmd = cmd .. " -e " .. "xxtea_chunk"
    cmd = cmd .. " -ek " .. ek_key
    cmd = cmd .. " -es " .. ek_es
    
    dump(cmd,"cmd=")
    os.execute( cmd )
end

function getFilesCode(files)
    for i = 1, #files do
        local data = readFile( export_dir .. files[i].name )
        local ms = crypto.md5(hex(data or "")) or ""
        files[i].code = ms
    end
    return files
end

local lfs = require "lfs"

function MakeFileList:mycopyfile(source,destination_dir,destination_file)
    print(source)
    print(destination_dir)
    print(destination_file)
    local f = io.open(source, "rb") 
    local content = f:read "*a"
    f:close()
    checkCacheDirOK(destination_dir, destination_file)
    f = io.open(destination_dir .. destination_file, "wb")
    f:write(content) 
    f:close()
end

-- 生成差异化文件
function MakeFileList:mkdiff()
    local dir1ScriptMD5 = {}
    local dir2ScriptMD5 = {}
    local dir1ResMD5 = {}
    local dir2ResMD5 = {}   

    self:getFileMD5(proj_dir .. "src/", proj_dir .. "src/", dir1ScriptMD5)
    self:getFileMD5(branch_dir .. "src/", branch_dir .. "src/", dir2ScriptMD5)

    local diffList = self:getDiffListByMD5(dir1ScriptMD5, dir2ScriptMD5)

    self:getFileMD5(proj_dir .. "res/", proj_dir .. "res/", dir1ResMD5)
    self:getFileMD5(branch_dir .. "res/", branch_dir .. "res/", dir2ResMD5)

    if io.exists(export_diff) then
        io.rmdir(export_diff)
    end
    io.mkdir(export_diff)
    -- 生成脚本
    for k, v in pairs(diffList) do

        self:mycopyfile(proj_dir .. "src" .. k, export_diff .. "src", k)            
    end
    -- 生成资源
    diffList = self:getDiffListByMD5(dir1ResMD5, dir2ResMD5)
    for k, v in pairs(diffList) do
        self:mycopyfile(proj_dir .. "res" .. k, export_diff .. "res", k)     
    end    
end    

function MakeFileList:getFileMD5(rootPath, path, files)
    for file in lfs.dir(path) do
         if file ~= "." and file ~= ".." and file ~= ".DS_Store" and file ~= ".svn" then
            local fullPath = path .. file 
            local attr = lfs.attributes(fullPath)
            if attr.mode == "directory" then
                self:getFileMD5(rootPath, fullPath .. "/", files)
            else
                local _, endPos = string.find(fullPath, rootPath, 1, true)
                local childPath = string.sub(fullPath, endPos)
                local data = readFile(fullPath)
                local key = tostring(childPath)
                files[key] = crypto.md5(hex(data or ""))
            end
        end
    end
end

-- trunk 主版本
-- branch 分支版本
function MakeFileList:getDiffListByMD5(trunk, branch)
    local diffList = {}
    for k, v in pairs(trunk) do
       if not branch[k] then 
        -- 没找到
            diffList[k] = v
       elseif branch[k] ~= v then
        -- 找到了 MD5不相等
            diffList[k] = v
       end
    end
    return diffList
end



return MakeFileList