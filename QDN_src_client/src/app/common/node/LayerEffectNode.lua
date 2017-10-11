--
-- Author: XuJian
-- 场景特效
--

local LayerEffectNode = class("LayerEffectNode", function()
		local node = display.newNode()
		return node
	end)


function LayerEffectNode:ctor(_action, ...)
    display.addSpriteFrames("fly_effect.plist", "fly_effect.pvr.ccz")
end

--[[
	冲锋
	_sprFile 精灵图
	_num 量级 (100一个)
	_sp 起点
	_ep 终点
	_range 分布范围（精灵散开的范围 -_range..._range ）
	_fun 终点调用 fun(_price) end（每个精灵结束，会调用一次，参数表示当前精灵给的分）
	]]
function LayerEffectNode:assault(_sprFile, _num, _sp, _ep, _range, _fun, _endFun)
	--一颗代表的数量
    local price = 100
	--结束点
    local ex = _ep.x
    local ey = _ep.y
    --点创建函数(当前点得价值)
    local function createfun(_curPrice, _endFun)
    	--起点计算
        local sx = _sp.x+math.random(-_range, _range)
        local sy = _sp.y+math.random(-_range, _range)
        --精灵
        local spr = display.newSprite(_sprFile)
        spr:addTo(self)
        spr:setPosition(sx, sy)
        spr:setScale(0.0, 0.0)
        --出现吧
        local showScale = math.random(1,3)*0.1
        spr:runAction(cc.ScaleTo:create(showScale, 0.6))
        spr:runAction(cc.Sequence:create({
            cc.DelayTime:create(showScale), --停会
            cc.CallFunc:create(function()
                spr:runAction(cc.ScaleTo:create(0.5, 1.0))
                local seq = {
                    cc.EaseExponentialInOut:create(cc.MoveTo:create(1.0, cc.p(ex, ey))), --执行冲刺
                    cc.DelayTime:create(0.2), --停会
                    cc.CallFunc:create(function()
                    	spr:removeSelf()
                    	if _fun then _fun(_curPrice) end
                        if _endFun then _endFun() end
                    end), --干掉自己
                }
                spr:runAction(cc.Sequence:create(seq))
            end),
            }))
    end
    --计算批次
    local subNum = 5
    local t = {}
    local max = math.floor(_num/price)
    while true do
    	max = max - subNum
    	if max > 0 then
    		table.insert(t, subNum)
    	else
    		table.insert(t, subNum-max)
    		break
    	end
    end
    --创建分布点
    local len = #t
    for i,v in ipairs(t) do
    	self:performWithDelay(function()
            for j=1,v do
            	print(i, j, v)
            	if i==len and j==v then
            		createfun(price+_num%price, _endFun) --最后一次，把剩下全给
            	else
            		createfun(price, nil)
            	end
            end
        end, i*0.1)
    end
end
--[[
    金币喷泉
    _num 量级 (100一个)
    _sp 起点
    _r 初始分布范围
    _h 弹出高度
    _w 弹出宽度
    _showx 是否添加小星星
    _fun 终点调用 fun(_price) end（每个精灵结束，会调用一次，参数表示当前精灵给的分）
    ]]
