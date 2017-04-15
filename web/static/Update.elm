module Update exposing (update)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Routes exposing (Route(..))
import Material
import Login.Update as LoginUpdate
import Signup.Update as SignupUpdate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg_ ->
            Material.update Mdl msg_ model

        ErrorPage ->
            { model | route = NotFound } ! []

        ChangePage route ->
            { model | route = route } ! []

        Messages.Login loginMsg ->
            { model | login = LoginUpdate.update loginMsg model.login } ! []

        Messages.Signup signupMsg ->
            { model | signup = SignupUpdate.update signupMsg model.signup } ! []

        NoOp ->
            model ! []
