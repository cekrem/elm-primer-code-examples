module Api exposing (Step(..), Submittable, submit)

import Dict exposing (Dict)


type Step model
    = Continue model
    | Done Submittable


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
