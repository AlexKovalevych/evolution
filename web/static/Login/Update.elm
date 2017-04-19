module Login.Update exposing (..)

import Http
import Login.Messages exposing (LoginMsg(..))
import Login.Model exposing (LoginModel)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Models.User exposing (User, userDecoder)
import Json.Decode as D
import Routes exposing (Route(..))
import Dict


update : LoginMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        loginModel =
            model.login
    in
        case msg of
            SetLogin value ->
                { model | login = { loginModel | login = value } } ! []

            SetPassword value ->
                { model | login = { loginModel | password = value } } ! []

            LoginRequest ->
                let
                    body =
                        Login.Model.encoder loginModel |> Http.jsonBody

                    request =
                        Http.request
                            { method = "POST"
                            , headers = [ Http.header "x-csrf-token" model.csrf ]
                            , url = "/login"
                            , body = body
                            , expect = Http.expectString
                            , timeout = Nothing
                            , withCredentials = False
                            }
                in
                    model
                        ! [ Http.send (\v -> Messages.Login <| LoginResponse v) request ]

            LoginResponse (Ok response) ->
                case D.decodeString (D.at [ "errors" ] (D.dict D.string)) response of
                    Err _ ->
                        case D.decodeString successDecoder response of
                            Err _ ->
                                model ! []

                            Ok successLogin ->
                                { model
                                    | token = successLogin.token
                                    , user = Just successLogin.user
                                    , route = Home
                                    , login = { loginModel | errors = Dict.empty }
                                }
                                    ! []

                    Ok errors ->
                        { model | login = { loginModel | errors = errors } } ! []

            LoginResponse (Err reason) ->
                model ! []


type alias SuccessLogin =
    { token : String, user : User }


successDecoder : D.Decoder SuccessLogin
successDecoder =
    D.map2 SuccessLogin
        (D.field "token" D.string)
        (D.field "user" userDecoder)