function LayerEffectNode:fountainCoin(_num, _pos, _r, _h, _w, _showx, _fun)

    local range = _r or 100 --初始动态分布
    local height = _h or 150 --弹出高度分布
    local width = _w or 50 --弹出宽度分布

    --点创建函数
    local function createfun(__delay, __fun)
        --点计算
        local p0 = cc.p(_pos.x + math.random(-range, range), _pos.y + math.random(-range, range))
        local fang = math.random(-width, width) --左右
        local p1 = cc.p(p0.x + fang, _pos.y + math.random(height*0.3, height))
        local p2 = cc.p(p1.x + fang+ math.random(width*0.1, width), p1.y + math.random(height*0.1, height))
        local p3 = cc.p(p2.x + fang * math.random(0, 10)*0.1, -display.height*0.1)
        local bezier = {p1, p2, p3}

        --精灵
        local name = string.format("#fly_coin%d.png", math.random(1,6))
        if _showx and math.random(1,10) > 7 then
            name = "#fly_exp.png"
        end
        local spr = display.newSprite(name)
        spr:addTo(self)
        spr:setPosition(p0)
        spr:setScale(0.0, 0.0)
        --旋转吧
        -- local fs = display.newFrames("fly_coin%d.png", 1, 6)
        -- local act = display.newAnimation(fs, 0.4/4)
        -- spr:playAnimationForever(act, 0.0)
        --跳起来
        spr:runAction(cc.Sequence:create({
            cc.DelayTime:create(__delay), --停会
            cc.CallFunc:create(function()
                spr:runAction(cc.ScaleTo:create(0.1, 2.0))
                local seq = {
                    cc.EaseBackOut:create(cc.BezierTo:create(1.5 + math.random(0, 10)*0.1, bezier)), --曲线
                    -- cc.DelayTime:create(0.1), --停会
                    cc.CallFunc:create(function()
                        spr:removeSelf()
                        if __fun then __fun() end
                    end), --干掉自己
                }
                spr:runAction(cc.Sequence:create(seq))
            end),
            }))
    end
    --循环创建点
    for i=1,_num do
        createfun(0)
    end
    --循环创建点
    -- for i=1,_num do
    --     if i == _num and _fun then
    --         createfun(i*0.1, _fun)
    --     else
    --         createfun(i*0.1)
    --     end
    --     print("i*0.1", i*0.1)
    -- end
    --循环创建点
    -- local ntime = 0.1
    -- for i=1,_num do
    --     if i == _num and _fun then
    --         createfun(math.random(1,5)*0.1, _fun)
    --     else
    --         createfun(math.random(1,5)*0.1, nil)
    --     end
    -- end
end
--[[
    金币钻石星星喷泉
    _num 量级 (100一个)
    _sp 起点
    _r 初始分布范围
    _h 弹出高度
    _w 弹出宽度
    _fun 终点调用 fun(_price) end（每个精灵结束，会调用一次，参数表示当前精灵给的分）
    _star 是否显示星星
    ]]
function LayerEffectNode:fountainCGS(_num, _pos, _r, _h, _w,_fun,_star)

    local range = _r or 100 --初始动态分布
    local height = _h or 150 --弹出高度分布
    local width = _w or 50 --弹出宽度分布

    --点创建函数
    local function createfun(__delay,_idx)
        local _offset=-1
        local type=0
        if not _star then
            _offset=0
        end
        local scale=0.7
        --精灵
        local name ="#ui_icon_coins.png"
        if math.random(1,10) >= 8 then
            type=1
            _offset=0
            if not _star then
                _offset=0
            end
            name = "#ui_icon_gems.png"
        end
        if _star and math.random(1,10)==10 then
            name="#ui_task_d_star.png"
            _offset=1
            scale=1
            type=2
        end

        --点计算
        local p0 = cc.p(_pos.x + math.random(-range, range)+_offset*300, _pos.y + math.random(-range, range))
        local fang = math.random(-width, width) --左右

        local p1 = cc.p(p0.x + fang, _pos.y + math.random(height*0.1, height))
        local p2 = cc.p(p1.x + fang+ math.random(width*0.1, width), p1.y + math.random(height*0.1, height))
        local p3 = cc.p(p2.x, display.height*0.3)
        local p4 = cc.p(p2.x, display.height*0.3)
        local bezier = {p1, p2, p3}


        local spr = display.newSprite(name)
        spr:addTo(self)
        spr:setPosition(p0)
        spr:setScale(0.0, 0.0)
        --跳起来
        spr:runAction(cc.Sequence:create({
            cc.DelayTime:create(__delay), --停会
            cc.CallFunc:create(function()
                spr:runAction(cc.ScaleTo:create(0.1, scale))
                local time=0.4 + math.random(0, 10)*0.03
                -- spr:setRotation(math.random(1,180))
                local seq = {
                    cc.Spawn:create({
                        cc.BezierTo:create(time, bezier), --曲线
                        cc.RotateTo:create(time, math.random(1,360)),
                     }),
                    cc.CallFunc:create(function()
                            local p1 = cc.p(spr:getPositionX(),spr:getPositionY())
                            local p2 = cc.p(spr:getPositionX(),spr:getPositionY())
                            local p3 = nil
                            if type==0 then
                                p3 = cc.p(display.width*0.2, display.height*0.95)
                            elseif type==1 then
                                p3 = cc.p(display.width*0.5, display.height*0.95)
                            elseif type==2 then
                                p3 = cc.p(display.width*0.75, display.height*0.95)
                            end

                            local bezier = {p1, p2, p3}

                            -- spr:setRotation(math.random(1,360))

                            local delay =cc.DelayTime:create(0.2)--停会

                            local bezierTo = cc.BezierTo:create(0.3 + math.random(0, 10)*0.03, bezier)

                            local fun = cc.CallFunc:create(function()
                                            if _idx ==_num then
                                                g_msg:post(g_msgcmd.DB_UPDATE_MAIN_MENU, {hasAcion=true})
                                            end
                                            spr:removeSelf()
                                            if _fun and _idx==_num then _fun() end
                                        end)

                            local seq = cc.Sequence:create(delay,bezierTo,fun)
                            spr:runAction(seq)
                    end),
                }
                spr:runAction(cc.Sequence:create(seq))
            end),
            }))
    end
    --循环创建点
    for i=1,_num do
        createfun(0,i)
    end
	g_audio.playSound(g_audioConfig.sound["task_shouji"])
