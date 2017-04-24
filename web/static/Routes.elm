module Routes exposing (..)


type Route
    = Home
    | Login
    | Signup
    | Games GameRoute
    | NotFound


type GameRoute
    = GameList
    | NewGame
