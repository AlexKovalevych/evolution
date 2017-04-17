module Model exposing (..)

import Models.User exposing (User)
import Login.Model exposing (LoginModel)
import Signup.Model exposing (SignupModel)
import Routes exposing (Route)
import Material


type alias Model =
    { mdl : Material.Model
    , token : String
    , csrf : String
    , user : Maybe User
    , route : Route
    , login : LoginModel
    , signup : SignupModel
    }
