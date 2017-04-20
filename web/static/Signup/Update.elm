module Signup.Update exposing (..)

import Http
import Signup.Messages exposing (SignupMsg(..))
import Signup.Model
import Model exposing (Model)
import Messages exposing (Msg(..))
import Json.Decode as D
import Models.User exposing (User, userDecoder)
import Routes exposing (Route(..))
import Dict


update : SignupMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        signupModel =
            model.signup
    in
        case msg of
            SetLogin value ->
                { model | signup = { signupModel | login = value } } ! []

            SetPassword value ->
                { model | signup = { signupModel | password = value } } ! []

            SetConfirmPassword value ->
                { model | signup = { signupModel | confirmPassword = value } } ! []

            SignupRequest ->
                let
                    body =
                        Signup.Model.encoder signupModel |> Http.jsonBody

                    request =
                        Http.request
                            { method = "POST"
                            , headers = [ Http.header "x-csrf-token" model.csrf ]
                            , url = "/auth/identity/callback"
                            , body = body
                            , expect = Http.expectString
                            , timeout = Nothing
                            , withCredentials = False
                            }
                in
                    model
                        ! [ Http.send (\v -> Messages.Signup <| SignupResponse v) request ]

            SignupResponse (Ok response) ->
                case D.decodeString (D.at [ "errors" ] (D.dict D.string)) response of
                    Err _ ->
                        case D.decodeString successDecoder response of
                            Err _ ->
                                model ! []

                            Ok successSignup ->
                                { model
                                    | token = successSignup.token
                                    , user = Just successSignup.user
                                    , route = Home
                                    , signup = { signupModel | errors = Dict.empty }
                                }
                                    ! []

                    Ok errors ->
                        { model | signup = { signupModel | errors = errors } } ! []

            SignupResponse (Err reason) ->
                model ! []


type alias SuccessSignup =
    { token : String, user : User }


successDecoder : D.Decoder SuccessSignup
successDecoder =
    D.map2 SuccessSignup
        (D.field "token" D.string)
        (D.field "user" userDecoder)
