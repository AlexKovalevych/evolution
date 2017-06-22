module Game.Update exposing (..)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Json.Encode as JE
import Json.Decode as JD
import Phoenix.Socket
import Phoenix.Channel
import Game.Messages exposing (GameMsg(..))
import Game.Model exposing (decodeGamesResponse, decodeGameState, decodeGame)
import Phoenix.Socket
import Phoenix.Push
import Routes exposing (GameRoute(..))
import Channel exposing (gamesChannel, Channel(..))


update : GameMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        gamesModel =
            model.games
    in
        case msg of
            SetPlayers players ->
                { model | games = { gamesModel | newGamePlayers = players } } ! []

            SetSearchPlayers players ->
                { model | games = { gamesModel | searchPlayers = players } } ! []

            SetSearchPlayer player ->
                { model | games = { gamesModel | searchPlayer = player } } ! []

            LoadGames value ->
                case JD.decodeValue decodeGamesResponse value of
                    Err reason ->
                        let
                            _ =
                                Debug.log "reason" reason
                        in
                            model ! []

                    Ok gamesResponse ->
                        { model
                            | games =
                                { gamesModel
                                    | games = gamesResponse.games
                                    , totalPages = gamesResponse.total_pages
                                    , page = gamesResponse.page
                                }
                        }
                            ! []

            LoadGame value ->
                case JD.decodeValue decodeGameState value of
                    Err reason ->
                        let
                            _ =
                                Debug.log "reason" reason
                        in
                            model ! []

                    Ok game ->
                        { model
                            | games =
                                { gamesModel | openedGame = Just game }
                        }
                            ! []

            CreateGame ->
                case model.phxSocket of
                    Nothing ->
                        model ! []

                    Just socket ->
                        let
                            payload =
                                JE.object [ ( "players", JE.int gamesModel.newGamePlayers ) ]

                            push =
                                Phoenix.Push.init "new" gamesChannel
                                    |> Phoenix.Push.withPayload payload
                                    |> Phoenix.Push.onOk
                                        (\value ->
                                            case JD.decodeValue decodeGameState value of
                                                Err err ->
                                                    let
                                                        _ =
                                                            Debug.log "Error" err
                                                    in
                                                        NoOp

                                                Ok gameState ->
                                                    ChangePage <| Routes.Games <| ViewGame gameState.game.id
                                        )

                            ( socket_, cmd ) =
                                Phoenix.Socket.push push socket
                        in
                            { model | phxSocket = Just socket_ } ! [ Cmd.map PhoenixMsg cmd ]

            SetPage andLoad page ->
                let
                    newModel =
                        { model | games = { gamesModel | page = page } }
                in
                    if andLoad then
                        loadGames newModel
                    else
                        newModel ! []

            SearchGames ->
                searchGames model

            FoundGames value ->
                case JD.decodeValue decodeGamesResponse value of
                    Err reason ->
                        let
                            _ =
                                Debug.log "reason" reason
                        in
                            model ! []

                    Ok gamesResponse ->
                        { model
                            | games =
                                { gamesModel
                                    | foundGames = gamesResponse.games
                                    , foundPages = gamesResponse.total_pages
                                    , foundPage = gamesResponse.page
                                }
                        }
                            ! []

            ReloadPage ->
                case model.route of
                    Routes.Home ->
                        loadGames model

                    _ ->
                        model ! []


joinGamesChannel : Model -> ( Model, Cmd Msg )
joinGamesChannel model =
    let
        _ =
            Debug.log "join channel" ""
    in
        case model.phxSocket of
            Nothing ->
                model ! []

            Just socket ->
                let
                    channel =
                        Phoenix.Channel.init gamesChannel
                            |> Phoenix.Channel.onJoin (\_ -> JoinChannel GamesChannel)

                    -- |> Phoenix.Channel.onClose (always (ShowLeftMessage "rooms:lobby"))
                    ( phxSocket, phxCmd ) =
                        Phoenix.Socket.join channel socket
                in
                    { model | phxSocket = Just phxSocket }
                        ! [ Cmd.map PhoenixMsg phxCmd ]


loadGames : Model -> ( Model, Cmd Msg )
loadGames model =
    case model.phxSocket of
        Nothing ->
            model ! []

        Just socket ->
            if List.member GamesChannel model.channels then
                let
                    payload =
                        (JE.object [ ( "page", JE.int model.games.page ) ])

                    channel =
                        Phoenix.Push.init "list" gamesChannel
                            |> Phoenix.Push.withPayload payload
                            |> Phoenix.Push.onOk (\v -> Game <| LoadGames v)

                    ( phxSocket, phxCmd ) =
                        Phoenix.Socket.push channel socket
                in
                    { model | phxSocket = Just phxSocket }
                        ! [ Cmd.map PhoenixMsg phxCmd ]
            else
                model ! []


loadGame : Int -> Model -> ( Model, Cmd Msg )
loadGame id model =
    let
        gameModel =
            model.games

        newGameModel =
            { gameModel | openedGame = Nothing }
    in
        case model.phxSocket of
            Nothing ->
                { model | games = newGameModel } ! []

            Just socket ->
                if List.member GamesChannel model.channels then
                    let
                        payload =
                            (JE.object [ ( "id", JE.int id ) ])

                        channel =
                            Phoenix.Push.init "load" gamesChannel
                                |> Phoenix.Push.withPayload payload
                                |> Phoenix.Push.onOk (\v -> Game <| LoadGame v)

                        ( phxSocket, phxCmd ) =
                            Phoenix.Socket.push channel socket
                    in
                        { model | phxSocket = Just phxSocket, games = newGameModel }
                            ! [ Cmd.map PhoenixMsg phxCmd ]
                else
                    { model | games = newGameModel } ! []


searchGames : Model -> ( Model, Cmd Msg )
searchGames model =
    case model.phxSocket of
        Nothing ->
            model ! []

        Just socket ->
            if List.member GamesChannel model.channels then
                let
                    payload =
                        (JE.object
                            [ ( "player", JE.string model.games.searchPlayer )
                            , ( "players", JE.int model.games.searchPlayers )
                            , ( "page", JE.int model.games.foundPage )
                            ]
                        )

                    channel =
                        Phoenix.Push.init "search" gamesChannel
                            |> Phoenix.Push.withPayload payload
                            |> Phoenix.Push.onOk (\v -> Game <| FoundGames v)

                    ( phxSocket, phxCmd ) =
                        Phoenix.Socket.push channel socket
                in
                    { model | phxSocket = Just phxSocket }
                        ! [ Cmd.map PhoenixMsg phxCmd ]
            else
                model ! []



-- LeaveChannel ->
--     let
--         ( phxSocket, phxCmd ) =
--             Phoenix.Socket.leave "rooms:lobby" model.phxSocket
--     in
--         ( { model | phxSocket = phxSocket }
--         , Cmd.map PhoenixMsg phxCmd
--         )
