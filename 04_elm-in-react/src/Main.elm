module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events



-- ENTRYPOINT


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


init : Model
init =
    { phrase = "Looks Good To Me"
    }


type alias Model =
    { phrase : String
    }



-- UPDATE


type Msg
    = ChangePhrase
    | CopyToClipboard


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangePhrase ->
            { model | phrase = nextPhrase model.phrase }

        CopyToClipboard ->
            Debug.log "copy to clipboard not implemented yet" model


nextPhrase : String -> String
nextPhrase prevPhrase =
    let
        firstPhrase =
            "Looks Good To Me"

        secondPhrase =
            "Let's Go To Mars"
    in
    if prevPhrase == firstPhrase then
        secondPhrase

    else
        firstPhrase



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.span
            [ Events.onClick CopyToClipboard
            ]
            [ Html.text model.phrase ]
        , Html.span
            [ Events.onClick ChangePhrase
            , Attributes.style "border" "thin solid black"
            , Attributes.style "cursor" "pointer"
            ]
            [ Html.text "⟳" ]
        ]
