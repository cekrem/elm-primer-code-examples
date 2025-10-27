module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http exposing (Error(..))



-- ENTRYPOINT


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


init : () -> ( Model, Cmd Msg )
init () =
    ( { phrase = Loading
      }
    , fetchLgtmPhrase
    )


type alias Model =
    { phrase : Phrase
    }


type Phrase
    = Loading
    | Success String
    | Error Error



-- UPDATE


type Msg
    = ChangePhrase
    | GotPhrase (Result Error String)
    | CopyToClipboard


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangePhrase ->
            ( model, fetchLgtmPhrase )

        GotPhrase result ->
            case result of
                Ok newPhrase ->
                    ( { model | phrase = Success newPhrase }, Cmd.none )

                Err err ->
                    ( { model | phrase = Error err }, Cmd.none )

        CopyToClipboard ->
            -- We'll implement clipboard access in Chapter 8 when we cover JavaScript interop
            ( model, Cmd.none )


fetchLgtmPhrase : Cmd Msg
fetchLgtmPhrase =
    Http.get
        { url = "http://localhost:3000/lgtm"
        , expect = Http.expectString GotPhrase
        }



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.span
            [ Events.onClick CopyToClipboard
            ]
            [ viewPhrase model.phrase ]
        , Html.span
            [ Events.onClick ChangePhrase
            , Attributes.style "border" "thin solid black"
            , Attributes.style "cursor" "pointer"
            ]
            [ Html.text "⟳" ]
        ]


viewPhrase : Phrase -> Html msg
viewPhrase phrase =
    let
        string =
            case phrase of
                Success p ->
                    p

                Loading ->
                    "Loading..."

                Error err ->
                    case err of
                        BadStatus status ->
                            status
                                |> String.fromInt
                                |> String.append "Http error: "

                        _ ->
                            "Unknown error"
    in
    Html.text string
