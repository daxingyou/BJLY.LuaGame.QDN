--[[
    音频的管理器
    音乐音效总管理
]]
require "framework.audio"


local audio_manager = audio_manager or {}

local audio_handle = {}

--是否播放背景音乐
function audio_manager.isMusionOn()
    local result = g_LocalDB:read( "bgmstate" ) == 1 or false
    return result
end

--是否开启音效
function audio_manager.isSoundOn()
    local result = g_LocalDB:read( "soundstate" ) == 1 or false
    return result
end

--音频具柄初始化
function audio_manager.init()
    audio_handle = {}
    local soundValume  = g_LocalDB:read("soundvalume")
    audio_manager.setSoundVolume(soundValume/100)

    local musicValume  = g_LocalDB:read("bgvalume")
    audio_manager.setMusicVolume(musicValume/100)
end

--播放按钮音效
function audio_manager.playButtonSound(_name)
    audio_manager.playSound(g_audioConfig.sound[_name])
end

--播放按钮音效
function audio_manager.playTileSound(_name,_sex)
    local sound_info = g_audioConfig.card[_name]
    local lg = g_LocalDB:read("language_type")

    if "normal" == lg  then
        --普通话
        if _sex == 1 then -- 男
            audio_manager.playSound(sound_info["man_common"])
        else
            audio_manager.playSound(sound_info["woman_common"])
        end
    else
        if _sex == 1 then -- 男
            audio_manager.playSound(sound_info["man_native"])
        else
             audio_manager.playSound(sound_info["woman_native"])
        end
    end
end

--当前播放背景音乐
audio_manager.m_musicName = ""

--播放背景音乐
function audio_manager.playMusic(_name, _isLoop)
    if _isLoop == nil then
        _isLoop = true
    end
    if not audio_manager.isMusionOn() then
        return
    end
    local musicName = _name
    print("musicName ----",musicName)
    if musicName then
        audio.playMusic(musicName, _isLoop)
        audio_manager.m_musicName = musicName

   
    end
end

--停止背景音乐
function audio_manager.stopMusic(_isRelease)
    audio.stopMusic(_isRelease)
    audio_manager.m_musicName = ""
end

--暂停背景音乐
function audio_manager.pauseMusic()
    audio.pauseMusic()
end

--恢复背景音乐
function audio_manager.resumeMusic()
    audio.resumeMusic()
end

--修改背景音乐大小(0~1.0)
function audio_manager.setMusicVolume(_v)
    audio.setMusicVolume(_v)
end


function audio_manager.setSoundVolume(_v)
    audio.setSoundsVolume(_v)
end

--播放音效
function audio_manager.playSound(_name, _isLoop)
    if not _isLoop then
        _isLoop = false
    end
    if not audio_manager.isSoundOn() then
        return
    end

    local _soundName = _name 
    if g_GameConfig then

    end
    if _soundName~=nil then
        --循环播放的音效，不重复播
        if _isLoop and audio_handle[_soundName] then
            return
        end
        local handle = audio.playSound(_soundName, _isLoop)
        audio_handle[_soundName] = handle

        
    end
end

--根据音效名称停止音效
function audio_manager.stopSoundWithName(_name)
    -- printTable("stopSoundWithName",audio_handle)
    if audio_handle[_name] then
        print("stop sound :", _name, audio_handle[_name])
        audio_manager.stopSound(audio_handle[_name])
        audio_handle[_name] = nil
    end
end

--根据音效句柄
function audio_manager.stopSound(_handle)
    audio.stopSound(_handle)
end

--停止全部音效
function audio_manager.stopAllSound()
    audio.stopAllSounds()
end

--暂停
function audio_manager.pauseAllSound()
    audio.pauseAllSounds()
end
function audio_manager.resumeAllSound()
    audio.resumeAllSounds()
end

function audio_manager.releaseSound(_name)

    if audio_handle[_name] then
        audio.unloadSound(k)
    end
end

function audio_manager.releaseAllSound()
    for k,v in pairs(audio_handle) do
        audio.unloadSound(k)
    end
    audio_handle = {}
end

--重新加载
function audio_manager.preloadSound(_name)
    audio.preloadSound(_name)
end

--卸载
function audio_manager.unloadSound(_name)
    audio.unloadSound(_name)
end

--播放地图背景音
function audio_manager.playMap(_fid)
    local fid = _fid
    if not fid and audio_manager.m_mapfid then
        fid = audio_manager.m_mapfid
    end
    if fid then
        local musicName = fid.."_map_bg.mp3"
        --防止重头开始播放同一背景音
        if musicName ~= audio_manager.m_musicName then
            g_audio.playMusic(musicName)
        end
        if not audio_manager.m_mapfid or audio_manager.m_mapfid ~= fid then
            audio_manager.m_mapfid = fid
        end
    end
end

return audio_manager
