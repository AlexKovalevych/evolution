module Login.View exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Material.Textfield as Textfield


view : Model.Model -> Html Messages.Msg
view model =
    div []
        [ Textfield.render Mdl
            [ 0 ]
            model.mdl
            [ Textfield.label "Login"
            , Textfield.floatingLabel
            ]
            []
        , Textfield.render Mdl
            [ 1 ]
            model.mdl
            [ Textfield.label "Password"
            , Textfield.floatingLabel
            , Textfield.password
            ]
            []
        ]
