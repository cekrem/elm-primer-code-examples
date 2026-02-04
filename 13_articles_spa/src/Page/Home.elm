module Page.Home exposing (Model, Msg, init, update, view)

import Api exposing (ArticleSummary)
import Html exposing (..)
import Html.Attributes exposing (..)
import RemoteData exposing (WebData)
import Route


type alias Model =
    { articles : WebData (List ArticleSummary)
    }


type Msg
    = GotArticles (WebData (List ArticleSummary))


init : ( Model, Cmd Msg )
init =
    ( { articles = RemoteData.Loading }
    , Api.fetchArticles GotArticles
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticles response ->
            ( { model | articles = response }, Cmd.none )


view : Model -> Html msg
view model =
    div [ class "page home" ]
        [ h1 [] [ text "Programming Articles" ]
        , p [ class "subtitle" ] [ text "Wisdom from the trenches (and some questionable advice)" ]
        , viewArticles model.articles
        ]


viewArticles : WebData (List ArticleSummary) -> Html msg
viewArticles webData =
    case webData of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            p [ class "loading" ] [ text "Loading articles..." ]

        RemoteData.Failure _ ->
            p [ class "error" ] [ text "Failed to load articles. Is the server running?" ]

        RemoteData.Success articles ->
            ul [ class "article-list" ]
                (List.map viewArticleSummary articles)


viewArticleSummary : ArticleSummary -> Html msg
viewArticleSummary article =
    li []
        [ a [ href (Route.toPath (Route.Article article.id)) ]
            [ h2 [] [ text article.title ]
            , p [] [ text article.summary ]
            ]
        ]
