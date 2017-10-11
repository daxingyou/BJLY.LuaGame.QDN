--ui基础类，ui显示类以此类进行扩展
local BaseUILayer = class("BaseUILayer", function()
    return cc.LayerColor:create(cc.c4b(0,0,0,0))
end)

function BaseUILayer:ctor()
	print("BaseUILayer:ctor()")
    self:initData()
    self:loadCCB()
    self:initUI()
end
--初始化相关数据
function BaseUILayer:initData()
end
--加载ui文件
function BaseUILayer:loadCCB()
end    

--初始化ui
function BaseUILayer:initUI()

end
return BaseUILayer


