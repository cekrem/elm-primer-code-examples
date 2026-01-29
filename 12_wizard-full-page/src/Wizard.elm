module Wizard exposing (Model, Msg, OutMsg(..), init, update, view)

import Api
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


type Model
    = Intro


type Msg
    = Noop
    | Finished Api.Submittable


type OutMsg
    = Cancel
    | Complete Api.Submittable


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none, Nothing )

        Finished data ->
            ( model, Cmd.none, Just <| Complete data )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.text "TODO: wizard view."
        , viewButton (Finished mockData) "Click to finish wizard with mock data"
        ]


viewButton : msg -> String -> Html msg
viewButton action label =
    Html.div
        [ Events.onClick action
        , Attr.class "p-2 bg-[#5cee9a] rounded cursor-pointer"
        ]
        [ Html.text label ]


init : Model
init =
    Intro


mockData : Api.Submittable
mockData =
    [ ( "some data type", "some data value" )
    , ( "some data type2", "some data value" )
    , ( "some data type3", "some data value" )
    , ( "some data type4", "some data value" )
    ]
        |> Dict.fromList
