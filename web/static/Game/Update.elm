module Game.Update exposing (..)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Channel


joinGamesChannel : Model -> ( Model, Cmd Msg )
joinGamesChannel model =
    case model.phxSocket of
        Nothing ->
            model ! []

        Just socket ->
            let
                payload =
                    (JE.object [ ( "page", JE.int model.games.page ) ])

                channel =
                    Phoenix.Channel.init "games:list"
                        |> Phoenix.Channel.withPayload payload

                -- |> Phoenix.Channel.onJoin (always (ShowJoinedMessage "rooms:lobby"))
                -- |> Phoenix.Channel.onClose (always (ShowLeftMessage "rooms:lobby"))
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel socket
            in
                { model | phxSocket = Just phxSocket }
                    ! [ Cmd.map PhoenixMsg phxCmd ]



-- LeaveChannel ->
--     let
--         ( phxSocket, phxCmd ) =
--             Phoenix.Socket.leave "rooms:lobby" model.phxSocket
--     in
--         ( { model | phxSocket = phxSocket }
--         , Cmd.map PhoenixMsg phxCmd
--         )
