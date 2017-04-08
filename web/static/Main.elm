module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Models.User exposing (User)
import RouteUrl exposing (RouteUrlProgram, UrlChange, Builder)
import Router exposing (parseUrl, delta2url)
import Navigation exposing (Location)
import Material
import Material.Scheme
import Material.Layout as Layout
import Material.Button as Button
import Material.Options as Options exposing (css)


main : RouteUrlProgram Never Model Action
main =
    RouteUrl.program
        { delta2url = delta2url
        , location2messages = parsePath
        , init = ( model, Cmd.none )
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }



--url2messages : Location -> List Action
--url2messages location =
-- You can parse the `Location` in whatever way you want. I'm making
-- a `Builder` and working from that, but I'm sure that's not the
-- best way. There are links to a number of proper parsing packages
-- in the README.
--builder2messages (Builder.fromUrl location.href)
--builder2messages : Builder -> List Action
--builder2messages builder =
-- You can parse the `Location` in whatever way you want ... there are a
-- number of parsing packages listed in the README. Here, I'm constructing
-- a `Builder` and working from that, but that's probably not the best
-- thing to do.
-- MODEL


type alias Model =
    { mdl : Material.Model
    , token : Maybe String
    , user : Maybe User
    }


model : Model
model =
    { mdl = Material.model
    , token = Nothing
    , user = Nothing
    }



-- ACTION, UPDATE


type Msg
    = Mdl (Material.Msg Msg)



-- Boilerplate: Msg clause for internal Mdl messages.


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Boilerplate: Mdl action handler.
        Mdl msg_ ->
            Material.update Mdl msg_ model



-- VIEW


type alias Mdl =
    Material.Model


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
