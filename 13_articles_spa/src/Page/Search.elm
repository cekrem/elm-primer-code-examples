module Page.Search exposing (Model, Msg, init, update, view)

import Api exposing (ArticleSummary)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import RemoteData exposing (WebData)
import Route


type alias Model =
    { query : String
    , articles : WebData (List ArticleSummary)
    }


type Msg
    = GotArticles (WebData (List ArticleSummary))
    | QueryChanged String


init : Maybe String -> ( Model, Cmd Msg )
init maybeQuery =
    ( { query = Maybe.withDefault "" maybeQuery
      , articles = RemoteData.Loading
      }
    , Api.fetchArticles GotArticles
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticles response ->
            ( { model | articles = response }, Cmd.none )

        QueryChanged newQuery ->
            ( { model | query = newQuery }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "page search" ]
        [ h1 [] [ text "Search Articles" ]
        , viewSearchBox model.query
        , viewResults model
        ]


viewSearchBox : String -> Html Msg
viewSearchBox query =
    div [ class "search-box" ]
        [ input
            [ type_ "text"
            , placeholder "Search articles..."
            , value query
            , onInput QueryChanged
            ]
            []
        ]


viewResults : Model -> Html Msg
viewResults model =
    case model.articles of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            p [ class "loading" ] [ text "Loading articles..." ]

        RemoteData.Failure _ ->
            p [ class "error" ] [ text "Failed to load articles." ]

        RemoteData.Success articles ->
            let
                filtered =
                    filterArticles model.query articles
            in
            if List.isEmpty filtered then
                p [ class "no-results" ]
                    [ text <|
                        if String.isEmpty model.query then
                            "Type to search articles..."

                        else
                            "No articles match your search."
                    ]

            else
                ul [ class "article-list" ]
                    (List.map viewArticleSummary filtered)


filterArticles : String -> List ArticleSummary -> List ArticleSummary
filterArticles query articles =
    if String.isEmpty query then
        []

    else
        let
            lowerQuery =
                String.toLower query
        in
        List.filter
            (\article ->
                String.contains lowerQuery (String.toLower article.title)
                    || String.contains lowerQuery (String.toLower article.summary)
            )
            articles


viewArticleSummary : ArticleSummary -> Html Msg
viewArticleSummary article =
    li []
        [ a [ href (Route.toPath (Route.Article article.id)) ]
            [ h2 [] [ text article.title ]
            , p [] [ text article.summary ]
            ]
        ]
