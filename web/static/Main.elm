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
import Phoenix.Socket


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
    , csrf : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        route =
            Routes.Login
    in
        { token = flags.token
        , csrf = flags.csrf
        , user = flags.user
        , mdl = Material.model
        , route = route
        , login = LoginModel.model
        , signup = SignupModel.model
        , phxSocket = Nothing
        }
            ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.phxSocket of
        Nothing ->
            Sub.none

        Just socket ->
            Phoenix.Socket.listen socket PhoenixMsg
