--[[
    UIInputBox
    用法示例
        local config={
        layer=self.m_ccbRoot.m_layerEditBox,
        fontSize=20,
        image="img_pos.png",
        maxLength=140,

    }
    self.m_UIInputBox=require("lib.ui.UIInputBox").new(config)
    self.m_ccbRoot.m_spriteEditBox:addChild(self.m_UIInputBox)
]]

local UIInputBox = class("UIInputBox", function()
    local node=display.newNode()
    return node
end)
--配置
function UIInputBox:ctor(_cfg)
    self:initData(_cfg)
    self:initUI()
end
function UIInputBox:initData(_cfg)
    self.m_cfg          = _cfg
    self.m_layer        = _cfg.layer
    self.m_image        = _cfg.image
    self.m_fontSize     = _cfg.fontSize
    self.m_color        = _cfg.color or cc.c3b(255,255,255)
    self.m_maxLength    = _cfg.maxLength
    self.m_text         = _cfg.text or ""
    self.m_defaultText  = _cfg.defaultText or nil
    self.m_keyBord      = _cfg.keyBord or cc.KEYBOARD_RETURNTYPE_DONE
    self.m_inputMode    = _cfg.inputMode or cc.EDITBOX_INPUT_MODE_ANY
    self.m_fontName     = _cfg.fontName or "Arial"
    self.m_defaultLabel = _cfg.defaultLabel or nil
    self.m_listener     = _cfg.listener or nil
    self.m_layerSize    = self.m_layer:getContentSize()
end

function UIInputBox:initUI()
    local tempsize=self.m_layerSize
    local width  = tempsize.width
    local height = tempsize.height
    local size   = cc.size(width*5, height*2)
    local posX   = self.m_layer:getPositionX()-width*4
    local posY   = self.m_layer:getPositionY()-height
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
    self.m_edb:setFontColor(self.m_color)
    self.m_edb:setInputMode(self.m_inputMode)
    self.m_edb:setMaxLength(self.m_maxLength)
    --self.m_edb:setInputFlag(0)
    --self.m_edb:setFontSize(0)
    self.m_edb:setFont(self.m_fontName, 0)
    self.m_edb:setReturnType(self.m_keyBord)
    self.m_edb:setText(self.m_text)
    self.m_edb:addTo(self)

    -- initLabel
    self.m_label = require("app.common.ui.UIRichLabel").new({
            fontName = self.m_fontName,
            fontSize = self.m_fontSize,
            fontColor = self.m_color,
            dimensions = cc.size(tempsize.width, tempsize.height),
            text = self.m_text,
            showCursor = true
        })
    self.m_label:setDimensions(0)
    self.m_label:addTo(self.m_layer)
    self.m_label:setPosition(cc.p(0, tempsize.height))

    self:updateDefaultText()
end

function UIInputBox:updateDefaultText()
    if self.m_text == nil  or string.len(self.m_text) == 0 then
        if self.m_defaultLabel then
            self.m_defaultLabel:setVisible(true)
        end
        if self.m_defaultText then
            self.m_label:setLabelString(self.m_defaultText, "1")
            return true
        end
    else
        if self.m_defaultText and self.m_defaultText==self.m_text then
            self.m_label:setLabelString(self.m_defaultText, "2")
            self.m_text = ""
            return true
        end
    end

    return false
end

--当输入框开始输入时的回调
function UIInputBox:onEditBoxBegan(editbox)
    print("editbox event began : text = %s", editbox:getText())
    editbox:setText(self.m_text)
    self.m_label:setLabelString(self.m_text, "3")
    self.m_label:startCursor()
    if self.m_defaultLabel then
        self.m_defaultLabel:setVisible(false)
    end
end

--当输入框结束输入的回调
function UIInputBox:onEditBoxEnded(editbox)
    print("editbox event Ended : text = %s", editbox:getText())
end

 --当键盘消失时的回调
function UIInputBox:onEditBoxReturn(editbox)
    print("editbox event Return : text = %s", editbox:getText())
    local str = editbox:getText()
    editbox:setText("")

    self.m_text = str

    if not self:updateDefaultText() then
        self.m_label:setLabelString(self.m_text, "4")
    end
    self.m_label:endCursor()

    g_msg:post(g_msgcmd.DB_EDITBOX_RETURN)
end

--当输入框字符有变化的是的回调接口
function UIInputBox:onEditBoxChanged(editbox)
    print("editbox event Changed : text =", editbox:getText())
    local str = editbox:getText()
    self.m_label:setLabelString(str, "5")


    --如果越界了就重置字符
    local labelSize = self.m_label:getLabelSize()

    if labelSize.width > self.m_layerSize.width or labelSize.height > self.m_layerSize.height then

        str = self.m_text
        self.m_label:setLabelString(str, "6")
    end

    self.m_text = str
    editbox:setText(self.m_text)

end

--是否使用input功能，如果设置为false后，不能在设置再设置回来能input状态
function UIInputBox:setEnable(_isEnable)
    if _isEnable == false then
         self.m_edb:removeFromParent()
    end
end

--设置显示默认的文本
function UIInputBox:setDefaultText(_text)
    self.m_defaultText = _text
    self:setText(self.m_inputString)
end

--设置输入框的文本
function UIInputBox:setText(_text)
    if _text==nil then
        return
    end

    if string.len(_text) == 0 then
        return
    end

    self.m_label:setLabelString(_text, "7")

    local labelSize = self.m_label:getLabelSize()
    if labelSize.width > self.m_layerSize.width or labelSize.height > self.m_layerSize.height then

        _text = self.m_text
        self.m_label:setLabelString(_text, "8")
    end

    self.m_text = _text
end

--得到输入框中的文本字符串
function UIInputBox:getText()
    return self.m_text
end

return UIInputBox
