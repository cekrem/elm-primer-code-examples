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
    , fetchLgtmPhrase GotPhrase
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
    = ClickedNewPhrase
    | GotPhrase (Result Error String)
    | ClickedCopy


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedNewPhrase ->
            ( { model | phrase = Loading }, fetchLgtmPhrase GotPhrase )

        GotPhrase result ->
            case result of
                Ok newPhrase ->
                    ( { model | phrase = Success newPhrase }, Cmd.none )

                Err err ->
                    ( { model | phrase = Error err }, Cmd.none )

        ClickedCopy ->
            -- We'll implement clipboard access in Chapter 8 when we cover JavaScript interop
            ( model, Cmd.none )



-- CMD


fetchLgtmPhrase : (Result Error String -> Msg) -> Cmd Msg
fetchLgtmPhrase toMsg =
    Http.get
        { url = "http://localhost:3000/lgtm"
        , expect = Http.expectString toMsg
        }



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.span
            [ Events.onClick ClickedCopy
            ]
            [ viewPhrase model.phrase ]
        , Html.span
            [ Events.onClick ClickedNewPhrase
            , Attributes.style "border" "thin solid black"
            , Attributes.style "cursor" "pointer"
            ]
            [ Html.text "⟳" ]
        ]


viewPhrase : Phrase -> Html Msg
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
