module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Set exposing (Set)
import Task
import Time



-- PROGRAM


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { today = Unset
      , openSlots = Set.empty
      }
    , Task.perform GotDay getDay
    )



-- MODEL


type alias Model =
    { today : Day
    , openSlots : Set Int
    }


type Day
    = Advent Int
    | Christmas
    | Other
    | Unset


type Gift
    = Available Char
    | NotYet
    | None


adventDays : List Int
adventDays =
    List.range 1 24


allGifts : Dict Int Char
allGifts =
    "That_nice_dress_you_like"
        |> String.toList
        |> List.indexedMap (\i char -> ( i + 1, char ))
        |> Dict.fromList


giftsForToday : Day -> Dict Int Gift
giftsForToday day =
    case day of
        Unset ->
            allGifts
                |> Dict.map (\_ _ -> NotYet)

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
    = GotDay Day
    | ToggleGiftSlotOpen Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        GotDay day ->
            ( { model | today = day }, Cmd.none )



-- CMD


getDay : Task.Task x Day
getDay =
    Task.map2 initDay Time.here Time.now


initDay : Time.Zone -> Time.Posix -> Day
initDay zone time =
    let
        month : Time.Month
        month =
            Time.toMonth zone time
    in
    case month of
        Time.Dec ->
            let
                day : Int
                day =
                    Time.toDay zone time
            in
            if day > 23 then
                Christmas

            else
                Advent day

        _ ->
            Other



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
        [ Attr.class "flex flex-wrap gap-[8vw] sm:gap-[2vmin]"
        , Attr.class "justify-center items-center"
        , Attr.class "min-w-[100vw] min-h-[100vh]"
        , Attr.class "p-[4vmin]"
        , Attr.class "text-[16vw] sm:text-[8vmin]"
        , Attr.class "font-mono font-bold"
        , Attr.class "bg-[#753D92]"
        , Attr.class "overflow-y-auto"
        ]
        (viewHeader
            :: viewDay today
            :: (adventDays
                    |> List.map
                        (\num ->
                            viewGiftSlot num (isOpen num) (getGift num) (ToggleGiftSlotOpen num)
                        )
               )
        )


viewHeader : Html msg
viewHeader =
    Html.div
        [ Attr.class "w-full sm:h-[16vmin] text-center text-white"
        ]
        [ Html.text "Advent 2025" ]


viewDay : Day -> Html msg
viewDay day =
    Html.div
        [ Attr.class "w-3/4 sm:w-[88vmin] sm:h-[16vmin]"
        , Attr.class "flex items-center justify-center"
        , Attr.class "bg-[#D23B3B] text-white"
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
                    "Wait until December!"

                Unset ->
                    "..."
        ]


viewGiftSlot : Int -> Bool -> Gift -> msg -> Html msg
viewGiftSlot number open gift onToggle =
    let
        clickable : List (Html.Attribute msg)
        clickable =
            [ Events.onClick onToggle
            , Attr.class "hover:scale-110"
            , Attr.class "cursor-pointer"
            ]

        dynamicAttrs : List (Html.Attribute msg)
        dynamicAttrs =
            case ( open, gift ) of
                ( True, _ ) ->
                    Attr.class "text-[#F8CAFF] bg-[#2B0A36] border-[#D23B3B]" :: clickable

                ( _, Available _ ) ->
                    Attr.class "text-white bg-[#44134C] border-transparent" :: clickable

                _ ->
                    [ Attr.class "text-[#372D3B] bg-[#AC85B3] border-transparent" ]
    in
    Html.div
        ([ Attr.class "flex justify-center items-center"
         , Attr.class "h-[24vh] w-1/3 sm:size-[16vmin]"
         , Attr.class "rounded-xl"
         , Attr.class "select-none"
         , Attr.class "border-dashed border-4"
         , Attr.class "transition-all"
         ]
            ++ dynamicAttrs
        )
        (if open then
            [ viewGiftContent gift ]

         else
            [ number |> String.fromInt |> Html.text
            ]
        )


viewGiftContent : Gift -> Html msg
viewGiftContent gift =
    case gift of
        Available content ->
            Html.span [] [ Html.text <| String.fromChar content ]

        NotYet ->
            Html.span [ Attr.class "opacity-30" ] [ Html.text "?" ]

        None ->
            Html.span [ Attr.class "opacity-30" ] [ Html.text "?!" ]
