module Calendar exposing (..)

import Dict exposing (Dict)
import Task
import Time


type Gifts availability
    = Gifts (Dict Int Char)


type Available
    = Available Never


initGifts : String -> Gifts all
initGifts phrase =
    phrase
        |> String.toList
        |> List.indexedMap
            (\i char ->
                ( i + 1
                , if Char.isAlphaNum char then
                    char

                  else
                    '_'
                )
            )
        |> List.take 24
        |> Dict.fromList
        |> Gifts


type Day
    = Advent Int
    | Christmas
    | Other
    | Unset


label : Day -> String
label day =
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


isChristmas : Day -> Bool
isChristmas day =
    day == Christmas


isWrongMonth : Day -> Bool
isWrongMonth day =
    day == Other


initDay : Day
initDay =
    Unset


availableNow : Day -> Gifts any -> Gifts Available
availableNow day (Gifts gifts) =
    Gifts
        (case day of
            Advent num ->
                gifts
                    |> Dict.filter (\key _ -> key <= num)

            Christmas ->
                gifts

            Other ->
                Dict.empty

            Unset ->
                Dict.empty
        )


forDay : Int -> Gifts Available -> Maybe Char
forDay num (Gifts gifts) =
    gifts
        |> Dict.get num


adventDays : List Int
adventDays =
    List.range 1 24



-- CMD


getDayCmd : (Day -> msg) -> Cmd msg
getDayCmd toMsg =
    Task.perform toMsg (Task.map2 currentDay Time.here Time.now)


currentDay : Time.Zone -> Time.Posix -> Day
currentDay zone time =
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
            if day > 24 then
                Christmas

            else
                Advent day

        _ ->
            Other
