module Model exposing (..)

import Models.User exposing (User)
import Login.Model exposing (LoginModel)
import Signup.Model exposing (SignupModel)
import Messages exposing (Msg)
import Routes exposing (Route)
import Material
import Phoenix.Socket


type alias Model =
    { mdl : Material.Model
    , token : String
    , csrf : String
    , user : Maybe User
    , route : Route
    , login : LoginModel
    , signup : SignupModel
    , phxSocket : Maybe (Phoenix.Socket.Socket Msg)
    , selectedTab : Maybe Int
    }
