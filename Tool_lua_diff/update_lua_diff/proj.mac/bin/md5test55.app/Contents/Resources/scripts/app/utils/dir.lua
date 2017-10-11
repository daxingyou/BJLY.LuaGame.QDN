

function io.copyFile(src, des, filepath)    
    -- print("io.copyFile", src, des, des .. filepath)

    io.checkdir(des, filepath)
    
    local srcFile = io.open(src, "r")

    local desFile = io.open(des .. filepath, "w")
    for line in srcFile:lines() do
        desFile:write(line .. "\n")
    end
    srcFile:close()
    desFile:close()
end 

function io.mkdir(path)
    require "lfs"

    local oldpath = lfs.currentdir()

    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        return true
    end

    if lfs.mkdir(path) then
        return true
    end
end


function io.checkdir(path, name)
    local dirList = string.split(name, '/')
    local dirListLen = #dirList - 1
    local destPath = path
    for i = 1, dirListLen do
        destPath = destPath .. dirList[i] ..'/'
        if not io.exists(destPath) then
            io.mkdir(destPath)
        end
    end
end


function io.rmdir(path)
    -- print("----------------io.rmdir", path)
    if io.exists(path) then
        require "lfs"
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then                                
                    local curDir = path .. dir
                    local mode = lfs.attributes(curDir, "mode")                   
                    if mode == "directory" then
                        _rmdir(curDir .. "/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end    
                end
            end    
            local succ, des = os.remove(path)
            if des then
                print(des)
            end
            return succ
        end
        _rmdir(path)
    end  
    local succ, des = os.remove(path)
    if des then print(des) end  
    
    return true
end