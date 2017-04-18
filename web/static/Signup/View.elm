module Signup.View exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Html.Attributes exposing (style)
import Html.Events exposing (onSubmit)
import Messages exposing (Msg(..))
import Signup.Messages exposing (SignupMsg(..))
import Material.Textfield as Textfield
import Material.Button as Button
import Material.Grid exposing (grid, Device(..), size, cell, offset)
import Material.Options as Options
import Dict


view : Model.Model -> Html Msg
view model =
    grid []
        [ cell
            [ offset Tablet 3
            , offset Desktop 4
            , size Tablet 6
            , size Desktop 4
            , size Phone 12
            ]
            [ form [ onSubmit <| Signup SignupRequest ]
                [ div []
                    [ Textfield.render Mdl
                        [ 0 ]
                        model.mdl
                        [ Textfield.label "Login"
                        , Textfield.floatingLabel
                        , Textfield.value model.signup.login
                        , Textfield.text_
                        , Options.css "width" "100%"
                        , Options.onInput <| (\value -> Signup <| SetLogin value)
                        , Textfield.error (getError model.signup.errors "login")
                            |> Options.when (Dict.member "login" model.signup.errors)
                        ]
                        []
                    ]
                , div []
                    [ Textfield.render Mdl
                        [ 1 ]
                        model.mdl
                        [ Textfield.label "Password"
                        , Textfield.floatingLabel
                        , Textfield.password
                        , Textfield.value model.signup.password
                        , Options.css "width" "100%"
                        , Options.onInput <| (\value -> Signup <| SetPassword value)
                        , Textfield.error (getError model.signup.errors "password")
                            |> Options.when (Dict.member "password" model.signup.errors)
                        ]
                        []
                    ]
                , div []
                    [ Textfield.render Mdl
                        [ 2 ]
                        model.mdl
                        [ Textfield.label "Confirm Password"
                        , Textfield.floatingLabel
                        , Textfield.password
                        , Textfield.value model.signup.confirmPassword
                        , Options.css "width" "100%"
                        , Options.onInput <| (\value -> Signup <| SetConfirmPassword value)
                        , Textfield.error (getError model.signup.errors "password_confirmation")
                            |> Options.when (Dict.member "password_confirmation" model.signup.errors)
                        ]
                        []
                    ]
                , div [ style [ ( "text-align", "center" ) ] ]
                    [ Button.render Mdl
                        [ 3 ]
                        model.mdl
                        [ Button.raised
                        , Button.colored
                        ]
                        [ text "Signup" ]
                    ]
                ]
            ]
        ]


getError : Dict.Dict String String -> String -> String
getError errors field =
    case Dict.get field errors of
        Nothing ->
            ""

        Just value ->
            value
