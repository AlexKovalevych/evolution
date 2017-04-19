module Messages exposing (..)

import Http
import Material
import Routes exposing (Route)
import Login.Messages exposing (LoginMsg)
import Signup.Messages exposing (SignupMsg)


type Msg
    = Mdl (Material.Msg Msg)
    | ErrorPage
    | ChangePage Route
    | Login LoginMsg
    | Signup SignupMsg
    | LogoutRequest
    | LogoutResponse (Result Http.Error String)
    | NoOp
