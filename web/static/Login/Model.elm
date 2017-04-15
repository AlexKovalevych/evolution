module Login.Model exposing (..)


type alias LoginModel =
    { login : String
    , password : String
    }


model : LoginModel
model =
    { login = ""
    , password = ""
    }