end

--[[
    彩带
    _num 量级 (100一个)
    _delay 创建延时
    _sp 起点
    _r 初始分布范围
    _h 弹出高度
    _w 弹出宽度
    _fun 终点调用 fun(_price) end（每个精灵结束，会调用一次，参数表示当前精灵给的分）
    ]]
function LayerEffectNode:fountainColor(_num, _delay, _pos, _r, _h, _w, _fun)

    local range = _r or 100 --初始动态分布
    local height = _h or 150 --弹出高度分布
    local width = _w or 50 --弹出宽度分布 决定左右

    local fushu = 1
    if width < 0 then --负数往右喷
        fushu = -1
    end
    width = math.abs(width)

    --点创建函数
    local function createfun(__delay, __fun)
        --点计算
        local p0 = cc.p(_pos.x + math.random(-range, range), _pos.y + math.random(-range, range))
        local fang = 0
        fang = math.random(width*0.5, width) * fushu
        local p1 = cc.p(p0.x + fang, _pos.y + math.random(height*0.1, height))
        local p2 = cc.p(p1.x + fang + math.random(width*0.1, width)*fushu, p1.y + math.random(height*0.1, height))
        local p3 = cc.p(p2.x + fang * math.random(0, 10)*0.1, -display.height*0.1)
        local bezier = {p1, p2, p3}

        --精灵
        local name = string.format("#fly_d%d.png", math.random(1,17))
        local spr = display.newSprite(name)
        spr:addTo(self)
        spr:setPosition(p0)
        spr:setScale(0.0, 0.0)
        --旋转吧
        -- spr:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.3, 360)))
        --跳起来
        spr:runAction(cc.Sequence:create({
            cc.DelayTime:create(__delay), --停会
            cc.CallFunc:create(function()
                spr:runAction(cc.ScaleTo:create(0.1, 0.7))
                local seq = {
                    cc.BezierTo:create(1.0 + math.random(0, 10)*0.1, bezier), --曲线
                    -- cc.DelayTime:create(0.1), --停会
                    cc.CallFunc:create(function()
                        spr:removeSelf()
                        if __fun then __fun() end
                    end), --干掉自己
                }
                spr:runAction(cc.Sequence:create(seq))
            end),
            }))
    end
    --循环创建点
    for i=1,_num do
        createfun(_delay)
    end
    --循环创建点
    -- for i=1,_num do
    --     if i == _num and _fun then
    --         createfun(i*0.1, _fun)
    --     else
    --         createfun(i*0.1)
    --     end
    --     print("i*0.1", i*0.1)
    -- end
    --循环创建点
    -- local ntime = 0.1
    -- for i=1,_num do
    --     if i == _num and _fun then
    --         createfun(math.random(1,5)*0.1, _fun)
    --     else
    --         createfun(math.random(1,5)*0.1, nil)
    --     end
    -- end
end

--[[
    宝箱金币
    _num 量级 (100一个)
    _pos 起点
    _endy 结束y点
    _r 初始分布范围
    _h 弹出高度
    _w 弹出宽度
    _fun 终点调用 fun(_price) end（每个精灵结束，会调用一次，参数表示当前精灵给的分）
    ]]
