module Page.Article exposing (Model, Msg, init, title, update, view)

import Api exposing (Article)
import Html exposing (Html)
import Html.Attributes as Attr
import RemoteData exposing (WebData)
import Route


type alias Model =
    { articleId : Int
    , article : WebData Article
    }


type Msg
    = GotArticle (WebData Article)


init : Int -> ( Model, Cmd Msg )
init articleId =
    ( { articleId = articleId
      , article = RemoteData.Loading
      }
    , Api.fetchArticle articleId GotArticle
    )


title : Model -> String
title model =
    case model.article of
        RemoteData.Success article ->
            article.title

        _ ->
            "Article"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticle response ->
            ( { model | article = response }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.a
            [ Attr.href (Route.toPath Route.Home)
            , Attr.class "inline-block mb-5"
            , Attr.class "no-underline hover:underline text-blue-600"
            ]
            [ Html.text "< Back to articles" ]
        , viewArticle model.article
        ]


viewArticle : WebData Article -> Html Msg
viewArticle webData =
    case webData of
        RemoteData.NotAsked ->
            Html.text ""

        RemoteData.Loading ->
            Html.p [ Attr.class "italic text-gray-500" ] [ Html.text "Loading article..." ]

        RemoteData.Failure _ ->
            Html.div []
                [ Html.h1 [ Attr.class "font-bold text-2xl" ] [ Html.text "Article not found" ]
                , Html.p [] [ Html.text "This article doesn't exist or couldn't be loaded." ]
                ]

        RemoteData.Success article ->
            Html.node "article"
                []
                [ Html.h1 [ Attr.class "mb-2 font-bold text-2xl" ] [ Html.text article.title ]
                , Html.p
                    [ Attr.class "pl-4 mb-5"
                    , Attr.class "italic text-lg text-gray-500"
                    , Attr.class "border-l-3 border-gray-300"
                    ]
                    [ Html.text article.summary ]
                , Html.div []
                    (article.body
                        |> String.split "\n\n"
                        |> List.map (\para -> Html.p [ Attr.class "mt-4" ] [ Html.text para ])
                    )
                ]
