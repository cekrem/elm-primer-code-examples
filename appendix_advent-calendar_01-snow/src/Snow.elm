module Snow exposing (Progress, initState, subscription, view)

import Html exposing (Html, progress, time)
import Html.Attributes as Attr
import Time


type Progress
    = Idle
    | Motion Float


initState : Progress
initState =
    Idle


view : Progress -> Html msg
view progress =
    case progress of
        Idle ->
            Html.text ""

        Motion state ->
            Html.div
                [ Attr.class "fixed top-0 left-0 size-full pointer-events-none z-99"
                ]
                [ snowFlake state 0
                ]


snowFlake : Float -> Int -> Html msg
snowFlake progress offset =
    let
        marginTop =
            (progress * 100) |> String.fromFloat
    in
    Html.span
        [ Attr.class "absolute rounded-full size-2"
        , Attr.class "text-white opacity-80"
        , Attr.class "animate-pulse"
        , Attr.style "top" "10rem"
        ]
        [ Html.text "*" ]


stateFromTime : Time.Posix -> Progress
stateFromTime timestamp =
    let
        progress =
            (Time.posixToMillis timestamp // 1000)
                |> modBy 8
                |> toFloat
                |> (*) (1 / 7)
    in
    Motion progress


subscription : (Progress -> msg) -> Sub msg
subscription toMsg =
    Time.every 1000 (stateFromTime >> toMsg)
