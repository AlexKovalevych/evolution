module Router exposing (parseUrl, parsePath, delta2url)

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


parsePath : Location -> Route
parsePath location =
    case UrlParser.parsePath route location of
        Nothing ->
            NotFound

        Just route ->
            route


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    Maybe.map toUrlChange <|
        (builder
            |> newEntry
            |> replacePath [ toString current.route ]
            |> Just
        )


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home (s "")
        , map Login (s "login")
        , map Signup (s "signup")
        ]



--matchers : List (Matcher Route)
--matchers =
--[ static Home "/"
--, static Login "/login"
--, static Register "/register"
--]
---- static
--match matchers "/" == Just Home
--match matchers "/login" == Just Login
--match matchers "/register" == Just Register
