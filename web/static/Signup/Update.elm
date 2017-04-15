module Signup.Update exposing (..)

import Signup.Messages exposing (SignupMsg(..))
import Signup.Model exposing (SignupModel)


update : SignupMsg -> SignupModel -> SignupModel
update msg model =
    case msg of
        SetLogin value ->
            { model | login = value }

        SetPassword value ->
            { model | password = value }

        SetConfirmPassword value ->
            { model | confirmPassword = value }

        SignupRequest ->
            model
