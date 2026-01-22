module Main exposing (main)

import Browser
import Html exposing (Html)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = always ( Welcome, Cmd.none )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }



-- MODEL (WIP!)


type Model
    = Welcome
    | ReportBug Bug.Model
    | RequestFeature Feature.Model
    | Confirm Api.Submittable



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )


type Msg
    = Noop



-- VIEW


view : Model -> Html Msg
view model =
    Html.div [] [ Html.text "it's on" ]
