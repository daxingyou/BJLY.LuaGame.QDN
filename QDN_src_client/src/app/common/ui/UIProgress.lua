--
-- Author: XuJian
-- 经验条
--
local DEFAULT_REF    = -1 --第一次设定默认数
local RUN_STEP_TIME = 0.05 --运行步伐时间

local UIProgress = class("UIProgress", function()
		local node = display.newNode()
		return node
	end)

function UIProgress:ctor(_bgImage, _headImage, _particle, _aniNode)
	--进度条
	local sprBar = display.newSprite(_bgImage)
	local barLevel = display.newProgressTimer(sprBar, display.PROGRESS_TIMER_BAR)
    barLevel:setMidpoint(cc.p(0,0))--x为0代表进度条从左边开始      setMidpoint:用来设定进度条横向前进的方向从左向右或是从右向左
    barLevel:setBarChangeRate(cc.p(1,0)) --y为0代表进度条垂直方向无增长   setBarChangeRate:用来设置进度条增长按横向或是按纵向增长
    barLevel:setAnchorPoint(cc.p(0,0))
    barLevel:setPosition(0, 0)
    barLevel:addTo(self, 1, 1)
    self.m_barLevel = barLevel

    --进度头
    if _headImage then
    	local sprAni = display.newSprite(_headImage)
    	self.m_aniPos = cc.p(0, sprBar:getContentSize().height*0.5)
	    sprAni:setPosition(self.m_aniPos)
    	sprAni:addTo(self, 3, 2)
    	self.m_sprAni = sprAni
	end

	--粒子
	if _particle then
		self.m_particle = g_utils.playParticleFile(_particle, self, self.m_aniPos, 2, false)
	end

	--外挂动画
	if _aniNode then
		_aniNode:addTo(self, 4, 4)
		_aniNode:setPosition(self.m_aniPos)
		self.m_aniNode = _aniNode
	end

	self.m_duration = 0.5 --每次移动时间
    self.m_percent 	= 0 --进度值
    self.m_refNum  	= DEFAULT_REF --参考值
    self.m_runList  = {} --动画行动表
    self.m_refFun   = nil --参考数回调

    self.m_toNum  = DEFAULT_REF --动画进度
    self.m_curNum = 0
    self.m_step   = 0
end

--设定每次移动时间（默认0.5秒）
function UIProgress:setDuration(_duration)
	self.m_duration = _duration
end

--设置进度(进度值，参考数)
--参考数(比如传入等级)
--第一次设定，进度条不走动，直接设置
--参考数增加，进度条随参考数快速走动满条次数
--参考数减少，进度条不走动，直接设置
function UIProgress:setPercentage(_percent, _refNum)
	local curPer = self.m_percent
	local curRef = self.m_refNum
	-- print("UIProgress:setPercentage", _percent, _refNum, curPer, curRef)

	--返回时间
	local r = 0

	--都一样不更新
	if _percent == self.m_percent and _refNum == self.m_refNum then
		return r
	end

	self.m_percent = _percent
	self.m_refNum  = _refNum

	--先停止
	self:stop()

	--增加播放步伐（时间片(以最小单位倍数)，数）
	local function fnAddPlayStep(_t, _n, _f, _p)
		local s = {}
		s.time 	= _t
		s.tonum = _n
		s.fun   = _f
		s.param = _p
		table.insert(self.m_runList, s)
		r = r + s.time
	end

	--第一次设定 / 参考数减少
	if DEFAULT_REF == curRef or _refNum < curRef then
		--立刻完成
		fnAddPlayStep(RUN_STEP_TIME, self.m_percent)
	else
		--计算播放列表
		self.m_runList = {}
		--升级
		local num = self.m_refNum - curRef
		if num > 0 then
			for i=1,num do
				fnAddPlayStep(self.m_duration, 100, self.m_refFun, curRef+i)
				fnAddPlayStep(RUN_STEP_TIME, 0)  --停一次
			end
		end
		--当前
		fnAddPlayStep(self.m_duration, self.m_percent)
		--打开粒子
		if self.m_particle then
			self.m_particle:setVisible(true)
		end
		if self.m_aniNode then
			-- self.m_aniNode:setVisible(true)
			if self.m_aniNode.m_playFun then
				self.m_aniNode.m_playFun()
			end
		end
	end

	--开始播放
	self:play()
	return r
