
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    ui.newTTFLabel({text = "请输入版本号:", size = 32, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx-200, display.cy+100)
        :addTo(self)

    self.versionEdit   = CCEditBox:create( CCSize( 250, 60 ), CCScale9Sprite:create( "log_blank.png" ), CCScale9Sprite:create( "log_blank_sel.png" ) )
    self.versionEdit:setReturnType( kKeyboardReturnTypeDone )
    self.versionEdit:setInputFlag( kEditBoxInputFlagSensitive )
    self.versionEdit:setText( ver )
    self.versionEdit:setFontColor(ccc3(255,255,255))
    self.versionEdit:addTo( self )
    self.versionEdit:setPosition( ccp( display.cx+60, display.cy+100 ) )
    self.versionEdit:setFontSize(15)

    -- 工程名字
    ui.newTTFLabel({text = "请输入工程名字:", size = 32, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx-200, display.cy)
        :addTo(self)

    self.worknameEdit   = CCEditBox:create( CCSize( 250, 60 ), CCScale9Sprite:create( "log_blank.png" ), CCScale9Sprite:create( "log_blank_sel.png" ) )
    self.worknameEdit:setReturnType( kKeyboardReturnTypeDone )
    self.worknameEdit:setInputFlag( kEditBoxInputFlagSensitive )
    self.worknameEdit:setText( project_name )
    self.worknameEdit:setFontColor(ccc3(255,255,255))
    self.worknameEdit:addTo( self )
    self.worknameEdit:setPosition( ccp( display.cx+60, display.cy ) )
    self.worknameEdit:setFontSize(15)

    self.surButton = cc.ui.UIPushButton.new({normal="buttonon.png",pressed="buttonoff.png"}, {scale9 = true})
        :setButtonLabel(cc.ui.UILabel.new({text = "确定", size = 15, color = ccc3(255,0,255)}))
        :setButtonSize( 70, 30 )
        :onButtonClicked(function()
            print("AAAA")
           self:startWork()
        end)
        :pos(display.cx, display.cy-100)
        :addTo(self)
end

function MainScene:startWork()
    print( "projects = AAAAA")
    project_name = self.worknameEdit:getText()
    ver          = self.versionEdit:getText()

    print( "projects = ", project_name )
    print( "ver = ", ver )

    genEnv(ver,project_name)

    mk = require("mkflist")
    mk:run("files")
end

function MainScene:onEnter()
    if device.platform == "android" then
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(function(event)
                if event == "back" then app.exit() end
            end)
            self:addChild(layer)

            layer:setKeypadEnabled(true)
        end, 0.5)
    end
end

function MainScene:onExit()
end

return MainScene
