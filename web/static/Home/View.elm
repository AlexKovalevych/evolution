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
import Game.Messages exposing (GameMsg(..))
import Date
import Date.Extra.Config.Config_ru_ru exposing (config)
import Date.Extra.Format as Format exposing (isoString, format)


itemsPerPage : Int
itemsPerPage =
    10


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
            , p []
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
                    , Table.tbody [] <| renderGames model
                    ]
                ]
            , pagination model (List.length model.games.games) model.games.totalPages model.games.page
            ]
        ]


renderGames : Model -> List (Html Messages.Msg)
renderGames model =
    List.indexedMap (\i game -> renderGame i game model) model.games.games


renderGame : Int -> Game -> Model.Model -> Html Messages.Msg
renderGame index game model =
    Table.tr
        []
        [ Table.td [] [ text <| toString <| (model.games.page - 1) * itemsPerPage + index + 1 ]
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


pagination : Model.Model -> Int -> Int -> Int -> Html Msg
pagination model fromIndex totalPages currentPage =
    let
        buttonProps =
            (\i ->
                if i == currentPage then
                    [ Button.raised ]
                else
                    [ Button.plain
                    , Button.ripple
                    , Options.onClick <| Messages.Game <| SetPage True i
                    ]
            )

        firstPage =
            Button.render Mdl
                [ fromIndex + 1 ]
                model.mdl
                (buttonProps 1)
                [ text "1" ]

        lastPage =
            if totalPages == 1 then
                span [] []
            else
                Button.render Mdl
                    [ fromIndex + totalPages ]
                    model.mdl
                    (buttonProps totalPages)
                    [ text <| toString totalPages ]

        dots =
            span [] [ text "..." ]

        leftDots =
            if currentPage >= 6 then
                dots
            else
                span [] []

        rightDots =
            if totalPages - currentPage >= 5 then
                dots
            else
                span [] []

        pages =
            if totalPages > 2 then
                List.map
                    (\i ->
                        Button.render Mdl
                            [ fromIndex + i ]
                            model.mdl
                            (buttonProps i)
                            [ text <| toString i ]
                    )
                <|
                    List.range 2 (totalPages - 1)
            else
                [ span [] [] ]
    in
        p [] <|
            [ firstPage
            , leftDots
            ]
                ++ pages
                ++ [ rightDots
                   , lastPage
                   ]