end

function UIProgress:play()
	local curFun = nil
	local param  = nil
	--取下一步
	local function nextRun()
		--执行当次运行回调
		if curFun then
			curFun(param)
			curFun = nil
		end
		local runList = self.m_runList
		if not runList or 0 == #runList then
			--结束
			self:stop()
			return
		end
		--走完一圈，当前数返回0
		if self.m_curNum >= 100 then
			self.m_curNum = 0
		end
		local s = runList[1]
		--计算步伐
		local count  = s.time/RUN_STEP_TIME
		self.m_toNum = s.tonum
		self.m_step  = (self.m_toNum - self.m_curNum) / count
		curFun = s.fun
		param = s.param
		table.remove(self.m_runList, 1)
		-- print("nextRun", self.m_toNum, self.m_step)
	end

	--更新进度
	-- local showNum = 0
	local function updateRun()
		--前进
		self.m_curNum = self.m_curNum + self.m_step
		-- print("updateRun", self.m_curNum, self.m_step, self.m_toNum)
		--边界
		if self.m_curNum >= self.m_toNum then
			self.m_curNum = self.m_toNum
			self.m_toNum  = DEFAULT_REF --进入下一轮
		end
		self:__setProgress(self.m_curNum)
	end

	--运行
	local function runFun()
		if DEFAULT_REF == self.m_toNum then
			nextRun()
		end
		if self.m_toNum >= 0 then
			updateRun()
		end
	end
	runFun()
	self.m_runAct = self:schedule(runFun, RUN_STEP_TIME)
end

function UIProgress:stop()
	-- print("stop", self.m_curNum, self.m_toNum)
	self:__setProgress(self.m_percent)
	self.m_toNum = DEFAULT_REF
	if self.m_particle then
		self.m_particle:setVisible(false)
	end
	if self.m_aniNode then
		-- self.m_aniNode:setVisible(false)
		if self.m_aniNode.m_stopFun then
			self.m_aniNode.m_stopFun()
		end
	end
	if self.m_runAct then
		self:stopAction(self.m_runAct)
		self.m_runAct = nil
	end
end

--设置进度
function UIProgress:__setProgress(_num)
	-- print("UIProgress:__setProgress", _num)
	--进度条
	self.m_barLevel:setPercentage(_num)
	--跟随动画
	local sprAni = self.m_sprAni
	if sprAni then
		sprAni:setVisible(true)
		local w = self.m_barLevel:getContentSize().width / 100 * _num
		sprAni:setPositionX(self.m_aniPos.x + w)
		if self.m_particle then
			--跟随粒子
			self.m_particle:setPositionX(sprAni:getPositionX())
		end
		if self.m_aniNode then
			self.m_aniNode:setPositionX(sprAni:getPositionX())
		end
		--头尾，不显示跟随节点
		if 0 == _num or 100 == _num then
			sprAni:setVisible(false)
		end
	end
end

--跳过动画
function UIProgress:setSkipAni()
	self.m_refNum = DEFAULT_REF
	self.m_toNum  = DEFAULT_REF
end

--设置参考数改变回调
function UIProgress:setRefFun(_fn)
	self.m_refFun = _fn
end

--测试走动动画(走动幅度)
function UIProgress:test(_min, _max)
	--第一次设定
	self:setPercentage(0, 1)
	--循环测试移动
    local num = 0
    local level = 1
    self:schedule(function()
            num = num + math.random(_min, _max)
            if num > 100 then
                num = num - 100
                level = level + 1
            end
            self:setPercentage(num, level)
        end, self.m_duration * 1.5)
end

return UIProgress
