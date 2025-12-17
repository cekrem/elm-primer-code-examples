module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Form
import Html exposing (Html)
import Html.Attributes as Attr


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


type alias Model =
    { formValues : Dict String String
    , submitted : Maybe (Dict String String)
    }


type Msg
    = FormChanged (Dict String String)
    | FormSubmitted


init : Model
init =
    { formValues = Dict.empty
    , submitted = Nothing
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged values ->
            { model | formValues = values }

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
    Form.new [ Attr.class "feedback-form" ]
        [ Form.input "name" "Full Name"
            |> Form.withRequired True
            |> Form.withTransformer String.trim
            |> Form.withPlaceholder "Jane Doe"

        , Form.input "email" "Email Address"
            |> Form.withType "email"
            |> Form.withRequired True
            |> Form.withValidator emailValidator
            |> Form.withPlaceholder "you@example.com"

        , Form.input "phone" "Phone (optional)"
            |> Form.withType "tel"
            |> Form.withTransformer normalizePhone
            |> Form.withPlaceholder "555-123-4567"

        , Form.input "message" "Message"
            |> Form.withRequired True
            |> Form.withValidator (minLength 10)
            |> Form.withPlaceholder "Tell us what's on your mind..."
        ]


view : Model -> Html Msg
view model =
    Html.div [ Attr.class "container" ]
        [ Html.h2 [] [ Html.text "Send Feedback" ]
        , feedbackForm
            |> Form.build model.formValues FormChanged FormSubmitted
        , viewSubmitted model.submitted
        ]


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
