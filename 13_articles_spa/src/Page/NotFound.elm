module Page.NotFound exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Route


view : Html msg
view =
    Html.div [ Attr.class "py-15 text-center" ]
        [ Html.h1 [ Attr.class "m-0 text-7xl text-gray-300" ] [ Html.text "404" ]
        , Html.p [] [ Html.text "This page doesn't exist." ]
        , Html.a [ Attr.href (Route.toPath Route.Home), Attr.class "no-underline hover:underline text-blue-600" ] [ Html.text "Go back home" ]
        ]
