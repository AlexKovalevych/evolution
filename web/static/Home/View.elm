module Home.View exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Material.Button as Button
import Material.Grid exposing (grid, Device(..), size, cell, offset)
import Material.Table as Table


view : Model.Model -> Html Messages.Msg
view model =
    grid []
        [ cell
            [ size All 12
            ]
            [ div []
                [ Button.render Mdl
                    [ 0 ]
                    model.mdl
                    [ Button.raised
                    , Button.colored
                    ]
                    [ text "New game" ]
                ]
            , Table.table
                []
                [ Table.thead []
                    [ Table.tr []
                        [ Table.th [] [ text "# of Players" ]
                        , Table.th [] [ text "Started" ]
                        , Table.th [] [ text "Last update" ]
                        ]
                    ]
                , Table.tbody [] []
                ]
            ]
        ]
