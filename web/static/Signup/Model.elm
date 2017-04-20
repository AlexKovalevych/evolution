module Signup.Model exposing (..)

import Json.Encode exposing (object, string, Value)
import Dict


type alias SignupModel =
    { login : String
    , password : String
    , confirmPassword : String
    , errors : Dict.Dict String String
    }


model : SignupModel
model =
    { login = ""
    , password = ""
    , confirmPassword = ""
    , errors = Dict.empty
    }


encoder : SignupModel -> Value
encoder model =
    object
        [ ( "nickname", string model.login )
        , ( "password", string model.password )
        , ( "password_confirmation", string model.confirmPassword )
        ]
