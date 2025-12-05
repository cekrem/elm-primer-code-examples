module Snow exposing (State, initState, subscription, view)

import Html exposing (Html, progress)
import Html.Attributes as Attr
import Time


type State
    = Idle
    | Snowing (List SnowFlake)


type SnowFlake
    = Entry Int
    | Middle Int
    | End Int


initState : State
initState =
    Idle


nextState : Int -> State -> State
nextState globalSeed state =
    case state of
        Snowing snowFlakes ->
            Snowing
                (snowFlakes
                    |> List.indexedMap (\i snow -> snow |> nextSnowFlake (globalSeed * i))
                )

        Idle ->
            Snowing
                (List.repeat 24 ()
                    |> List.indexedMap
                        (\i () ->
                            let
                                snowSeed =
                                    globalSeed * i
                            in
                            case snowSeed |> modBy 3 of
                                0 ->
                                    Entry snowSeed

                                1 ->
                                    Middle snowSeed

                                _ ->
                                    End snowSeed
                        )
                )


nextSnowFlake : Int -> SnowFlake -> SnowFlake
nextSnowFlake seed progress =
    case progress of
        Entry prev ->
            Middle <| seed + prev

        Middle prev ->
            End <| seed + prev

        End prev ->
            Entry <| seed + prev


variations : Int -> { degrees : Int, offset : Float }
variations seed =
    let
        offset =
            seed
                |> modBy 500
                |> toFloat
                |> (*) (1 / 499)

        degrees =
            seed
                |> modBy 360
    in
    { offset = offset, degrees = degrees }


view : State -> Html msg
view state =
    let
        snowFlakes =
            case state of
                Idle ->
                    []

                Snowing s ->
                    s
    in
    Html.div
        [ Attr.class "fixed top-0 left-0 size-full pointer-events-none z-99"
        ]
        (snowFlakes |> List.indexedMap snowFlake)


snowFlake : Int -> SnowFlake -> Html msg
snowFlake index snowState =
    let
        pos =
            Attr.class <| "left-" ++ String.fromInt (index |> modBy 12) ++ "/12"

        attrs =
            case snowState of
                Entry seed ->
                    variations seed
                        |> (\{ offset, degrees } ->
                                [ Attr.class "top-0 opacity-0"
                                , Attr.class <| "rotate-" ++ String.fromInt degrees
                                , Attr.class <| "scale-[" ++ String.fromFloat (offset * 100) ++ "%]"
                                ]
                           )

                Middle seed ->
                    variations seed
                        |> (\{ offset, degrees } ->
                                [ Attr.class "top-100"
                                , Attr.class <| "rotate-" ++ String.fromInt degrees
                                , Attr.class <| "scale-[" ++ String.fromFloat (offset * 100) ++ "%]"
                                ]
                           )

                End seed ->
                    variations seed
                        |> (\{ offset, degrees } ->
                                [ Attr.class "top-200 opacity-0"
                                , Attr.class <| "rotate-" ++ String.fromInt degrees
                                , Attr.class <| "scale-[" ++ String.fromFloat (offset * 100) ++ "%]"
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
    prev |> nextState (Time.posixToMillis timestamp)


subscription : (State -> msg) -> State -> Sub msg
subscription toMsg state =
    Time.every 500 (stateFromTime state >> toMsg)
