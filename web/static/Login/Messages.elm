module Login.Messages exposing (..)

import Http


type LoginMsg
    = SetLogin String
    | SetPassword String
    | LoginRequest
    | LoginResponse (Result Http.Error String)
