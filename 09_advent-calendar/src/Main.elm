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
        { init = always ( { today = Advent 2, openSlots = Set.empty }, Cmd.none )
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
        [ Attr.class "flex flex-wrap gap-[2vw]"
        , Attr.class "justify-center items-center"
        , Attr.class "min-w-[100vw] min-h-[100vh]"
        , Attr.class "p-4"
        , Attr.class "text-[8vw]"
        , Attr.class "font-mono font-bold"
        , Attr.class "bg-blue-700"
        ]
        (viewHeader
            :: viewDay today
            :: (adventDays
                    |> List.map
                        (\num ->
                            giftSlot num (isOpen num) (getGift num) (ToggleGiftSlotOpen num)
                        )
               )
        )


viewHeader : Html msg
viewHeader =
    Html.div
        [ Attr.class "w-full h-[16vw] text-center"
        ]
        [ Html.text "Advent 2025" ]


viewDay : Day -> Html msg
viewDay day =
    Html.div
        [ Attr.class "w-[52vmin] h-[16vw]"
        , Attr.class "flex items-center justify-center"
        , Attr.class "bg-green-300"
        , Attr.class "rounded-xl"
        , Attr.class "text-center"
        , Attr.class "text-[0.5em]"
        ]
        [ Html.text <|
            case day of
                Christmas ->
                    "Christmas🎄"

                Advent num ->
                    num
                        |> String.fromInt
                        |> String.append "December "

                Other ->
                    "Wrong month! ❌"
        ]


giftSlot : Int -> Bool -> Gift -> msg -> Html msg
giftSlot number open gift onToggle =
    let
        dynamicClass =
            if open then
                Attr.class "text-red-700 bg-white border-red-700"

            else
                Attr.class "text-white bg-red-700 border-transparent"
    in
    Html.div
        [ Attr.class "flex justify-center items-center"
        , Attr.class "size-[16vw]"
        , Attr.class "rounded-xl"
        , Attr.class "select-none"
        , Attr.class "cursor-pointer"
        , Attr.class "border-dashed border-4"

        -- Dynamic stuff
        , Attr.class "transition-all"
        , dynamicClass
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
