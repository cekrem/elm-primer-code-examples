module GroupTests exposing (suite)

import Expect
import Fuzz
import Group exposing (group)
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "group"
        [ describe "base cases"
            [ test "empty list gives empty groups" <|
                \_ ->
                    group []
                        |> Expect.equal []
            , test "single element gives one group" <|
                \_ ->
                    group [ 1 ]
                        |> Expect.equal [ [ 1 ] ]
            ]
        , describe "grouping behavior"
            [ test "different elements form separate groups" <|
                \_ ->
                    group [ 1, 2 ]
                        |> Expect.equal [ [ 1 ], [ 2 ] ]
            , test "consecutive equal elements are grouped together" <|
                \_ ->
                    group [ 1, 1 ]
                        |> Expect.equal [ [ 1, 1 ] ]
            , test "mixed sequence groups correctly" <|
                \_ ->
                    group [ 1, 1, 2, 3, 3, 3, 2, 2 ]
                        |> Expect.equal
                            [ [ 1, 1 ]
                            , [ 2 ]
                            , [ 3, 3, 3 ]
                            , [ 2, 2 ]
                            ]
            ]
        , describe "properties"
            [ fuzz (Fuzz.list Fuzz.int) "flattening groups recovers the original list" <|
                \randomList ->
                    group randomList
                        |> List.concat
                        |> Expect.equal randomList
            , fuzz (Fuzz.list Fuzz.int) "no group is empty" <|
                \randomList ->
                    group randomList
                        |> List.all (\g -> not (List.isEmpty g))
                        |> Expect.equal True
            , fuzz (Fuzz.list Fuzz.int) "elements within each group are identical" <|
                \randomList ->
                    group randomList
                        |> List.all
                            (\g ->
                                case g of
                                    [] ->
                                        False

                                    first :: rest ->
                                        List.all (\x -> x == first) rest
                            )
                        |> Expect.equal True
            ]
        ]
