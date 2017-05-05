module Game.Model exposing (..)

import Json.Decode as JD


model : GameModel
model =
    { page = 1
    , totalPages = 1
    , games = []
    , newGamePlayers = 2
    , searchPlayers = 2
    , foundGames = []
    , openedGame = Nothing
    }


type alias GameModel =
    { page : Int
    , totalPages : Int
    , games : List Game
    , newGamePlayers : Int
    , searchPlayers : Int
    , foundGames : List Game
    , openedGame : Maybe Game
    }


type alias Game =
    { id : Int
    , players_number : Int
    , inserted_at : String
    , updated_at : String
    }


type alias GameResponse =
    { total_pages : Int
    , games : List Game
    , page : Int
    }


decodeGamesResponse : JD.Decoder GameResponse
decodeGamesResponse =
    JD.map3 GameResponse
        (JD.field "total_pages" JD.int)
        (JD.field "games" <| JD.list decodeGame)
        (JD.field "page" JD.int)


decodeGame : JD.Decoder Game
decodeGame =
    JD.map4 Game
        (JD.field "id" JD.int)
        (JD.field "players_number" JD.int)
        (JD.field "inserted_at" JD.string)
        (JD.field "updated_at" JD.string)
