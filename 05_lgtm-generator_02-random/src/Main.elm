module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Random



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


-- REVIEW-TECH: Should be `( Model, Cmd Msg )` not `( { phrase : String }, Cmd msg )` to match chapter text and Browser.element convention
init : () -> ( { phrase : String }, Cmd msg )
init () =
    ( { phrase = defaultPhrase
      }
    , Cmd.none
    )


type alias Model =
    { phrase : String
    }



-- UPDATE


type Msg
    = ClickedNewPhrase
    | GotPhrase String
    | ClickedCopy


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedNewPhrase ->
            ( model, Random.generate GotPhrase phraseGenerator )

        GotPhrase newPhrase ->
            ( { model | phrase = newPhrase }, Cmd.none )

        ClickedCopy ->
            -- We'll implement clipboard access in Chapter 8 when we cover JavaScript interop
            ( model, Cmd.none )


defaultPhrase : String
defaultPhrase =
    "Looks Good To Me 👍"


otherPhrases : List String
otherPhrases =
    [ "Let's Go To Mars 🚀"
    , "Love Grows Through Mistakes 💚"
    , "Learning Goes Through Making 📚"
    , "Life's Good, Trust Me ✨"
    , "Let's Get This Merged 🎯"
    , "Lovely Green Tea Moment 🍵"
    , "Lunch Gathering This Monday 🍽️"
    , "Legendary Groundbreaking Technical Marvel 🏆"
    , "Let's Grab Tacos, Maybe? 🌮"
    , "Laughing Genuinely This Much 😄"
    , "Late Game Team Move ♟️"
    , "Loops Getting Too Meta 🌀"
    , "Lighthouse Guiding Through Midnight 🏮"
    , "Literally Going Through Masterpiece 🎨"
    ]


phraseGenerator : Random.Generator String
phraseGenerator =
    Random.uniform
        defaultPhrase
        otherPhrases



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.span
            [ Events.onClick ClickedCopy
            ]
            [ Html.text model.phrase ]
        , Html.span
            [ Events.onClick ClickedNewPhrase
            , Attributes.style "border" "thin solid black"
            , Attributes.style "cursor" "pointer"
            ]
            [ Html.text "⟳" ]
        ]
