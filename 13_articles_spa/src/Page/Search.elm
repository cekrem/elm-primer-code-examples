module Page.Search exposing (Model, Msg, init, update, view)

import Api exposing (ArticleSummary)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
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
    Html.div []
        [ Html.h1 [ Attr.class "font-bold text-2xl" ] [ Html.text "Search Articles" ]
        , viewSearchBox model.query
        , viewResults model
        ]


viewSearchBox : String -> Html Msg
viewSearchBox query =
    Html.div [ Attr.class "mb-5" ]
        [ Html.input
            [ Attr.type_ "text"
            , Attr.placeholder "Search articles..."
            , Attr.value query
            , Events.onInput QueryChanged
            , Attr.class "w-full"
            , Attr.class "p-2.5"
            , Attr.class "text-base"
            , Attr.class "border border-gray-300 rounded"
            ]
            []
        ]


viewResults : Model -> Html Msg
viewResults model =
    case model.articles of
        RemoteData.NotAsked ->
            Html.text ""

        RemoteData.Loading ->
            Html.p [ Attr.class "italic text-gray-500" ] [ Html.text "Loading articles..." ]

        RemoteData.Failure _ ->
            Html.p [ Attr.class "italic text-red-600" ] [ Html.text "Failed to load articles." ]

        RemoteData.Success articles ->
            let
                filtered =
                    filterArticles model.query articles
            in
            if List.isEmpty filtered then
                let
                    message =
                        if String.isEmpty model.query then
                            "Type to search articles..."

                        else
                            "No articles match your search."
                in
                Html.p [ Attr.class "italic text-gray-500" ]
                    [ Html.text message ]

            else
                Html.ul [ Attr.class "p-0 list-none" ]
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
    Html.li
        [ Attr.class "pb-5 mb-5"
        , Attr.class "border-b border-gray-200"
        ]
        [ Html.a
            [ Attr.href (Route.toPath (Route.Article article.id))
            , Attr.class "no-underline text-inherit"
            , Attr.class "hover:[&_h2]:text-blue-600"
            ]
            [ Html.h2 [ Attr.class "m-0 mb-1 text-lg" ]
                [ Html.text article.title ]
            , Html.p [ Attr.class "m-0 text-gray-500" ]
                [ Html.text article.summary ]
            ]
        ]
