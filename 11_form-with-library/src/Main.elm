module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Form
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


type alias Model =
    { formValues : Dict String String
    , category : Category
    , submitted : Maybe (Dict String String)
    }


type Category
    = BugReport
    | FeatureRequest
    | GeneralFeedback


type Msg
    = FormChanged (Dict String String)
    | UpdateCategory Category
    | FormSubmitted


init : Model
init =
    { formValues = Dict.empty
    , category = GeneralFeedback
    , submitted = Nothing
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged values ->
            { model | formValues = values }

        UpdateCategory category ->
            { model | category = category }

        FormSubmitted ->
            { model | submitted = Just model.formValues }



-- Validators


emailValidator : String -> Result (List (Html.Attribute msg)) ()
emailValidator value =
    if String.isEmpty value then
        Ok ()

    else if String.contains "@" value && String.contains "." value then
        Ok ()

    else
        Err
            [ Attr.class "error"
            , Attr.attribute "aria-invalid" "true"
            ]


minLength : Int -> String -> Result (List (Html.Attribute msg)) ()
minLength n value =
    if String.length value >= n then
        Ok ()

    else
        Err
            [ Attr.class "error"
            , Attr.attribute "aria-invalid" "true"
            ]



-- Transformers


normalizePhone : String -> String
normalizePhone =
    String.filter Char.isDigit



-- View


feedbackForm : Form.Form Msg
feedbackForm =
    Form.new [ Attr.class "feedback-form", Attr.id "feedback-form" ]
        [ Form.input "email" "Email"
            |> Form.withType "email"
            |> Form.withRequired True
            |> Form.withValidator emailValidator
            |> Form.withPlaceholder "you@example.com"

        , Form.input "message" "Message"
            |> Form.withRequired True
            |> Form.withValidator (minLength 10)
            |> Form.withPlaceholder "Tell us what's on your mind..."

        -- Extra fields to show the form scales without boilerplate
        , Form.input "name" "Full Name (optional)"
            |> Form.withTransformer String.trim
            |> Form.withPlaceholder "Jane Doe"

        , Form.input "phone" "Phone (optional)"
            |> Form.withType "tel"
            |> Form.withTransformer normalizePhone
            |> Form.withPlaceholder "555-123-4567"
        ]


view : Model -> Html Msg
view model =
    Html.div [ Attr.class "container" ]
        [ Html.h2 [] [ Html.text "Send Feedback" ]
        , Html.div []
            [ feedbackForm
                |> Form.build model.formValues FormChanged FormSubmitted

            -- Category handled separately as Form library doesn't include select yet
            , Html.div []
                [ Html.label [] [ Html.text "Category" ]
                , Html.select
                    [ Html.Events.onInput categoryFromString
                    , Attr.form "feedback-form"
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
                ]
            ]
        , Html.button
            [ Attr.type_ "submit"
            , Attr.form "feedback-form"
            ]
            [ Html.text "Submit" ]
        , viewSubmitted model.submitted
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


viewSubmitted : Maybe (Dict String String) -> Html msg
viewSubmitted maybeValues =
    case maybeValues of
        Nothing ->
            Html.text ""

        Just values ->
            Html.div [ Attr.class "submitted" ]
                [ Html.h3 [] [ Html.text "Submitted:" ]
                , Html.ul []
                    (values
                        |> Dict.toList
                        |> List.map
                            (\( key, value ) ->
                                Html.li []
                                    [ Html.strong [] [ Html.text (key ++ ": ") ]
                                    , Html.text value
                                    ]
                            )
                    )
                ]
