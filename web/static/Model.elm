module Model exposing (..)

import Models.User exposing (User)
import Material


type alias Model =
    { mdl : Material.Model
    , token : Maybe String
    , user : Maybe User
    , route : String
    }
