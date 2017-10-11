--[[
	UIEditBox
    用法示例
        local config={
        layer=self.m_ccbRoot.m_layerEditBox,
        fontSize=20,
        image="img_pos.png",
        maxLength=140,

    }
    self.m_uiEditBox=require("lib.ui.UIEditBox").new(config)
    self.m_ccbRoot.m_spriteEditBox:addChild(self.m_uiEditBox)
]]

local UIEditBox = class("UIEditBox", function()
    local node=display.newNode()
    return node
end)
--配置
function UIEditBox:ctor(_cfg)
	self:initData(_cfg)
	self:initUI()
end
function UIEditBox:initData(_cfg)
	self.m_cfg=_cfg
    self.m_layer=_cfg.layer
    self.m_image=_cfg.image
    self.m_fontSize=_cfg.fontSize
    self.m_color=_cfg.color or cc.c3b(255,255,255)
    self.m_maxLength=_cfg.maxLength
    self.m_text=_cfg.text or ""
    self.m_label=_cfg.label
    self.m_keyBord=_cfg.keyBord or cc.KEYBOARD_RETURNTYPE_DONE
    self.m_inputMode=_cfg.inputMode or cc.EDITBOX_INPUT_MODE_ANY
    self.m_listener= _cfg.listener or nil
    self.m_inputString = ""
    self.m_showCursor = true
end

function UIEditBox:initUI()
    local tempsize=self.m_layer:getContentSize()
    local width=tempsize.width
    local size=cc.size(width*5,tempsize.height)
    local posX=self.m_layer:getPositionX()-width*4
    local posY=self.m_layer:getPositionY()
    
    self.m_edb = cc.ui.UIInput.new({
        image = self.m_image,
        size = size,
        x = posX,
        y = posY,
        --listener=self.onEditBox,
        listener = function(event, editbox)
            if event == "began" then
                self:onEditBoxBegan(editbox)
            elseif event == "ended" then
                self:onEditBoxEnded(editbox)
            elseif event == "return" then
                self:onEditBoxReturn(editbox)
            elseif event == "changed" then
                self:onEditBoxChanged(editbox)
            else
                printf("EditBox event %s", tostring(event))
            end

            if self.m_listener then
                self.m_listener(event, editbox)
            end
        end
    })
    self.m_edb:setAnchorPoint(cc.p(0,0)) 
    if self.m_color then
        self.m_edb:setFontColor(self.m_color)
    end
    self.m_edb:setInputMode(self.m_inputMode)
    self.m_edb:setMaxLength(self.m_maxLength)
    --self.m_edb:setInputFlag(0)
    --self.m_edb:setFontSize(0)
    self.m_edb:setFont("Arial", 0)
    self.m_label:setSystemFontSize(self.m_fontSize)
    self.m_edb:setReturnType(self.m_keyBord)
    self.m_label:setColor(cc.c3b(255, 255, 255))
    if self.m_text then
        self.m_edb:setText(self.m_text)
        self.m_label:setString(self.m_text)
        self.m_inputString = self.m_text
    end
    self.m_edb:addTo(self)
    self.m_edb:setFontColor(cc.c3b(0,255,0))

    self.m_edb:setVisible(false)
end
function UIEditBox:onEditBoxBegan(editbox)
    print("editbox event began : text = %s", editbox:getText(),self.m_label:getString())
    editbox:setText(self.m_label:getString())
    self.m_inputString = self.m_label:getString()

    if self.m_cursorSchedule == nil then
        self.m_showCursor = true
        self:updateCursor()
        self.m_cursorSchedule = self:schedule(function() self:updateCursor() end, 0.5)
    end
    --editbox:setFontColor(cc.c3b(255, 255, 255))
end

function UIEditBox:onEditBoxEnded(editbox)
    print("editbox event Ended : text = %s", editbox:getText())
end

function UIEditBox:onEditBoxReturn(editbox)
    print("editbox event Return : text = %s", editbox:getText())
    local str = editbox:getText()  
    editbox:setText("")  
    self.m_label:setString(str) 
    self.m_inputString = str

    if self.m_cursorSchedule ~= nil then
            self:stopAction(self.m_cursorSchedule)
            self.m_cursorSchedule = nil
    end

