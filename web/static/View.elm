module View exposing (..)

import Html exposing (..)
import Material.Layout as Layout
import Model exposing (Model)
import Messages exposing (Msg(..))
import Material.Options as Options exposing (css)
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
        Login ->
            LoginView.view model

        Home ->
            HomeView.view model

        Signup ->
            SignupView.view model

        NotFound ->
            NotFoundView.view model


header : Model -> List (Html Msg)
header model =
    [ Layout.row
        [ css "transition" "height 333ms ease-in-out 0s"
        ]
        [ Layout.title [] [ text "Evolution" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link
                [ Layout.href "https://github.com/debois/elm-mdl" ]
                [ span [] [ text "github" ] ]
            , Layout.link
                [ Layout.href "http://package.elm-lang.org/packages/debois/elm-mdl/latest/" ]
                [ text "elm-package" ]
            ]
        ]
    ]
