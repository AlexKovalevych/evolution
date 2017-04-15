module Signup.Messages exposing (..)


type SignupMsg
    = SetLogin String
    | SetPassword String
    | SetConfirmPassword String
    | SignupRequest
