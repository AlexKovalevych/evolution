module Game.Model exposing (..)


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
    { maxPlayers : Int
    }
