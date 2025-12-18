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
        Err [ Attr.class "border-red-500" ]


minLength : Int -> String -> Result (List (Html.Attribute msg)) ()
minLength n value =
    if String.length value >= n then
        Ok ()

    else
        Err [ Attr.class "border-red-500" ]



-- Transformers


normalizePhone : String -> String
normalizePhone =
    String.filter Char.isDigit



-- View


inputClass : String
inputClass =
    "border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 w-full"


feedbackForm : Form.Form Msg
feedbackForm =
    Form.new
        [ Attr.class "flex flex-col gap-4"
        , Attr.id "feedback-form"
        ]
        [ Form.input "email" "Email"
            |> Form.withType "email"
            |> Form.withRequired True
            |> Form.withValidator emailValidator
            |> Form.withPlaceholder "you@example.com"
            |> Form.withInputClass inputClass
            |> Form.withLabelClass "font-medium"
        , Form.input "message" "Message"
            |> Form.withRequired True
            |> Form.withValidator (minLength 10)
            |> Form.withPlaceholder "Tell us what's on your mind..."
            |> Form.withInputClass inputClass
            |> Form.withLabelClass "font-medium"

        -- Extra fields to show the form scales without boilerplate
        , Form.input "name" "Full Name (optional)"
            |> Form.withTransformer String.trim
            |> Form.withPlaceholder "Jane Doe"
            |> Form.withInputClass inputClass
            |> Form.withLabelClass "font-medium"
        , Form.input "phone" "Phone (optional)"
            |> Form.withType "tel"
            |> Form.withTransformer normalizePhone
            |> Form.withPlaceholder "555-123-4567"
            |> Form.withInputClass inputClass
            |> Form.withLabelClass "font-medium"
        ]


view : Model -> Html Msg
view model =
    Html.div
        [ Attr.class "max-w-md mx-auto p-6" ]
        [ Html.h2
            [ Attr.class "text-2xl font-bold mb-4" ]
            [ Html.text "Send Feedback" ]
        , feedbackForm
            |> Form.build model.formValues FormChanged FormSubmitted
        , Html.label
            [ Attr.class "font-medium mt-4 block" ]
            [ Html.text "Category" ]
        , Html.select
            [ Html.Events.onInput categoryFromString
            , Attr.form "feedback-form"
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
        , Html.button
            [ Attr.type_ "submit"
            , Attr.form "feedback-form"
            , Attr.class "bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700 mt-4"
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
            Html.div
                [ Attr.class "mt-6 p-4 bg-green-50 rounded border border-green-200" ]
                [ Html.h3
                    [ Attr.class "font-bold text-green-800" ]
                    [ Html.text "Submitted:" ]
                , Html.ul
                    [ Attr.class "mt-2" ]
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
