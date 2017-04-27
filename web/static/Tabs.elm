module Tabs exposing (..)

import Routes exposing (Route(..), GameRoute(..))
import Dict


tabRoutes : Dict.Dict Int (List Route)
tabRoutes =
    Dict.fromList [ ( 0, [ Home, Games NewGame ] ), ( 1, [ Games GameList ] ) ]


tabToRoute : Int -> Maybe Route
tabToRoute tab =
    case Dict.get tab tabRoutes of
        Nothing ->
            Nothing

        Just routes ->
            List.head routes


routeToTab : Route -> Maybe Int
routeToTab route =
    Dict.filter (\k v -> List.member route v) tabRoutes
        |> Dict.keys
        |> List.head
