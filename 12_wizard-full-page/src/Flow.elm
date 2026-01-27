module Flow exposing (Flow(..))

import Api


type Flow model
    = Continue model
    | Done Api.Submittable
