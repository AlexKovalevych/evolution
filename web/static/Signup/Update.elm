module Signup.Update exposing (..)

import Http
import Signup.Messages exposing (SignupMsg(..))
import Signup.Model
import Model exposing (Model)
import Messages exposing (Msg(..))


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
                            , url = "/signup"
                            , body = body
                            , expect = Http.expectString
                            , timeout = Nothing
                            , withCredentials = False
                            }
                in
                    model
                        ! [ Http.send (\v -> Signup <| SignupResponse v) request ]

            SignupResponse (Ok response) ->
                model ! []

            SignupResponse (Err reason) ->
                model ! []
