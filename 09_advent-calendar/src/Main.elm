module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Set exposing (Set)



-- PROGRAM


main : Program () Model Msg
main =
    Browser.element
        { init = always ( { today = Advent 24, openSlots = Set.empty }, Cmd.none )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    { today : Day
    , openSlots : Set Int
    }


type Day
    = Advent Int
    | Christmas
    | Other


type Gift
    = Available Char
    | NotYet
    | None


adventDays : List Int
adventDays =
    List.range 1 24


allGifts : Dict Int Char
allGifts =
    "Video_fra_vårt_bryllup🥳🎄"
        |> String.toList
        |> List.indexedMap (\i char -> ( i + 1, char ))
        |> Dict.fromList


giftsForToday : Day -> Dict Int Gift
giftsForToday day =
    let
        _ =
            Debug.log "giftsForToday called" ()
    in
    case day of
        Other ->
            allGifts
                |> Dict.map (\_ _ -> NotYet)

        Advent today ->
            allGifts
                |> Dict.map
                    (\d gift ->
                        if today >= d then
                            Available gift

                        else
                            NotYet
                    )

        Christmas ->
            allGifts
                |> Dict.map (\_ gift -> Available gift)



-- MSG


type Msg
    = Noop
    | ToggleGiftSlotOpen Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        ToggleGiftSlotOpen num ->
            let
                transform : Int -> Set Int -> Set Int
                transform =
                    if model.openSlots |> Set.member num then
                        Set.remove

                    else
                        Set.insert
            in
            ( { model | openSlots = model.openSlots |> transform num }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view { today, openSlots } =
    let
        gifts : Dict Int Gift
        gifts =
            giftsForToday today

        getGift : Int -> Gift
        getGift day =
            gifts
                |> Dict.get day
                |> Maybe.withDefault None

        isOpen : Int -> Bool
        isOpen day =
            openSlots |> Set.member day
    in
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-wrap" "wrap"
        , Attr.style "gap" "1rem"
        , Attr.style "height" "100vh"
        , Attr.style "width" "100vw"
        , Attr.style "overflow-x" "scroll"
        , Attr.style "font-size" "10vw"
        , Attr.style "box-sizing" "border-box"
        , Attr.style "padding" "1rem"
        , Attr.style "justify-content" "space-around"
        , Attr.style "background" "blue"
        ]
        (adventDays
            |> List.map
                (\num ->
                    giftSlot num (isOpen num) (getGift num) (ToggleGiftSlotOpen num)
                )
        )


giftSlot : Int -> Bool -> Gift -> msg -> Html msg
giftSlot number open gift onToggle =
    let
        ( background, fontColor, border ) =
            if open then
                ( "white", "red", "thick dotted gray" )

            else
                ( "red", "white", "none" )
    in
    Html.div
        [ Attr.style "width" "16vw"
        , Attr.style "height" "16vw"
        , Attr.style "box-sizing" "border-box"
        , Attr.style "padding" "0"
        , Attr.style "display" "flex"
        , Attr.style "justify-content" "center"
        , Attr.style "align-items" "center"
        , Attr.style "text-align" "center"
        , Attr.style "font-family" "monospace"
        , Attr.style "font-weight" "bold"
        , Attr.style "border-radius" "0.25rem"
        , Attr.style "user-select" "none"
        , Attr.style "cursor" "pointer"

        -- Dynamic stuff
        , Attr.style "transition" "all 0.1s linear"
        , Attr.style "background" background
        , Attr.style "color" fontColor
        , Attr.style "border" border
        , Events.onClick onToggle
        ]
        (if open then
            [ giftContent gift ]

         else
            [ number |> String.fromInt |> Html.text
            ]
        )


giftContent : Gift -> Html msg
giftContent gift =
    case gift of
        Available content ->
            Html.text <| String.fromChar content

        NotYet ->
            Html.text "❌"

        None ->
            Html.text "⁉️"
