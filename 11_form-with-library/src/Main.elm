module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Form
import Html exposing (Html)
import Html.Attributes as Attr


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }


type alias Model =
    { formValues : Dict String String }


initialModel : Model
initialModel =
    { formValues = Dict.empty }


type Msg
    = FormChanged (Dict String String)
    | Submit


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged values ->
            { model | formValues = values }

        Submit ->
            Debug.log "submit" model


view : Model -> Html Msg
view model =
    Form.new
        [ Attr.class "flex flex-col gap-4 max-w-md mx-auto"
        , Attr.class "bg-gray-100 p-4 rounded"
        ]
        [ Form.input "name" "Name"
            |> Form.withPlaceholder "Name"
        , Form.input "email" "Email"
            |> Form.withPlaceholder "Email"
            |> Form.withValidator emailValidator
        , Form.input "phone" "Phone"
            |> Form.withPlaceholder "Phone"
            |> Form.withType "tel"
            |> Form.withTransformer (String.filter Char.isDigit)
        , Form.input "message" "Message"
            |> Form.withPlaceholder "Message"
        ]
        |> Form.withSubmitButton "Submit" []
        |> Form.build model.formValues FormChanged Submit


emailValidator : String -> Result (List (Html.Attribute msg)) ()
emailValidator email =
    if email == "" || String.contains "@" email then
        Ok ()

    else
        Err errAttrs


errAttrs : List (Html.Attribute msg)
errAttrs =
    [ Attr.class "bg-red-500", Attr.attribute "aria-invalid" "true" ]
