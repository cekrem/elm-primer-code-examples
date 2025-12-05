module Snow exposing (State, initState, subscription, view)

import Html exposing (Html, progress)
import Html.Attributes as Attr
import Time


type State
    = Idle
    | Entry Int
    | Middle Int
    | End Int


initState : State
initState =
    Idle


next : Int -> State -> State
next seed progress =
    case progress of
        Idle ->
            Entry seed

        Entry _ ->
            Middle seed

        Middle _ ->
            End seed

        End _ ->
            Entry seed


transposedData : Int -> Int -> { degrees : Int, offset : Float, translate : Int }
transposedData index seed =
    let
        offset =
            seed
                |> (*) (1 + index)
                |> modBy 500
                |> toFloat
                |> (*) (1 / 499)

        degrees =
            seed
                |> (*) (2 + index)
                |> modBy 360

        translate =
            (toFloat index * 0.1 * offset * toFloat degrees) |> floor
    in
    { offset = offset, degrees = degrees, translate = translate }


view : State -> Html msg
view state =
    Html.div
        [ Attr.class "fixed top-0 left-0 size-full pointer-events-none z-99"
        ]
        (List.repeat 12 ()
            |> List.indexedMap
                (\index () ->
                    snowFlake index state
                )
        )


snowFlake : Int -> State -> Html msg
snowFlake index state =
    let
        pos =
            Attr.class <| "left-" ++ String.fromInt index ++ "/12"

        attrs =
            case state of
                Idle ->
                    [ Attr.class "hidden" ]

                Entry seed ->
                    transposedData index seed
                        |> (\{ offset, degrees, translate } ->
                                [ Attr.class "top-0 opacity-0"
                                , Attr.class <| "rotate-" ++ String.fromInt degrees
                                , Attr.class <| "scale-[" ++ String.fromFloat (offset * 100) ++ "%]"
                                , Attr.class <| "p-[" ++ String.fromInt translate ++ "%]"
                                ]
                           )

                Middle seed ->
                    transposedData index seed
                        |> (\{ offset, degrees, translate } ->
                                [ Attr.class "top-60"
                                , Attr.class <| "rotate-" ++ String.fromInt degrees
                                , Attr.class <| "scale-[" ++ String.fromFloat (offset * 100) ++ "%]"
                                , Attr.class <| "mt-[" ++ String.fromInt translate ++ "vmax]"
                                ]
                           )

                End seed ->
                    transposedData index seed
                        |> (\{ offset, degrees, translate } ->
                                [ Attr.class "top-140 opacity-0"
                                , Attr.class <| "rotate-" ++ String.fromInt degrees
                                , Attr.class <| "scale-[" ++ String.fromFloat (offset * 100) ++ "%]"
                                , Attr.class <| "mt-[" ++ String.fromInt translate ++ "%]"
                                ]
                           )
    in
    Html.div
        (Attr.class "absolute rounded-full mt-[-10vh] h-[10vh] line-height-1"
            :: Attr.class "text-white text-[10vh]"
            :: Attr.class "transition-all duration-500 ease-linear"
            :: pos
            :: attrs
        )
        [ Html.text "*" ]


stateFromTime : State -> Time.Posix -> State
stateFromTime prev timestamp =
    prev |> next (Time.posixToMillis timestamp)


subscription : (State -> msg) -> State -> Sub msg
subscription toMsg state =
    Time.every 500 (stateFromTime state >> toMsg)
