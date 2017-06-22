module Game.View.List exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Material.Button as Button


-- import Material.Grid exposing (grid, Device(..), size, cell, offset)

import Material.Table as Table
import Material.Options as Options
import Routes exposing (Route(..), GameRoute(..))
import Game.Model exposing (Game)
import Game.Messages exposing (GameMsg(..))
import Date
import Date.Extra.Config.Config_ru_ru exposing (config)
import Date.Extra.Format as Format exposing (isoString, format)


itemsPerPage : Int
itemsPerPage =
    10


renderList : Model -> List Game -> Int -> Html Msg
renderList model games page =
    p []
        [ Table.table
            []
            [ Table.thead []
                [ Table.tr []
                    [ Table.th [] [ text "#" ]
                    , Table.th [] [ text "Количество игроков" ]
                    , Table.th [] [ text "Время создания" ]
                    , Table.th [] [ text "Время обновления" ]
                    , Table.th [] []
                    ]
                ]
            , Table.tbody [] <| renderGames model games page
            ]
        ]


renderGames : Model -> List Game -> Int -> List (Html Messages.Msg)
renderGames model games page =
    List.indexedMap (\i game -> renderGame model i game page) games


renderGame : Model -> Int -> Game -> Int -> Html Messages.Msg
renderGame model index game page =
    Table.tr
        []
        [ Table.td [] [ text <| toString <| (page - 1) * itemsPerPage + index + 1 ]
        , Table.td [] [ text <| toString game.players_number ]
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



-- renderPagination model totalPages page =
--    pagination model (List.length model.games.games) model.games.totalPages model.games.page
