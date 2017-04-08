module Router exposing (parseUrl, delta2url)

import Model exposing (Model)
import Navigation exposing (Location)
import UrlParser exposing (..)
import RouteUrl.Builder exposing (newEntry, builder, Builder)


parseUrl : Location -> List Message
parseUrl =
    parsePath route


delta2builder : Model -> Model -> Maybe Builder
delta2builder previous current =
    builder
        |> newEntry current.route
        |> Just


type Route
    = Home
    | Login
    | Signup


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
