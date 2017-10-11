

local UILayer = {
    Common = {
        LayerTipError = require("app.game.ui.common.LayerTipError"),
    },
    Main = require("app.game.ui.main.MainUIInit"),
    SecondLevel = {
    	LayerConfirmLogout = require("app.game.ui.SecondLevelLayer.LayerConfirmLogout")
    },
    RoomScene = {
    	LayerChat = require("app.game.ui.RoomSceneLayer.LayerChat")
    },
    GameSpriteUtil = require("app.game.ui.UIUtils.GameSpriteUtil"),
    Club = {
        ClubMain = require("app.game.ui.Club.ClubMain"),
        ItemClubMain = require("app.game.ui.Club.Cell.ItemCellClubMain"),
        ClubInfo = require("app.game.ui.Club.ClubInfo"),
        ClubHelp = require("app.game.ui.Club.ClubHelp"),

    },

}
return UILayer