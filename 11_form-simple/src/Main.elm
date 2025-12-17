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
    , category : Category
    , message : String
    }


initialModel : Model
initialModel =
    { email = ""
    , category = GeneralFeedback
    , message = ""
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
            { model | email = email }

        UpdateCategory category ->
            { model | category = category }

        UpdateMessage message ->
            { model | message = message }

        Submit ->
            Debug.log "submit" model


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
                ]
                []
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
                ]
                []
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
