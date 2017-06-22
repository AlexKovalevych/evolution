module Home.View exposing (..)

import Html exposing (..)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Material.Button as Button
import Material.Grid exposing (grid, Device(..), size, cell, offset)
import Material.Options as Options
import Routes exposing (Route(..), GameRoute(..))
import Game.Messages exposing (GameMsg(..))
import Game.View.List as ViewList


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
            , ViewList.renderList model model.games.games model.games.page
            , pagination model (List.length model.games.games) model.games.totalPages model.games.page
            ]
        ]


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
