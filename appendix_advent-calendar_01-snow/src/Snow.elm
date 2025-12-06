module Snow exposing (State, initState, subscription, view)

import Browser.Events
import Html exposing (Html)
import Html.Attributes as Attr


type State
    = Idle
    | Snowing Int


initState : State
initState =
    Idle


nextState : State -> State
nextState state =
    case state of
        Snowing counter ->
            Snowing (counter + 1)

        Idle ->
            Snowing 0


view : State -> Html msg
view state =
    let
        counter =
            case state of
                Idle ->
                    0

                Snowing c ->
                    c
    in
    Html.div
        [ Attr.class "fixed top-0 left-0 size-full pointer-events-none z-99" ]
        (List.range 0 23 |> List.map (snowFlake counter))



-- SNOWFLAKE


snowFlake : Int -> Int -> Html msg
snowFlake counter index =
    let
        config =
            snowFlakeConfig counter index
    in
    Html.div
        [ Attr.class "absolute rounded-full h-[10vh] line-height-1 text-white text-[10vh]"
        , Attr.style "left" (pct config.x)
        , Attr.style "top" (vh config.y)
        , Attr.style "transform" (transform config)
        , Attr.style "opacity" (String.fromFloat config.opacity)
        ]
        [ Html.text "*" ]


type alias SnowFlakeConfig =
    { x : Float
    , y : Float
    , drift : Float
    , rotation : Float
    , scale : Float
    , opacity : Float
    }


snowFlakeConfig : Int -> Int -> SnowFlakeConfig
snowFlakeConfig counter index =
    let
        seed =
            index * 1337 + 1001

        speed =
            0.8 + vary seed 40 / 100

        phase =
            vary seed 200

        progress =
            loop 220 (toFloat counter * speed + phase)

        y =
            progress - 10

        x =
            toFloat index / 24 * 100

        drift =
            sin (progress / 30) * (vary seed 50 + 20)

        rotation =
            progress * 2

        scale =
            0.5 + vary seed 500 / 500 * 0.5

        opacity =
            if y < 0 then
                1 + y / 10

            else if y > 200 then
                1 - (y - 200) / 10

            else
                scale
    in
    { x = x
    , y = y
    , drift = drift
    , rotation = rotation
    , scale = scale
    , opacity = opacity
    }



-- HELPERS


vary : Int -> Int -> Float
vary seed range =
    toFloat (modBy range seed)


loop : Int -> Float -> Float
loop range value =
    let
        cycles =
            floor (value / toFloat range)
    in
    value - toFloat (cycles * range)


pct : Float -> String
pct value =
    String.fromFloat value ++ "%"


vh : Float -> String
vh value =
    String.fromFloat value ++ "vh"


transform : SnowFlakeConfig -> String
transform config =
    "translateX("
        ++ String.fromFloat config.drift
        ++ "px) rotate("
        ++ String.fromFloat config.rotation
        ++ "deg) scale("
        ++ String.fromFloat config.scale
        ++ ")"


subscription : (State -> msg) -> State -> Sub msg
subscription toMsg state =
    Browser.Events.onAnimationFrame (\_ -> toMsg (nextState state))
