module Messages exposing (..)

import Material
import Routes exposing (Route)
import Login.Messages exposing (LoginMsg)


type Msg
    = Mdl (Material.Msg Msg)
    | ErrorPage
    | ChangePage Route
    | Login LoginMsg
    | NoOp
