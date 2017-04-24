module Models.User exposing (..)

import Json.Decode exposing (..)


type alias User =
    { login : String
    }


userDecoder : Decoder User
userDecoder =
    map User
        (field "login" string)
