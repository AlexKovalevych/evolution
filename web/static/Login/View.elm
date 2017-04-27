module Login.View exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Html.Attributes exposing (style)
import Html.Events exposing (onSubmit)
import Messages exposing (Msg(..))
import Login.Messages exposing (LoginMsg(..))
import Material.Textfield as Textfield
import Material.Button as Button
import Material.Grid exposing (grid, Device(..), size, cell, offset)
import Material.Options as Options
import Dict


view : Model.Model -> Html Messages.Msg
view model =
    grid []
        [ cell
            [ offset Tablet 3
            , offset Desktop 4
            , size Tablet 6
            , size Desktop 4
            , size Phone 12
            ]
            [ form [ onSubmit <| Login LoginRequest ]
                [ div []
                    [ Textfield.render Mdl
                        [ 0 ]
                        model.mdl
                        [ Textfield.label "Логин"
                        , Textfield.floatingLabel
                        , Textfield.value model.login.login
                        , Textfield.text_
                        , Options.css "width" "100%"
                        , Options.onInput <| (\value -> Login <| SetLogin value)
                        , Textfield.error (getError model.login.errors "login")
                            |> Options.when (Dict.member "login" model.login.errors)
                        ]
                        []
                    ]
                , div []
                    [ Textfield.render Mdl
                        [ 1 ]
                        model.mdl
                        [ Textfield.label "Пароль"
                        , Textfield.floatingLabel
                        , Textfield.password
                        , Textfield.value model.login.password
                        , Options.css "width" "100%"
                        , Options.onInput <| (\value -> Login <| SetPassword value)
                        , Textfield.error (getError model.login.errors "password")
                            |> Options.when (Dict.member "password" model.login.errors)
                        ]
                        []
                    ]
                , div [ style [ ( "text-align", "center" ) ] ]
                    [ Button.render Mdl
                        [ 2 ]
                        model.mdl
                        [ Button.raised
                        , Button.colored
                        ]
                        [ text "Вход" ]
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
