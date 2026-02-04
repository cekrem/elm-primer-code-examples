module Page.Article exposing (Model, Msg, init, update, view)

import Api exposing (Article)
import Html exposing (..)
import Html.Attributes exposing (..)
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticle response ->
            ( { model | article = response }, Cmd.none )


view : Model -> Html msg
view model =
    div [ class "page article" ]
        [ a [ href (Route.toPath Route.Home), class "back-link" ]
            [ text "< Back to articles" ]
        , viewArticle model.article
        ]


viewArticle : WebData Article -> Html msg
viewArticle webData =
    case webData of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            p [ class "loading" ] [ text "Loading article..." ]

        RemoteData.Failure _ ->
            div []
                [ h1 [] [ text "Article not found" ]
                , p [] [ text "This article doesn't exist or couldn't be loaded." ]
                ]

        RemoteData.Success article ->
            article_
                [ h1 [] [ text article.title ]
                , p [ class "summary" ] [ text article.summary ]
                , div [ class "body" ]
                    (article.body
                        |> String.split "\n\n"
                        |> List.map (\para -> p [] [ text para ])
                    )
                ]


article_ : List (Html msg) -> Html msg
article_ children =
    node "article" [] children
