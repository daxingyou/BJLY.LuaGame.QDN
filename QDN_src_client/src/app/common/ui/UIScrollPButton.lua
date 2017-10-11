
--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--[[--

quick 按钮控件

]]
local UIButton        = require("framework.cc.ui.UIButton")
local UIPushButton    = require("framework.cc.ui.UIPushButton")
local UIScrollPButton = class("UIScrollPButton", UIPushButton )

--[[--

按钮控件构建函数
]]
local DISTANCE        = 10
function UIScrollPButton:ctor(images, options)
    UIScrollPButton.super.ctor( self, images, options )
    self:setTouchSwallowEnabled(false)
    self.Y = 0
end

function UIScrollPButton:onTouch_(event)
    -- print("----UIScrollPButton:onTouch_")
    local name, x, y = event.name, event.x, event.y
    -- print("----name, x, y = ", name, x, y)
    if  name == "began" then
        -- print("----began")
        if not self:checkTouchInSprite_(x, y) then return false end
        -- print("----doEvent('press')")
        self.fsm_:doEvent("press")
        self:dispatchEvent({name = UIButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        self.startP = cc.p(x, y)
        return true
    end

    local touchInTarget = self:checkTouchInSprite_(x, y)
    if  name == "moved" then
        if  touchInTarget and self.fsm_:canDoEvent("press") then
            self.fsm_:doEvent("press")
            self:dispatchEvent({name = UIButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        elseif not touchInTarget and self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
            self:dispatchEvent({name = UIButton.RELEASE_EVENT, x = x, y = y, touchInTarget = false})
        end
    else
        if  self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
            self:dispatchEvent({name = UIButton.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})
        end

        -- move过10像素则视为滑动
        local dis = cc.pGetDistance(self.startP, cc.p(x, y))
        if  name == "ended" and touchInTarget and math.abs(dis) <= DISTANCE then
            self:dispatchEvent({name = UIButton.CLICKED_EVENT, x = x, y = y, touchInTarget = true})
        end
    end
end

return UIScrollPButton
