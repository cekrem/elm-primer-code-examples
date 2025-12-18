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


type Category
    = BugReport
    | FeatureRequest
    | GeneralFeedback


type alias Model =
    { email : String
    , emailError : Maybe String
    , category : Category
    , message : String
    , messageError : Maybe String
    }


initialModel : Model
initialModel =
    { email = ""
    , emailError = Nothing
    , category = GeneralFeedback
    , message = ""
    , messageError = Nothing
    }


type Msg
    = UpdateEmail String
    | UpdateCategory Category
    | UpdateMessage String
    | Submit


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateEmail email ->
            { model
                | email = email
                , emailError = validateEmail email
            }

        UpdateCategory category ->
            { model | category = category }

        UpdateMessage message ->
            { model
                | message = message
                , messageError = validateMessage message
            }

        Submit ->
            Debug.log "submit" model


validateEmail : String -> Maybe String
validateEmail email =
    if String.isEmpty email then
        Just "Email is required"

    else if not (String.contains "@" email) then
        Just "Please enter a valid email"

    else
        Nothing


validateMessage : String -> Maybe String
validateMessage message =
    if String.length message < 10 then
        Just "Message must be at least 10 characters"

    else
        Nothing


view : Model -> Html Msg
view model =
    Html.form
        [ Events.onSubmit Submit
        , Attr.class "flex flex-col gap-4 max-w-md mx-auto p-6"
        ]
        [ Html.h2
            [ Attr.class "text-2xl font-bold" ]
            [ Html.text "Send Feedback" ]
        , Html.label
            [ Attr.class "font-medium" ]
            [ Html.text "Email" ]
        , Html.input
            [ Attr.type_ "email"
            , Attr.value model.email
            , Events.onInput UpdateEmail
            , Attr.placeholder "you@example.com"
            , Attr.class
                (inputClass ++ errorBorder model.emailError)
            ]
            []
        , viewError model.emailError
        , Html.label
            [ Attr.class "font-medium" ]
            [ Html.text "Category" ]
        , Html.select
            [ Events.onInput categoryFromString
            , Attr.class inputClass
            ]
            [ Html.option
                [ Attr.selected (model.category == BugReport) ]
                [ Html.text "Bug Report" ]
            , Html.option
                [ Attr.selected (model.category == FeatureRequest) ]
                [ Html.text "Feature Request" ]
            , Html.option
                [ Attr.selected (model.category == GeneralFeedback) ]
                [ Html.text "General Feedback" ]
            ]
        , Html.label
            [ Attr.class "font-medium" ]
            [ Html.text "Message" ]
        , Html.textarea
            [ Attr.value model.message
            , Events.onInput UpdateMessage
            , Attr.placeholder "Tell us what's on your mind..."
            , Attr.class
                (inputClass ++ errorBorder model.messageError)
            ]
            []
        , viewError model.messageError
        , Html.button
            [ Attr.class "bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700" ]
            [ Html.text "Submit" ]
        ]


inputClass : String
inputClass =
    "border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"


errorBorder : Maybe String -> String
errorBorder maybeError =
    case maybeError of
        Just _ ->
            " border-red-500"

        Nothing ->
            " border-gray-300"


viewError : Maybe String -> Html msg
viewError maybeError =
    case maybeError of
        Just err ->
            Html.span
                [ Attr.class "text-red-500 text-sm -mt-2" ]
                [ Html.text err ]

        Nothing ->
            Html.text ""


categoryFromString : String -> Msg
categoryFromString str =
    case str of
        "Bug Report" ->
            UpdateCategory BugReport

        "Feature Request" ->
            UpdateCategory FeatureRequest

        _ ->
            UpdateCategory GeneralFeedback
