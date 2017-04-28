module Main exposing (..)

import Model exposing (Model)
import Models.User exposing (User)
import RouteUrl exposing (RouteUrlProgram, UrlChange)
import Router exposing (parseUrl, delta2url)
import Material
import Material.Menu as Menu
import Messages exposing (Msg(..))
import Update exposing (update)
import Routes exposing (Route(..))
import View exposing (view)
import Login.Model as LoginModel
import Signup.Model as SignupModel
import Game.Update as GameUpdate
import Game.Model as GameModel
import Phoenix.Socket
import Socket exposing (initSocket)


main : RouteUrlProgram Flags Model Msg
main =
    RouteUrl.programWithFlags
        { delta2url = delta2url
        , location2messages = parseUrl
        , init = init
        , view = view
        , subscriptions = subscriptions
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
        , phxSocket = initSocket flags.token
        , channels = []
        , selectedTab = Nothing
        , games = GameModel.model
        }
            |> GameUpdate.joinGamesChannel


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        phxSocketSub =
            phoenixSub model
    in
        Sub.batch [ phxSocketSub, Menu.subs Mdl model.mdl ]


phoenixSub : Model -> Sub Msg
phoenixSub model =
    case model.phxSocket of
        Nothing ->
            Sub.none

        Just socket ->
            Phoenix.Socket.listen socket PhoenixMsg
