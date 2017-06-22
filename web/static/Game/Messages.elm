module Game.Messages exposing (..)

import Json.Encode as JE


type GameMsg
    = SetPlayers Int
    | SetSearchPlayers Int
    | SetSearchPlayer String
    | CreateGame
    | SetPage Bool Int
    | ReloadPage
    | LoadGames JE.Value
    | LoadGame JE.Value
    | SearchGames
    | FoundGames JE.Value
