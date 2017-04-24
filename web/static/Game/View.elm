module Game.View exposing (..)

import Html exposing (..)
import Html.Events exposing (onSubmit)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Game.Messages exposing (GameMsg(..))
import Routes exposing (Route(..), GameRoute(..))
import Material.Grid exposing (grid, Device(..), size, cell, offset)
import Material.Menu as Menu


view : Model -> Html Msg
view model =
    case model.route of
        Games NewGame ->
            grid []
                [ cell
                    [ size All 12
                    ]
                    [ h1 [] [ text "New game" ]
                    , div []
                        [ Menu.render Mdl
                            [ 0 ]
                            model.mdl
                            [ Menu.ripple, Menu.bottomLeft ]
                          <|
                            List.map
                                (\i ->
                                    Menu.item
                                        [ Menu.onSelect <| Game <| SetPlayers i ]
                                        [ text <| toString i ]
                                )
                                [ 2, 3, 4 ]
                        ]
                    ]
                ]

        _ ->
            div [] []
