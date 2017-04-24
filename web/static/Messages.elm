module Messages exposing (..)

import Http
import Material
import Routes exposing (Route)
import Login.Messages exposing (LoginMsg)
import Signup.Messages exposing (SignupMsg)
import Game.Messages exposing (GameMsg)
import Phoenix.Socket


type Msg
    = Mdl (Material.Msg Msg)
    | SelectTab Int
    | ErrorPage
    | ChangePage Route
    | Login LoginMsg
    | Signup SignupMsg
    | Game GameMsg
    | LogoutRequest
    | LogoutResponse (Result Http.Error String)
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | NoOp
