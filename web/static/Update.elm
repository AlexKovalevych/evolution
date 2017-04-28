port module Update exposing (update)

import Http
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routes exposing (Route(..), GameRoute(..))
import Material
import Login.Update as LoginUpdate
import Signup.Update as SignupUpdate
import Game.Update as GameUpdate
import Phoenix.Socket
import Tabs exposing (..)
import Channel exposing (Channel(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            case model.phxSocket of
                Nothing ->
                    model ! []

                Just socket ->
                    let
                        ( phxSocket, phxCmd ) =
                            Phoenix.Socket.update msg socket
                    in
                        ( { model | phxSocket = Just phxSocket }
                        , Cmd.map PhoenixMsg phxCmd
                        )

        JoinChannel channel ->
            let
                _ =
                    Debug.log "joined" channel

                newModel =
                    { model | channels = channel :: model.channels }
            in
                case channel of
                    GamesChannel ->
                        case model.route of
                            Home ->
                                GameUpdate.loadGames newModel

                            Games GameList ->
                                GameUpdate.searchGames newModel

                            _ ->
                                model ! []

        Mdl msg_ ->
            Material.update Mdl msg_ model

        SelectTab k ->
            case tabToRoute k of
                Nothing ->
                    model ! []

                Just route ->
                    { model | selectedTab = Just k, route = route } ! []

        ErrorPage ->
            { model | route = NotFound } ! []

        ChangePage route ->
            let
                _ =
                    Debug.log "change route" route

                newModel =
                    { model | route = route, selectedTab = routeToTab route }
            in
                case route of
                    Home ->
                        GameUpdate.loadGames newModel

                    Games GameList ->
                        GameUpdate.searchGames newModel

                    _ ->
                        newModel ! []

        Messages.Login loginMsg ->
            LoginUpdate.update loginMsg model

        Messages.Signup signupMsg ->
            SignupUpdate.update signupMsg model

        Messages.Game gameMsg ->
            GameUpdate.update gameMsg model

        LogoutResponse (Ok response) ->
            { model
                | token = ""
                , user = Nothing
                , route = Routes.Login
            }
                ! [ reload True ]

        LogoutResponse (Err _) ->
            model ! []

        LogoutRequest ->
            let
                request =
                    Http.request
                        { method = "DELETE"
                        , headers = [ Http.header "x-csrf-token" model.csrf ]
                        , url = "/logout"
                        , body = Http.emptyBody
                        , expect = Http.expectString
                        , timeout = Nothing
                        , withCredentials = False
                        }
            in
                model
                    ! [ Http.send LogoutResponse request ]

        NoOp ->
            model ! []


port reload : Bool -> Cmd msg
