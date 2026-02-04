module Route exposing (Route(..), fromUrl, toPath)

import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser, int, map, oneOf, s, top)
import Url.Parser.Query as Query


type Route
    = Home
    | Article Int
    | Search (Maybe String)
    | NotFound


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Home top
        , map Article (s "article" </> int)
        , map Search (s "search" <?> Query.string "q")
        ]


fromUrl : Url -> Route
fromUrl url =
    Parser.parse parser url
        |> Maybe.withDefault NotFound


toPath : Route -> String
toPath route =
    case route of
        Home ->
            Builder.absolute [] []

        Article id ->
            Builder.absolute [ "article", String.fromInt id ] []

        Search maybeQuery ->
            case maybeQuery of
                Just query ->
                    Builder.absolute [ "search" ] [ Builder.string "q" query ]

                Nothing ->
                    Builder.absolute [ "search" ] []

        NotFound ->
            Builder.absolute [ "not-found" ] []
