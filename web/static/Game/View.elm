module Game.View exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Messages exposing (Msg)
import Material.Button as Button
import Messages exposing (Msg(..))


view : Model -> Html Msg
view model =
    div []
        [ Button.render Mdl
            [ 0 ]
            model.mdl
            [ Button.raised
            , Button.colored
            ]
            [ text "New game" ]
        ]
