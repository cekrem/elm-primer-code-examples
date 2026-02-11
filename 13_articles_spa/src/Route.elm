module Route exposing (Route(..), fromUrl, toPath)

import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser)
import Url.Parser.Query as Query


type Route
    = Home
    | Article Int
    | Search (Maybe String)


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Article (Parser.s "article" </> Parser.int)
        , Parser.map Search (Parser.s "search" <?> Query.string "q")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


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
