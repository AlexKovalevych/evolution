module Login.Update exposing (..)

import Login.Messages exposing (LoginMsg(..))
import Login.Model exposing (LoginModel)


update : LoginMsg -> LoginModel -> LoginModel
update msg model =
    case msg of
        SetLogin value ->
            { model | login = value }

        SetPassword value ->
            { model | password = value }

        LoginRequest ->
            model
