module Signup.Messages exposing (..)

import Http


type SignupMsg
    = SetLogin String
    | SetPassword String
    | SetConfirmPassword String
    | SignupRequest
    | SignupResponse (Result Http.Error String)
