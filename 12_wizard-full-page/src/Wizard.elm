module Wizard exposing (Model, Msg, OutMsg(..), init, update, view)

import Api
import Dict exposing (Dict)
import Form
import Html exposing (Html)
import Html.Attributes as Attr


type Model
    = Model
        { formValues : Dict String String
        }


type Msg
    = Noop
    | FormChanged Api.Submittable
    | FormSubmitted


type OutMsg
    = Cancel
    | Complete Api.Submittable


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg ((Model model) as unchangedModel) =
    case msg of
        Noop ->
            ( Model model, Cmd.none, Nothing )

        FormChanged newValues ->
            ( Model { model | formValues = newValues }, Cmd.none, Nothing )

        FormSubmitted ->
            ( unchangedModel, Cmd.none, Just <| Complete model.formValues )


view : Model -> Html Msg
view (Model model) =
    Html.div []
        [ viewTitle "Submit feedback"
        , Form.new [ Attr.class "flex flex-col gap-2" ]
            [ Form.input "feedback" "Feedback"
                |> Form.withRequired True
                |> Form.withPlaceholder "What's your feedback?"
                |> Form.withAttributes [ Attr.class "p-2" ]
            , Form.input "email" "Email Address"
                |> Form.withType "email"
                |> Form.withPlaceholder "Your email (optional)"
                |> Form.withAttributes [ Attr.class "p-2" ]
            ]
            |> Form.withSubmitButton "Submit"
                [ Attr.class "p-2"
                , Attr.class "bg-[#5cee9a]"
                , Attr.class "rounded"
                , Attr.class "cursor-pointer"
                ]
            |> Form.build model.formValues FormChanged FormSubmitted
        ]


viewTitle : String -> Html msg
viewTitle title =
    Html.h1
        [ Attr.class "mb-2"
        , Attr.class "text-xl font-bold"
        ]
        [ Html.text title ]


init : Model
init =
    Model { formValues = Dict.empty }
