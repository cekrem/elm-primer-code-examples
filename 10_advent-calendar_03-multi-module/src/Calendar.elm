module Calendar exposing (Available, Day, Gifts, adventDays, availableNow, forDay, getDayCmd, initDay, initGifts, isChristmas, isWrongMonth, label)

{-| Calendar module for Advent Calendar application.

This module demonstrates organizing code around data structures and using
phantom types to enforce compile-time safety.

Key patterns:
- Opaque types: Day constructors are NOT exported, preventing invalid construction
- Phantom types: Gifts uses a type parameter to track availability at compile-time
- Smart constructors: Only safe ways to create Days are exposed

-}

import Dict exposing (Dict)
import Task
import Time



-- GIFTS


{-| Gifts with phantom type parameter for tracking availability.

The `availability` parameter is a phantom type - it doesn't appear in the
actual data structure (Dict Int Char), but it tracks state at the type level.

This lets us prevent calling `forDay` on gifts that haven't been filtered
through `availableNow` yet. The compiler enforces the workflow:
  allGifts : Gifts all
  -> availableNow : Gifts all -> Gifts Available
  -> forDay : Gifts Available -> Maybe Char

-}
type Gifts availability
    = Gifts (Dict Int Char)


{-| Phantom type marker for available gifts.

This type uses `Never` (Elm's uninhabitable type) to make it impossible to
construct. It exists purely as a type-level marker. You can't create an
`Available` value, but you can use it as a type parameter.

This is what makes `Gifts Available` different from `Gifts all` at compile-time.
-}
type Available
    = Available Never


{-| Initialize gifts from a phrase.

Takes any string and converts it to a Dict of 24 gifts (one per Advent day).
Non-alphanumeric characters become underscores, enforcing the domain constraint
that advent calendars have exactly 24 days.

Returns `Gifts all` - these gifts haven't been filtered by availability yet.
-}
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



-- DAY


{-| Represents different calendar states.

Note: The constructors are NOT exported! Other modules can use the Day type
in signatures, but can't construct or pattern match on Days directly.
This prevents invalid dates like `Advent -5` or `Advent 99`.

The only way to get a Day is through `initDay` or `getDayCmd`.
-}
type Day
    = Advent Int
    | Christmas
    | Other
    | Unset


{-| Convert a Day to a human-readable label for display. -}
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


{-| Domain predicate: check if it's Christmas. -}
isChristmas : Day -> Bool
isChristmas day =
    day == Christmas


{-| Domain predicate: check if we're outside December. -}
isWrongMonth : Day -> Bool
isWrongMonth day =
    day == Other


{-| Initial Day state before we've fetched the real date. -}
initDay : Day
initDay =
    Unset


{-| Filter gifts by current day, returning only available ones.

This is the key function that narrows the type from `Gifts any` to `Gifts Available`.
After calling this, you can use `forDay` to safely access individual gifts.

The phantom type prevents you from calling `forDay` on unfiltered gifts:
  forDay 1 allGifts        -- Type error! allGifts is `Gifts all`
  forDay 1 (availableNow day allGifts)  -- Works! Result is `Gifts Available`
-}
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


{-| Get the gift for a specific day.

Note the type signature: this ONLY accepts `Gifts Available`, not `Gifts all`.
The compiler enforces that you must call `availableNow` first.
-}
forDay : Int -> Gifts Available -> Maybe Char
forDay num (Gifts gifts) =
    gifts
        |> Dict.get num


{-| All 24 days of Advent. -}
adventDays : List Int
adventDays =
    List.range 1 24



-- CMD


{-| Create a Cmd that fetches the current day.

This is a "smart constructor" for Days - the only safe way to get a real Day value.
It guarantees validity by computing the Day from the system time, preventing
invalid dates like `Advent -5` or `Advent 99`.

Usage:
  init : () -> ( Model, Cmd Msg )
  init () =
    ( initialModel, getDayCmd GotDay )
-}
getDayCmd : (Day -> msg) -> Cmd msg
getDayCmd toMsg =
    Task.perform toMsg (Task.map2 currentDay Time.here Time.now)


{-| Convert system time to a Day.

This is NOT exported - it's an internal helper that getDayCmd uses.
By keeping this private, we ensure the only way to get a Day is through
the controlled getDayCmd function.
-}
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
