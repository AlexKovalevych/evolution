module Game.Update exposing (..)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Json.Encode as JE
import Json.Decode as JD
import Phoenix.Socket
import Phoenix.Channel
import Game.Messages exposing (GameMsg(..))
import Game.Model exposing (decodeGamesResponse, decodeGame)
import Phoenix.Socket
import Phoenix.Push
import Routes exposing (GameRoute(..))


gamesChannel : String
gamesChannel =
    "games:list"


update : GameMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        gamesModel =
            model.games
    in
        case msg of
            SetPlayers players ->
                { model | games = { gamesModel | newGamePlayers = players } } ! []

            LoadGames value ->
                case JD.decodeValue decodeGamesResponse value of
                    Err reason ->
                        let
                            _ =
                                Debug.log "reason" reason
                        in
                            model ! []

                    Ok gamesResponse ->
                        { model | games = { gamesModel | games = gamesResponse.games } } ! []

            CreateGame ->
                case model.phxSocket of
                    Nothing ->
                        model ! []

                    Just socket ->
                        let
                            payload =
                                JE.object [ ( "players", JE.int gamesModel.newGamePlayers ) ]

                            push =
                                Phoenix.Push.init "new:game" gamesChannel
                                    |> Phoenix.Push.withPayload payload
                                    |> Phoenix.Push.onOk
                                        (\value ->
                                            case JD.decodeValue decodeGame value of
                                                Err _ ->
                                                    NoOp

                                                Ok game ->
                                                    ChangePage <| Routes.Games <| ViewGame game.id
                                        )

                            ( socket_, cmd ) =
                                Phoenix.Socket.push push socket
                        in
                            { model | phxSocket = Just socket_ } ! [ Cmd.map PhoenixMsg cmd ]


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
                    Phoenix.Channel.init gamesChannel
                        |> Phoenix.Channel.withPayload payload
                        |> Phoenix.Channel.onJoin (\v -> Game <| LoadGames v)

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
