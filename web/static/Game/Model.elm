module Game.Model exposing (..)

import Json.Decode as JD
import Models.User exposing (User, userDecoder)


model : GameModel
model =
    { page = 1
    , totalPages = 1
    , games = []
    , newGamePlayers = 2
    , searchPlayers = 2
    , searchPlayer = ""
    , foundGames = []
    , foundPages = 1
    , foundPage = 1
    , openedGame = Nothing
    }


type alias GameModel =
    { page : Int
    , totalPages : Int
    , games : List Game
    , newGamePlayers : Int
    , searchPlayers : Int
    , searchPlayer : String
    , foundGames : List Game
    , foundPages : Int
    , foundPage : Int
    , openedGame : Maybe GameState
    }


type alias Game =
    { id : Int
    , players_number : Int
    , inserted_at : String
    , updated_at : String
    }


type alias Player =
    { user : User
    }


type alias GameResponse =
    { total_pages : Int
    , games : List Game
    , page : Int
    }


type alias GameState =
    { players : List Player
    , state : String
    , game : Game
    }


decodeGamesResponse : JD.Decoder GameResponse
decodeGamesResponse =
    JD.map3 GameResponse
        (JD.field "total_pages" JD.int)
        (JD.field "games" <| JD.list decodeGame)
        (JD.field "page" JD.int)


decodeGameState : JD.Decoder GameState
decodeGameState =
    JD.map3 GameState
        (JD.field "players" <| JD.list decodePlayer)
        (JD.field "state" JD.string)
        (JD.field "game" decodeGame)


decodeGame : JD.Decoder Game
decodeGame =
    JD.map4 Game
        (JD.field "id" JD.int)
        (JD.field "players_number" JD.int)
        (JD.field "inserted_at" JD.string)
        (JD.field "updated_at" JD.string)


decodePlayer : JD.Decoder Player
decodePlayer =
    JD.map Player
        (JD.field "user" userDecoder)
