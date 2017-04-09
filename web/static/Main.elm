module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Model exposing (Model)
import Models.User exposing (User)
import RouteUrl exposing (RouteUrlProgram, UrlChange)
import Router exposing (parseUrl, parsePath, delta2url)
import Navigation exposing (Location)
import Material
import Material.Scheme
import Material.Layout as Layout
import Material.Button as Button
import Material.Options as Options exposing (css)
import Messages exposing (Msg(..))
import Update exposing (update)
import Routes exposing (Route(..))


main : RouteUrlProgram Flags Model Msg
main =
    RouteUrl.programWithFlags
        { delta2url = delta2url
        , location2messages = parseUrl
        , init = init
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }


type alias Flags =
    { user : Maybe User
    , token : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        route =
            Login
    in
        { token = flags.token
        , user = flags.user
        , mdl = Material.model
        , route = route
        }
            ! []



-- VIEW


view : Model -> Html Msg
view model =
    Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader
        ]
        { header = header model
        , drawer = []
        , tabs = ( [], [] )
        , main = []
        }


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
