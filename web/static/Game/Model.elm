module Game.Model exposing (..)


model : GameModel
model =
    { page = 1
    , games = []
    }


type alias GameModel =
    { page : Int
    , games : List Game
    }


type alias Game =
    { maxPlayers : Int
    }
