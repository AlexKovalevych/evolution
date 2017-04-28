module Socket exposing (..)

import Native.Location
import Phoenix.Socket
import Messages exposing (Msg(..))


gamesChannel : String
gamesChannel =
    "games:list"


initSocket : String -> Maybe (Phoenix.Socket.Socket Msg)
initSocket token =
    if token == "" then
        Nothing
    else
        let
            location =
                Native.Location.getLocation ()
        in
            Just <| Phoenix.Socket.init ("ws://" ++ location.host ++ "/socket/websocket?token=" ++ token)
