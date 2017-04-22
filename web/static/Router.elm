module Router exposing (parseUrl, delta2url)

import Model exposing (Model)
import Navigation exposing (Location)
import UrlParser exposing (..)
import RouteUrl exposing (UrlChange)
import RouteUrl.Builder exposing (newEntry, toUrlChange, builder, Builder, replacePath)
import Messages exposing (Msg(..))
import Routes exposing (Route(..))


parseUrl : Location -> List Msg
parseUrl location =
    case UrlParser.parsePath route location of
        Nothing ->
            [ ErrorPage ]

        Just route ->
            [ ChangePage route ]


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    Maybe.map toUrlChange <|
        (builder
            |> newEntry
            |> replacePath [ routeToString current.route ]
            |> Just
        )


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home (s "")
        , map Routes.Login (s "login")
        , map Routes.Signup (s "signup")
        , map Routes.Games (s "games")
        ]


routeToString : Route -> String
routeToString route =
    case route of
        Routes.Login ->
            "login"

        Routes.Signup ->
            "signup"

        Routes.Games ->
            "games"

        Home ->
            ""

        _ ->
            ""
