module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Set exposing (Set)



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init defaultOptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { wordToGuess : String
    , guessedLetters : Set Char
    , gameStatus : GameStatus
    }


type GameStatus
    = Playing Int -- This simple Int represents livesRemaining
    | Won
    | Lost


type alias Options =
    { word : String
    , lives : Int
    }


defaultOptions : Options
defaultOptions =
    { word = "FUNCTIONAL"
    , lives = 6
    }


init : Options -> Model
init { word, lives } =
    { wordToGuess = word |> String.toUpper
    , guessedLetters = Set.empty
    , gameStatus = Playing lives
    }



-- UPDATE


type Msg
    = GuessLetter Char
    | NewGame


update : Msg -> Model -> Model
update msg model =
    case ( msg, model.gameStatus ) of
        -- NewGame msg resets game, always
        ( NewGame, _ ) ->
            init defaultOptions

        -- GuessLetter is handled when in `Playing` state
        ( GuessLetter letter, Playing currentLives ) ->
            -- Already guessed this letter? Do nothing
            if model.guessedLetters |> Set.member letter then
                model

            else
                -- New letter guessed? Handle game logic
                let
                    newGuessedLetters =
                        model.guessedLetters |> Set.insert letter

                    isCorrectGuess =
                        model.wordToGuess |> String.contains (letter |> String.fromChar)

                    livesRemaining =
                        if isCorrectGuess then
                            currentLives

                        else
                            currentLives - 1

                    newGameStatus =
                        if
                            model.wordToGuess
                                |> String.toList
                                |> List.all (\correctChar -> newGuessedLetters |> Set.member correctChar)
                        then
                            Won

                        else if livesRemaining <= 0 then
                            Lost

                        else
                            Playing livesRemaining
                in
                { model
                    | guessedLetters = newGuessedLetters
                    , gameStatus = newGameStatus
                }

        -- GuessLetter is a noop when already won
        ( GuessLetter _, Won ) ->
            model

        -- GuessLetter is a noop when already lost
        ( GuessLetter _, Lost ) ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        , Attr.style "align-items" "center"
        , Attr.style "gap" "1rem"
        ]
        [ Html.h1 [] [ Html.text "Hangman" ]
        , viewGameStatus model
        , viewWord model
        , viewLivesRemaining model
        , viewAlphabet model
        , Html.button [ Events.onClick NewGame ] [ Html.text "New Game" ]
        ]


viewGameStatus : Model -> Html Msg
viewGameStatus model =
    case model.gameStatus of
        Playing _ ->
            Html.text ""

        Won ->
            Html.div [] [ Html.text "🎉 You Won!" ]

        Lost ->
            Html.div [] [ Html.text ("😞 Game Over! The word was: " ++ model.wordToGuess) ]


viewWord : Model -> Html Msg
viewWord model =
    let
        displayWord =
            model.wordToGuess
                |> String.toList
                |> List.map
                    (\char ->
                        if model.guessedLetters |> Set.member char then
                            char

                        else
                            '_'
                    )
                |> List.intersperse ' '
                |> String.fromList
    in
    Html.div [] [ Html.text displayWord ]


viewLivesRemaining : Model -> Html Msg
viewLivesRemaining model =
    case model.gameStatus of
        Playing lives ->
            Html.div [] [ Html.text ("Lives remaining: " ++ String.fromInt lives) ]

        _ ->
            Html.text ""


viewAlphabet : Model -> Html Msg
viewAlphabet model =
    let
        isDisabled letter =
            (model.guessedLetters |> Set.member letter)
                || (case model.gameStatus of
                        Playing _ ->
                            False

                        _ ->
                            True
                   )
    in
    Html.div []
        (List.range 65 90
            |> List.map Char.fromCode
            |> List.map
                (\letter ->
                    Html.button
                        [ Events.onClick (GuessLetter letter)
                        , Attr.disabled (isDisabled letter)
                        ]
                        [ Html.text (String.fromChar letter) ]
                )
        )
