module Login.Model exposing (..)

import Json.Encode exposing (object, string, Value)
import Dict


type alias LoginModel =
    { login : String
    , password : String
    , errors : Dict.Dict String String
    }


model : LoginModel
model =
    { login = ""
    , password = ""
    , errors = Dict.empty
    }


encoder : LoginModel -> Value
encoder model =
    object
        [ ( "login", string model.login )
        , ( "password", string model.password )
        ]
