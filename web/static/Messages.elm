module Messages exposing (..)

import Material
import Routes exposing (Route)


type Msg
    = Mdl (Material.Msg Msg)
    | ErrorPage
    | ChangePage Route
    | NoOp
