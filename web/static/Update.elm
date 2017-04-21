module Update exposing (update)

import Http
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routes exposing (Route(..))
import Material
import Login.Update as LoginUpdate
import Signup.Update as SignupUpdate
import Phoenix.Socket


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

        Mdl msg_ ->
            Material.update Mdl msg_ model

        ErrorPage ->
            { model | route = NotFound } ! []

        ChangePage route ->
            { model | route = route } ! []

        Messages.Login loginMsg ->
            LoginUpdate.update loginMsg model

        Messages.Signup signupMsg ->
            SignupUpdate.update signupMsg model

        LogoutResponse (Ok response) ->
            { model | token = "", user = Nothing, route = Routes.Login } ! []

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
