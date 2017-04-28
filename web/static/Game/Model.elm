module Game.Model exposing (..)

import Json.Decode as JD


model : GameModel
model =
    { page = 1
    , games = []
    , newGamePlayers = 2
    }


type alias GameModel =
    { page : Int
    , games : List Game
    , newGamePlayers : Int
    }


type alias Game =
    { players_number : Int
    , inserted_at : String
    , updated_at : String
    }


type alias GameResponse =
    { total_pages : Int
    , games : List Game
    }


decodeGamesResponse : JD.Decoder GameResponse
decodeGamesResponse =
    JD.map2 GameResponse
        (JD.field "total_pages" JD.int)
        (JD.field "games" <| JD.list decodeGame)


decodeGame : JD.Decoder Game
decodeGame =
    JD.map3 Game
        (JD.field "players_number" JD.int)
        (JD.field "inserted_at" JD.string)
        (JD.field "updated_at" JD.string)