function LayerEffectNode:chestCoin(_num, _pos, _endy, _r, _h, _w, _fun,_globalZ)

    local range = _r or 100 --初始动态分布
    local height = _h or 150 --弹出高度分布
    local width = _w or 50 --弹出宽度分布
    local globalZ = _globalZ or 1
    --点创建函数
    local function createfun(__delay, __fun)
        --点计算
        local p0 = cc.p(_pos.x + math.random(-range, range), _pos.y + math.random(-range, range))
        local fang = math.random(-width*2, width*2) --左右
        local p1 = cc.p(p0.x + fang, _pos.y + math.random(height*0.1, height))
        local p2 = cc.p(p1.x + fang+ math.random(width*0.1, width), p1.y + math.random(height*0.1, height))
        local p3 = cc.p(p2.x + fang * math.random(0, 10)*0.1, _endy)
        local bezier = {p1, p2, p3}

        --精灵
        local name = string.format("#fly_coin%d.png", math.random(1,6))
        -- local name = string.format("#fly_coin%d.png", 1)
        local spr = display.newSprite(name)
        spr:addTo(self)
        spr:setPosition(p0)
        spr:setScale(0.0, 0.0)

        --跳起来
        spr:runAction(cc.Sequence:create({
            cc.DelayTime:create(__delay), --停会
            cc.CallFunc:create(function()
                spr:runAction(cc.ScaleTo:create(0.1, 0.8))
                local seq = {
                    cc.BezierTo:create(0.5 + math.random(0, 10)*0.05, bezier), --曲线
                    -- cc.DelayTime:create(0.0), --停会
                    cc.CallFunc:create(function()
                        --旋转吧
                        local fs = display.newFrames("fly_coin%d.png", 1, 6)
                        local act = display.newAnimation(fs, 0.2/5)
                        spr:playAnimationForever(act, 0.0)
                    end),
                    cc.DelayTime:create(0.1+math.random(1,2)*0.1), --停会
                    cc.CallFunc:create(function()
                        spr:removeSelf()
                        if __fun then __fun() end
                    end), --干掉自己
                }
                spr:runAction(cc.Sequence:create(seq))
                --弹出后改变Z
                spr:runAction(cc.Sequence:create({
                    cc.DelayTime:create(0.25),
                    cc.CallFunc:create(function()
                            spr:setGlobalZOrder(globalZ)
                        end),
                    }))

            end),
            }))
    end

    --循环创建点
    local ntime = 0.1
    for i=1,_num do
        if i == _num and _fun then
            createfun(math.random(1,5)*0.05, _fun)
        else
            createfun(math.random(1,5)*0.05, nil)
        end
    end
end

--示例
    -- self.m_effNode = require("app.node.LayerEffectNode").new()
    -- self.m_effNode:addTo(self, 100, 100)

    -- self.m_effNode:flyEffect(10, cc.p(200,200), cc.p(700,900), {"#fly_coin1.png","#fly_coin2.png","#fly_coin3.png"},
    --                                     function(_score)
    --                                         print("flyEffect coins:::::",_score)
    --                                     end , 100)
--金币或宝石飞的特效
function LayerEffectNode:flyEffect(_num, _starPos, _endPos, _imgNames, _fun,_scale)
    local imgfiles = _imgNames or {"#fly_coin1.png"} --
    local maxImgNum = #imgfiles
    local range = 100
    local _scale = _scale or 1
    local function createfun(__fun, __score)
        local px  =  math.random(1,range) - math.random(1,range)
        local py  =  math.random(1,range) - math.random(1,range)

        local p1 = cc.p(_starPos.x+px,_starPos.y+py)
        local p2 = cc.p(_starPos.x+px,_starPos.y+py)
        local p3 = _endPos
        local bezier = {p1, p2, p3}

        local imgIndex = (math.random(1,maxImgNum))
        local name = imgfiles[imgIndex]
        local spr = display.newSprite(name)
        spr:setScale(_scale)
        spr:setRotation(math.random(1,360))

        local bezierTo = cc.BezierTo:create(0.5 + math.random(0, 10)*0.05, bezier)

        local fun = cc.CallFunc:create(function()
                        spr:removeSelf()
                        if __fun then __fun(__score) end
                    end)

        local seq = cc.Sequence:create(bezierTo,fun)

        -- print("start pos:",px,py,_endPos.x,_endPos.y)
        spr:addTo(self)
        spr:setPosition(cc.p(_starPos.x,_starPos.y))
        spr:runAction(seq)
    end
    for i=1,_num do
        -- print("flyEffect create::::",i)
		self:performWithDelay(function()
			createfun(_fun, i)
		end, 0.05*i)
		-- createfun(_fun, i)
    end
