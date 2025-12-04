module Main exposing (main)

import Browser
import Calendar
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Set exposing (Set)
import Snow



-- PROGRAM


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always (Snow.subscription GotSnow)
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { today = Calendar.initDay
      , openSlots = Set.empty
      , snow = Snow.initState
      }
    , Calendar.getDayCmd GotDay
    )


allGifts : Calendar.Gifts all
allGifts =
    Calendar.initGifts "That dress you like"



-- MODEL


type alias Model =
    { today : Calendar.Day
    , openSlots : Set Int
    , snow : Snow.Progress
    }



-- MSG


type Msg
    = GotDay Calendar.Day
    | GotSnow Snow.Progress
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

        GotSnow snow ->
            ( { model | snow = snow }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view { today, openSlots, snow } =
    let
        gifts : Calendar.Gifts Calendar.Available
        gifts =
            allGifts |> Calendar.availableNow today

        getGift : Int -> Maybe Char
        getGift day =
            gifts |> Calendar.forDay day

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
            :: Snow.view snow
            :: (Calendar.adventDays
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
        [ Html.text "Advent 2025"
        ]


viewDay : Calendar.Day -> Html msg
viewDay day =
    Html.div
        [ Attr.class "w-3/4 sm:w-[88vmin] sm:h-[16vmin]"
        , Attr.class "flex items-center justify-center"
        , Attr.class "bg-[#D23B3B] text-white"
        , Attr.class "rounded-xl"
        , Attr.class "text-center"
        , Attr.class "text-[0.5em]"
        ]
        [ Html.text <| Calendar.label day
        ]


viewGiftSlot : Int -> Bool -> Maybe Char -> msg -> Html msg
viewGiftSlot number open maybeGift onToggle =
    let
        clickable : List (Html.Attribute msg)
        clickable =
            [ Events.onClick onToggle
            , Attr.class "hover:scale-110"
            , Attr.class "cursor-pointer"
            ]

        ( content, dynamicAttrs ) =
            case ( open, maybeGift ) of
                ( True, Just gift ) ->
                    ( String.fromChar gift, Attr.class "text-[#F8CAFF] bg-[#2B0A36] border-[#D23B3B]" :: clickable )

                ( False, Just _ ) ->
                    ( String.fromInt number, Attr.class "text-white bg-[#44134C] border-transparent" :: clickable )

                ( _, Nothing ) ->
                    ( String.fromInt number, [ Attr.class "text-[#372D3B] bg-[#AC85B3] border-transparent" ] )
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
        [ Html.text content ]
