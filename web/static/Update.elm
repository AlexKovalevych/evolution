module Update exposing (update)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Routes exposing (Route(..))
import Material


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Boilerplate: Mdl action handler.
        Mdl msg_ ->
            Material.update Mdl msg_ model

        ErrorPage ->
            { model | route = NotFound } ! []

        ChangePage route ->
            { model | route = route } ! []
