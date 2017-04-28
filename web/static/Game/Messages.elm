module Game.Messages exposing (..)

import Json.Encode as JE


type GameMsg
    = SetPlayers Int
    | CreateGame
    | SetPage Int
    | LoadGames JE.Value
