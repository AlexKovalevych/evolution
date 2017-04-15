module Main exposing (..)

import Model exposing (Model)
import Models.User exposing (User)
import RouteUrl exposing (RouteUrlProgram, UrlChange)
import Router exposing (parseUrl, delta2url)
import Material
import Messages exposing (Msg(..))
import Update exposing (update)
import Routes exposing (Route(..))
import View exposing (view)
import Login.Model as LoginModel
import Signup.Model as SignupModel


main : RouteUrlProgram Flags Model Msg
main =
    RouteUrl.programWithFlags
        { delta2url = delta2url
        , location2messages = parseUrl
        , init = init
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }


type alias Flags =
    { user : Maybe User
    , token : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        route =
            Routes.Login
    in
        { token = flags.token
        , user = flags.user
        , mdl = Material.model
        , route = route
        , login = LoginModel.model
        , signup = SignupModel.model
        }
            ! []
