module Main exposing (main)

import Browser
import Html
import Html.Attributes as Attributes
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


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.h2 [] [ Html.text "Send Feedback" ]
        , Html.div []
            [ Html.label [] [ Html.text "Email" ]
            , Html.input
                [ Attributes.type_ "email"
                , Attributes.value model.email
                , Events.onInput UpdateEmail
                , Attributes.class
                    (if model.emailError /= Nothing then
                        "error"

                     else
                        ""
                    )
                ]
                []
            , case model.emailError of
                Just err ->
                    Html.span [ Attributes.class "error-message" ]
                        [ Html.text err ]

                Nothing ->
                    Html.text ""
            ]
        , Html.div []
            [ Html.label [] [ Html.text "Category" ]
            , Html.select
                [ Events.onInput categoryFromString ]
                [ Html.option
                    [ Attributes.selected (model.category == BugReport) ]
                    [ Html.text "Bug Report" ]
                , Html.option
                    [ Attributes.selected (model.category == FeatureRequest) ]
                    [ Html.text "Feature Request" ]
                , Html.option
                    [ Attributes.selected (model.category == GeneralFeedback) ]
                    [ Html.text "General Feedback" ]
                ]
            ]
        , Html.div []
            [ Html.label [] [ Html.text "Message" ]
            , Html.textarea
                [ Attributes.value model.message
                , Events.onInput UpdateMessage
                , Attributes.class
                    (if model.messageError /= Nothing then
                        "error"

                     else
                        ""
                    )
                ]
                []
            , case model.messageError of
                Just err ->
                    Html.span [ Attributes.class "error-message" ]
                        [ Html.text err ]

                Nothing ->
                    Html.text ""
            ]
        , Html.button [ Events.onClick Submit ] [ Html.text "Submit" ]
        ]


categoryFromString : String -> Msg
categoryFromString str =
    case str of
        "Bug Report" ->
            UpdateCategory BugReport

        "Feature Request" ->
            UpdateCategory FeatureRequest

        _ ->
            UpdateCategory GeneralFeedback
