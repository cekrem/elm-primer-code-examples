module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


-- MODEL


type alias Model =
    { count : Int
    , history : List Int
    }


init : Model
init =
    { count = 0
    , history = []
    }


-- MSG


type Msg
    = Increment
    | Decrement
    | Undo
    | Reset


-- UPDATE


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { count = model.count + 1
            , history = model.count :: model.history
            }

        Decrement ->
            { count = model.count - 1
            , history = model.count :: model.history
            }

        Undo ->
            case model.history of
                [] ->
                    model

                previousCount :: rest ->
                    { count = previousCount
                    , history = rest
                    }

        Reset ->
            init


-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ button [ onClick Decrement ] [ text "-" ]
            , div [] [ text (String.fromInt model.count) ]
            , button [ onClick Increment ] [ text "+" ]
            ]
        , div []
            [ button [ onClick Undo ] [ text "Undo" ]
            , button [ onClick Reset ] [ text "Reset" ]
            ]
        , div [] [ text ("History: " ++ String.fromInt (List.length model.history) ++ " items") ]
        ]


-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
