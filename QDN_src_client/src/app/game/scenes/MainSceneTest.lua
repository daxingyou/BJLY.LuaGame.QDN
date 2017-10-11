
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    local items = {
        "测试socket",
    }

    self:addChild(game.createMenu(items, handler(self, self.openTest)))
end

function MainScene:openTest(name)
    local Scene = require("app.scenes.socketTcpTest")
    display.replaceScene(Scene.new())
end

function MainScene:onEnter()
end

return MainScene
