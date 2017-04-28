module Home.View exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Material.Button as Button
import Material.Grid exposing (grid, Device(..), size, cell, offset)
import Material.Table as Table
import Material.Options as Options
import Routes exposing (Route(..), GameRoute(..))
import Game.Model exposing (Game)
import Date
import Date.Extra.Config.Config_ru_ru exposing (config)
import Date.Extra.Format as Format exposing (isoString, format)


view : Model.Model -> Html Messages.Msg
view model =
    grid []
        [ cell
            [ size All 12
            ]
            [ p []
                [ Button.render Mdl
                    [ 0 ]
                    model.mdl
                    [ Button.raised
                    , Button.colored
                    , Options.onClick <| ChangePage <| Games NewGame
                    ]
                    [ text "Создать игру" ]
                ]
            , Table.table
                []
                [ Table.thead []
                    [ Table.tr []
                        [ Table.th [] [ text "# игроков" ]
                        , Table.th [] [ text "Время создания" ]
                        , Table.th [] [ text "Время обновления" ]
                        , Table.th [] []
                        ]
                    ]
                , Table.tbody [] <| renderGames model
                ]
            ]
        ]


renderGames : Model -> List (Html Messages.Msg)
renderGames model =
    List.indexedMap (\i game -> renderGame i game model) model.games.games


renderGame : Int -> Game -> Model.Model -> Html Messages.Msg
renderGame index game model =
    Table.tr
        []
        [ Table.td [] [ text <| toString game.players_number ]
        , Table.td [] [ text <| formatDate game.inserted_at ]
        , Table.td [] [ text <| formatDate game.updated_at ]
        , Table.td []
            [ Button.render Mdl
                [ index + 1 ]
                model.mdl
                [ Button.raised
                , Options.onClick <| ChangePage <| Games <| ViewGame game.id
                ]
                [ text "Открыть" ]
            ]
        ]


formatDate : String -> String
formatDate value =
    case Date.fromString value of
        Ok date ->
            format config "%Y-%m-%d %H:%M:%S" date

        Err _ ->
            ""
