module Signup.Model exposing (..)


type alias SignupModel =
    { login : String
    , password : String
    , confirmPassword : String
    }


model : SignupModel
model =
    { login = ""
    , password = ""
    , confirmPassword = ""
    }
