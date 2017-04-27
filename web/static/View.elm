module View exposing (..)

import Html exposing (..)
import Material.Layout as Layout
import Model exposing (Model)
import Messages exposing (Msg(..))
import Material.Options as Options exposing (css, cs, when)
import Routes exposing (Route(..))
import Login.View as LoginView
import Home.View as HomeView
import Signup.View as SignupView
import NotFound.View as NotFoundView
import Game.View as GameView
import Material.Color as Color


view : Model -> Html Msg
view model =
    let
        properties =
            [ Layout.fixedHeader
            , Layout.onSelectTab SelectTab
            ]
                ++ (selectTabProperty model)
    in
        Layout.render Mdl
            model.mdl
            properties
            { header = header model
            , drawer = []
            , tabs =
                ( tabs model
                , [ Color.background (Color.color Color.Teal Color.S400) ]
                )
            , main = [ view_ model ]
            }


view_ : Model -> Html Msg
view_ model =
    case model.route of
        Routes.Login ->
            LoginView.view model

        Home ->
            HomeView.view model

        Games _ ->
            GameView.view model

        Routes.Signup ->
            SignupView.view model

        NotFound ->
            NotFoundView.view model


header : Model -> List (Html Msg)
header model =
    let
        loggedIn =
            isLoggedIn model
    in
        [ Layout.row
            [ css "transition" "height 333ms ease-in-out 0s"
            ]
            [ Layout.title [] [ text "Эволюция" ]
            , Layout.spacer
            , Layout.navigation []
                [ Layout.link
                    [ cs "hidden" |> when loggedIn
                    , Options.onClick <| ChangePage Routes.Signup
                    ]
                    [ span [] [ text "Регистрация" ] ]
                , Layout.link
                    [ cs "hidden" |> when loggedIn
                    , Options.onClick <| ChangePage Routes.Login
                    ]
                    [ span [] [ text "Вход" ] ]
                , Layout.link
                    [ cs "hidden" |> when (not loggedIn)
                    , Options.onClick <| LogoutRequest
                    ]
                    [ span [] [ text "Выход" ] ]
                ]
            ]
        ]


isLoggedIn : Model -> Bool
isLoggedIn model =
    if model.user == Nothing then
        False
    else
        True


tabs : Model -> List (Html Msg)
tabs model =
    if isLoggedIn model then
        [ div [] [ text "Мои игры" ]
        , div [] [ text "Найти игру" ]
        ]
    else
        []


selectTabProperty : Model -> List (Layout.Property Msg)
selectTabProperty model =
    case model.selectedTab of
        Nothing ->
            []

        Just tab ->
            [ Layout.selectedTab tab ]
