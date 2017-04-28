module Game.Messages exposing (..)

import Json.Encode as JE


type GameMsg
    = SetPlayers Int
    | CreateGame
    | SetPage Bool Int
    | ReloadPage
    | LoadGames JE.Value
    | SearchGames
