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
import Material.Textfield as Textfield
import Game.View.List as ViewList


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

        Games GameList ->
            grid []
                [ cell
                    [ size All 12
                    ]
                    [ h1 [] [ text "Поиск игр" ]
                    , div []
                        [ p []
                            [ text <| "Количество игроков: " ++ toString (model.games.searchPlayers)
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
                                            [ Menu.onSelect <| Game <| SetSearchPlayers i ]
                                            [ text <| toString i ]
                                    )
                                    [ 2, 3, 4 ]
                            ]
                        , Textfield.render Mdl
                            [ 1 ]
                            model.mdl
                            [ Textfield.label "Имя игрока"
                            , Textfield.floatingLabel
                            , Textfield.value model.games.searchPlayer
                            , Options.onInput <| (Game << SetSearchPlayer)
                            ]
                            []
                        , p []
                            [ Button.render Mdl
                                [ 2 ]
                                model.mdl
                                [ Button.raised
                                , Button.ripple
                                , Button.colored
                                , Options.onClick <| Game SearchGames
                                ]
                                [ text "Найти" ]
                            ]
                        ]
                    , ViewList.renderList model model.games.foundGames model.games.foundPage
                    ]
                ]

        _ ->
            div [] []
