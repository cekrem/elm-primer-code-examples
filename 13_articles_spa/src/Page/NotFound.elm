module Page.NotFound exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route


view : Html msg
view =
    div [ class "page not-found" ]
        [ h1 [] [ text "404" ]
        , p [] [ text "This page doesn't exist." ]
        , a [ href (Route.toPath Route.Home) ] [ text "Go back home" ]
        ]
