module Group exposing (group)


group : List a -> List (List a)
group list =
    case list of
        [] ->
            []

        first :: rest ->
            case group rest of
                (next :: others) :: groups ->
                    if first == next then
                        (first :: next :: others) :: groups

                    else
                        [ first ] :: (next :: others) :: groups

                _ ->
                    [ [ first ] ]