end

function LayerEffectNode:flyEffect2(_starPos, _endPos, _fun, _totalScore)
    local totalScore = _totalScore or 0

    local effect = g_utils.playParticleFile("lizi_spin_petexp.plist",self,_starPos,1, false)

    local p1 = cc.p(_starPos.x-100,_starPos.y+200)
    local p2 = cc.p(_starPos.x-150,_starPos.y+400)
    local p3 = _endPos
    local bezier = {p1, p2, p3}

    local t = 1.0
    --local bezierTo = cc.EaseExponentialIn:create(cc.BezierTo:create(t, bezier))
    --local bezierTo = cc.EaseSineIn:create(cc.BezierTo:create(t, bezier))
    local bezierTo = cc.EaseIn:create(cc.BezierTo:create(t, bezier),1.2)

    local fun = cc.CallFunc:create(function()
		g_utils.playParticleFile("lizi_petexp.plist",self,_endPos,1, true)
		if __fun then __fun() end
    end)

    local seq = cc.Sequence:create(bezierTo, fun)
    effect:setDuration(t+0.05)
    effect:setAutoRemoveOnFinish(true)
    effect:runAction(seq)

end
--[[
    移动白云
    _num 白云数量
    ]]
function LayerEffectNode:moveYun(_num)
    local function createfun(_i)
        local range=200--云上下浮动范围

        local spr=display.newSprite("map_1001_e_yun.png")
        spr:addTo(self)
        local type=_i%2
        local scaleX=math.random(2,3.5)
        local scaleY=math.random(1.5,2)
        if type==0 then
            scaleX=scaleX*math.random(5,7)*0.1
            scaleY=scaleY*math.random(5,7)*0.1
        end
        spr:setScaleX(scaleX)
        spr:setScaleY(scaleY)
        local width=spr:getContentSize().width*scaleX
        local posEnd=nil
        if type==0 then
            posEnd=cc.p(display.width+width, 0)
        elseif type==1 then
            posEnd=cc.p(-display.width-width, 0)
        end
        print("LayerEffectNode  width"..width)
        spr:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create({
                    cc.CallFunc:create(function()
                        spr:setOpacity(math.random(200,255))

                        local pos=nil
                        if type==0 then
                            spr:setAnchorPoint(cc.p(1,0.5))
                            pos = cc.p(0, display.height*0.5 + math.random(-range, range))
                        elseif type==1 then
                            spr:setAnchorPoint(cc.p(0,0.5))
                            pos = cc.p(display.width, display.height*0.5 + math.random(-range, range))
                        end
                        spr:setPosition(pos)
                    end),
                    cc.DelayTime:create(0.1),
                    cc.MoveBy:create(20+ math.random(0, 10)*1+type*0.5, posEnd),
                }))
            )
    end
    for i=1,_num do
        createfun(i)
    end
end
--[[
    移动光
    _num 白云数量
    ]]
function LayerEffectNode:moveGuang(_num)
    local function createfun(_i)
        local type=_i%2
        local canshu=nil
        if type==0 then
            canshu=-1
        elseif type==1 then
            canshu=1
        end
        local range=200--灯左右浮动范围

        local spr=display.newSprite("map_1002_e_bg.png")
        local guang=display.newSprite("map_1002_e_guang.png")
        guang:setAnchorPoint(cc.p(0.25,-0.17))
        spr:addChild(guang, 1, 1)
        spr:addTo(self)
        spr:setAnchorPoint(cc.p(0.5,0.5))
        spr:setRotation(-40*canshu)
        spr:setOpacity(200)
        spr:setPosition(display.width*0.5+range*canshu,display.height*0.40)
        spr:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create({
                    cc.CallFunc:create(function()

                    end),
                    cc.RotateBy:create(2+math.random(0, 10)*0.1, 80*canshu),
                    cc.RotateBy:create(2+math.random(0, 10)*0.1, -80*canshu),
                }))
            )
    end
    for i=1,_num do
        createfun(i)
    end
end

return LayerEffectNode
