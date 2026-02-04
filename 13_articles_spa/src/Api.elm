module Api exposing
    ( Article
    , ArticleSummary
    , fetchArticle
    , fetchArticles
    )

import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (WebData)


type alias ArticleSummary =
    { id : Int
    , title : String
    , summary : String
    }


type alias Article =
    { id : Int
    , title : String
    , summary : String
    , body : String
    }


baseUrl : String
baseUrl =
    "http://localhost:3001"


fetchArticles : (WebData (List ArticleSummary) -> msg) -> Cmd msg
fetchArticles toMsg =
    Http.get
        { url = baseUrl ++ "/api/articles"
        , expect = Http.expectJson (RemoteData.fromResult >> toMsg) articlesDecoder
        }


fetchArticle : Int -> (WebData Article -> msg) -> Cmd msg
fetchArticle id toMsg =
    Http.get
        { url = baseUrl ++ "/api/articles/" ++ String.fromInt id
        , expect = Http.expectJson (RemoteData.fromResult >> toMsg) articleDecoder
        }


articlesDecoder : Decoder (List ArticleSummary)
articlesDecoder =
    Decode.list articleSummaryDecoder


articleSummaryDecoder : Decoder ArticleSummary
articleSummaryDecoder =
    Decode.map3 ArticleSummary
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "summary" Decode.string)


articleDecoder : Decoder Article
articleDecoder =
    Decode.map4 Article
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "summary" Decode.string)
        (Decode.field "body" Decode.string)
