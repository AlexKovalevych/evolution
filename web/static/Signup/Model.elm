module Signup.Model exposing (..)

import Json.Encode exposing (object, string, Value)


type alias SignupModel =
    { login : String
    , password : String
    , confirmPassword : String
    , loginError : String
    , passwordError : String
    }


model : SignupModel
model =
    { login = ""
    , password = ""
    , confirmPassword = ""
    , loginError = ""
    , passwordError = ""
    }


encoder : SignupModel -> Value
encoder model =
    object
        [ ( "login", string model.login )
        , ( "password", string model.password )
        ]
