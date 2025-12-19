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
    = UpdateName String
    | UpdateEmail String
    | UpdateMessage String
    | Submit


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateName name ->
            { model | name = name }

        UpdateEmail email ->
            { model | email = email }

        UpdateMessage message ->
            { model | message = message }

        Submit ->
            Debug.log "submit" model


view : Model -> Html Msg
view model =
    Html.form
        [ Events.onSubmit Submit
        , Attr.class "flex flex-col gap-4 max-w-md mx-auto"
        , Attr.class "bg-gray-100 p-4 rounded"
        ]
        [ Html.input
            [ Attr.type_ "text"
            , Attr.value model.name
            , Attr.placeholder "Name"
            , Events.onInput UpdateName
            ]
            []
        , Html.input
            [ Attr.type_ "email"
            , Attr.value model.email
            , Attr.placeholder "Email"
            , Events.onInput UpdateEmail
            ]
            []
        , Html.input
            [ Attr.value model.message
            , Attr.placeholder "Message"
            , Events.onInput UpdateMessage
            ]
            []
        , Html.button [ Attr.type_ "submit" ] [ Html.text "Submit" ]
        ]
