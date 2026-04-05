module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }


type alias Model =
    { name : String
    , email : String
    , message : String
    }


initialModel : Model
initialModel =
    { name = ""
    , email = ""
    , message = ""
    }


type Msg
    = EnteredName String
    | EnteredEmail String
    | EnteredMessage String
    | FormSubmitted


update : Msg -> Model -> Model
update msg model =
    case msg of
        EnteredName name ->
            { model | name = name }

        EnteredEmail email ->
            { model | email = email }

        EnteredMessage message ->
            { model | message = message }

        FormSubmitted ->
            Debug.log "submit" model


view : Model -> Html Msg
view model =
    Html.form
        [ Events.onSubmit FormSubmitted
        , Attr.class "flex flex-col gap-4 max-w-md mx-auto"
        , Attr.class "bg-gray-100 p-4 rounded"
        ]
        [ Html.input
            [ Attr.type_ "text"
            , Attr.value model.name
            , Attr.placeholder "Name"
            , Events.onInput EnteredName
            ]
            []
        , Html.input
            [ Attr.type_ "email"
            , Attr.value model.email
            , Attr.placeholder "Email"
            , Events.onInput EnteredEmail
            ]
            []
        , Html.input
            [ Attr.value model.message
            , Attr.placeholder "Message"
            , Events.onInput EnteredMessage
            ]
            []
        , Html.button [ Attr.type_ "submit" ] [ Html.text "Submit" ]
        ]
