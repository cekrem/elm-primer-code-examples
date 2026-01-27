module Api exposing (Submittable, submit)

import Dict exposing (Dict)


type alias Submittable =
    Dict String String


submit : Submittable -> Cmd msg
submit data =
    let
        _ =
            Debug.log "submit data" data
    in
    -- TODO:
    Cmd.none
