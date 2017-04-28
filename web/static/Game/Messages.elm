module Game.Messages exposing (..)

import Json.Encode as JE


type GameMsg
    = SetPlayers Int
    | CreateGame
    | LoadGames JE.Value