end

function UIEditBox:onEditBoxChanged(editbox)
    print("editbox event Changed : text =", editbox:getText())
    local str = editbox:getText()  
    self.m_label:setString(str)
    self.m_inputString = str

    local boundBox = self.m_label:getBoundingBox()
    print("PP:lable size::::",boundBox.width,boundBox.height)
    self:getLabelSize()

end

function UIEditBox:updateCursor()
    local str = self.m_inputString
    if self.m_showCursor  then
         str = self.m_inputString.."|"
         self.m_showCursor = false
    else
        self.m_showCursor = true
    end    
    self.m_label:setString(str)
end    

function UIEditBox:setEnable(_isEnable)

end    

function UIEditBox:setText(_text)
    self.m_inputString = _text
    self.m_label:setString(_text)
end    

function UIEditBox:getText()
    return self.m_inputString
end    

-- --事件监听
-- function UIEditBox.onEditBox(event, editbox)
--     print("UIEditBox:onEditBox")
--     print(event)
--     g_utils.showTable(event)
--     print(event.name)
--     if event.name == "began" then
--         -- 开始输入
--         print("editBox event began : text = %s", editbox:getText())
--     elseif event.name == "changed" then
--         -- 输入框内容发生变化
--         print("editBox event began : text = %s", editbox:getText())
--     elseif event == "ended" then
--         -- 输入结束
--         print("editBox event began : text = %s", editbox:getText())
--     elseif event == "return" then
--         -- 从输入框返回
--         print("editBox event began : text = %s", editbox:getText())
--     end
-- end

function UIEditBox:getLabelSize()

    local totalWidth = self.m_label:getContentSize().width
    local totalHeight = self.m_label:getContentSize().height

    local maxWidth = 0
    local maxHeight = 0

    local textArr = self:stringToChar_(self.m_inputString)
  
    local fontName = self.m_label:getSystemFontName()

    local fontSize = self.m_label:getSystemFontSize()

    --从左往右，从上往下拓展
    local curX = 0 --当前x坐标偏移
    
    local curIndexX = 1 --当前横轴index
    local curIndexY = 1 --当前纵轴index

    local tmpHeight = 0
    
    for j, word in ipairs(textArr) do
        print("word::::::",j,word)
        local label = cc.LabelTTF:create(word, fontName, fontSize)
        local rect = label:getBoundingBox()
        local spriteWidth = rect.width
        local spriteHeight = rect.height
         print("word::::::",j,spriteWidth,spriteHeight)
        if tmpHeight<spriteHeight then
            tmpHeight = spriteHeight
        end
        local nexX = curX + spriteWidth
        local pointX
        local rowIndex = curIndexY
        local halfWidth = spriteWidth * 0.5

        if nexX > totalWidth and totalWidth ~= 0 then --超出界限了
            pointX = halfWidth
            if curIndexX == 1 then --当前是第一个，
                curX = 0-- 重置x
            else --不是第一个，当前行已经不足容纳
                rowIndex = curIndexY + 1 --换行
                curX = spriteWidth

                maxHeight = maxHeight + tmpHeight
                tmpHeight = 0
                print("maxHeight:::",maxHeight)
            end
            curIndexX = 1 --x坐标重置
            curIndexY = curIndexY + 1 --y坐标自增
        else
            if maxHeight == 0 then  ----------------------------???????????
                maxHeight = tmpHeight
            end

            pointX = curX + halfWidth --精灵坐标x
            curX = pointX + halfWidth --精灵最右侧坐标
            curIndexX = curIndexX + 1
        end

        if curX > maxWidth then
            maxWidth = curX
        end
    end 

    if tmpHeight>0 then
        maxHeight = maxHeight+tmpHeight
    end

    -- if maxWidth > totalWidth then
    --     totalWidth = maxWidth
    -- end

    -- if maxHeight > totalHeight then
    --     totalHeight = maxHeight
    -- end

    print("totalWidth::::::::",maxWidth,maxHeight)
end

-- 拆分出单个字符
function UIEditBox:stringToChar_(str)
    local list = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end
    return list, len
end

return UIEditBox
