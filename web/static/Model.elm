module Model exposing (..)

import Models.User exposing (User)
import Login.Model exposing (LoginModel)
import Routes exposing (Route)
import Material


type alias Model =
    { mdl : Material.Model
    , token : String
    , user : Maybe User
    , route : Route
    , login : LoginModel
    }
