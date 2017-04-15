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


view : Model -> Html Msg
view model =
    Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader
        ]
        { header = header model
        , drawer = []
        , tabs = ( [], [] )
        , main = [ view_ model ]
        }


view_ : Model -> Html Msg
view_ model =
    case model.route of
        Routes.Login ->
            LoginView.view model

        Home ->
            HomeView.view model

        Routes.Signup ->
            SignupView.view model

        NotFound ->
            NotFoundView.view model


header : Model -> List (Html Msg)
header model =
    let
        isLoggedIn =
            if model.user == Nothing then
                False
            else
                True
    in
        [ Layout.row
            [ css "transition" "height 333ms ease-in-out 0s"
            ]
            [ Layout.title [] [ text "Evolution" ]
            , Layout.spacer
            , Layout.navigation []
                [ Layout.link
                    [ cs "hide" |> when isLoggedIn
                    , Options.onClick <| ChangePage Routes.Signup
                    ]
                    [ span [] [ text "Signup" ] ]
                , Layout.link
                    [ Options.onClick <| ChangePage Routes.Login
                    ]
                    [ span [] [ text "Login" ] ]
                ]
            ]
        ]
