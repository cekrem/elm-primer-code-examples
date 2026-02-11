module Page.Home exposing (Model, Msg, init, update, view)

import Api exposing (ArticleSummary)
import Html exposing (Html)
import Html.Attributes as Attr
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


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [ Attr.class "font-bold text-2xl" ] [ Html.text "Programming Articles" ]
        , Html.p [ Attr.class "italic text-gray-500" ] [ Html.text "Wisdom from the trenches (and some questionable advice)" ]
        , viewArticles model.articles
        ]


viewArticles : WebData (List ArticleSummary) -> Html Msg
viewArticles webData =
    case webData of
        RemoteData.NotAsked ->
            Html.text ""

        RemoteData.Loading ->
            Html.p [ Attr.class "italic text-gray-500" ] [ Html.text "Loading articles..." ]

        RemoteData.Failure _ ->
            Html.p [ Attr.class "italic text-red-600" ] [ Html.text "Failed to load articles. Is the server running?" ]

        RemoteData.Success articles ->
            Html.ul [ Attr.class "mt-8 list-none" ]
                (List.map viewArticleSummary articles)


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
