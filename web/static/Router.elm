module Router exposing (parseUrl, delta2url)

import Model exposing (Model)
import Navigation exposing (Location)
import RouteParser exposing (..)
import RouteParser.QueryString as QueryString
import RouteUrl exposing (UrlChange)
import RouteUrl.Builder exposing (newEntry, toUrlChange, builder, Builder, replacePath, replaceQuery)
import Messages exposing (Msg(..))
import Game.Messages exposing (GameMsg(..))
import Routes exposing (Route(..), GameRoute(..))
import Dict
import String


parseUrl : Location -> List Msg
parseUrl location =
    case match matchers location.pathname of
        Nothing ->
            [ ErrorPage ]

        Just route ->
            case route of
                Home ->
                    let
                        params =
                            QueryString.parse location.search

                        page =
                            case Dict.get "page" params of
                                Nothing ->
                                    1

                                Just values ->
                                    case List.head (values) of
                                        Nothing ->
                                            1

                                        Just page ->
                                            case String.toInt page of
                                                Ok value ->
                                                    value

                                                Err _ ->
                                                    1
                    in
                        [ ChangePage route, Game <| SetPage False page ]

                _ ->
                    [ ChangePage route ]


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    Maybe.map toUrlChange <|
        (builder
            |> newEntry
            |> replacePath (routeToString current.route)
            |> replaceQuery (routeToQuery current)
            |> Just
        )


matchers : List (Matcher Route)
matchers =
    [ static Home "/"
    , static Routes.Login "/login"
    , static Routes.Signup "/signup"
    , static (Routes.Games Routes.GameList) "/games"
    , static (Routes.Games Routes.NewGame) "/games/new"
    , dyn1 (Routes.Games << Routes.ViewGame) "/games/view" int ""
    ]


routeToQuery : Model -> Dict.Dict String String
routeToQuery model =
    case model.route of
        Home ->
            Dict.fromList [ ( "page", toString (model.games.page) ) ]

        _ ->
            Dict.empty


routeToString : Route -> List String
routeToString route =
    case route of
        Routes.Login ->
            [ "login" ]

        Routes.Signup ->
            [ "signup" ]

        Routes.Games gameRoute ->
            let
                prefix =
                    [ "games" ]
            in
                case gameRoute of
                    Routes.GameList ->
                        prefix

                    Routes.NewGame ->
                        prefix ++ [ "new" ]

                    Routes.ViewGame id ->
                        prefix ++ [ "view", toString id ]

        _ ->
            [ "" ]
