module Wizard exposing (Model, Msg, OutMsg(..), init, update, view)

import Api
import Html exposing (Html)


type Model
    = Intro


type Msg
    = Noop


type OutMsg
    = Cancel
    | Complete Api.Submittable


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none, Nothing )


view : Model -> Html Msg
view model =
    Html.text "TODO: wizard view"


init : Model
init =
    Intro
