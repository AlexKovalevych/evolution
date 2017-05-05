module Game.View exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Game.Messages exposing (GameMsg(..))
import Routes exposing (Route(..), GameRoute(..))
import Material.Grid exposing (grid, Device(..), size, cell, offset)
import Material.Menu as Menu
import Material.Button as Button
import Material.Options as Options


view : Model -> Html Msg
view model =
    case model.route of
        Games NewGame ->
            grid []
                [ cell
                    [ size All 12
                    ]
                    [ h1 [] [ text "Создать игру" ]
                    , div []
                        [ p []
                            [ text <| "Количество игроков: " ++ toString (model.games.newGamePlayers)
                            , Menu.render Mdl
                                [ 0 ]
                                model.mdl
                                [ Menu.ripple
                                , Menu.bottomLeft
                                , Menu.icon "supervisor_account"
                                , Options.css "display" "inline-block"
                                ]
                              <|
                                List.map
                                    (\i ->
                                        Menu.item
                                            [ Menu.onSelect <| Game <| SetPlayers i ]
                                            [ text <| toString i ]
                                    )
                                    [ 2, 3, 4 ]
                            ]
                        , p []
                            [ Button.render Mdl
                                [ 1 ]
                                model.mdl
                                [ Button.raised
                                , Button.ripple
                                , Button.colored
                                , Options.onClick <| Game CreateGame
                                ]
                                [ text "Создать" ]
                            ]
                        ]
                    ]
                ]

        Games (ViewGame id) ->
            div [] []

        _ ->
            div [] []
