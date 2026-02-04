module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Article
import Page.Home
import Page.NotFound
import Page.Search
import Route exposing (Route)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = HomePage Page.Home.Model
    | ArticlePage Page.Article.Model
    | SearchPage Page.Search.Model
    | NotFoundPage


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    changeRouteTo (Route.fromUrl url)
        { key = key
        , page = NotFoundPage
        }



-- UPDATE


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | GotHomeMsg Page.Home.Msg
    | GotArticleMsg Page.Article.Msg
    | GotSearchMsg Page.Search.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( GotHomeMsg homeMsg, HomePage homeModel ) ->
            Page.Home.update homeMsg homeModel
                |> updateWith HomePage GotHomeMsg model

        ( GotArticleMsg articleMsg, ArticlePage articleModel ) ->
            Page.Article.update articleMsg articleModel
                |> updateWith ArticlePage GotArticleMsg model

        ( GotSearchMsg searchMsg, SearchPage searchModel ) ->
            Page.Search.update searchMsg searchModel
                |> updateWith SearchPage GotSearchMsg model

        _ ->
            ( model, Cmd.none )


changeRouteTo : Route -> Model -> ( Model, Cmd Msg )
changeRouteTo route model =
    case route of
        Route.Home ->
            Page.Home.init
                |> updateWith HomePage GotHomeMsg model

        Route.Article id ->
            Page.Article.init id
                |> updateWith ArticlePage GotArticleMsg model

        Route.Search maybeQuery ->
            Page.Search.init maybeQuery
                |> updateWith SearchPage GotSearchMsg model

        Route.NotFound ->
            ( { model | page = NotFoundPage }, Cmd.none )


updateWith :
    (pageModel -> Page)
    -> (pageMsg -> Msg)
    -> Model
    -> ( pageModel, Cmd pageMsg )
    -> ( Model, Cmd Msg )
updateWith toPage toMsg model ( pageModel, pageCmd ) =
    ( { model | page = toPage pageModel }
    , Cmd.map toMsg pageCmd
    )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = pageTitle model.page
    , body =
        [ div [ class "app" ]
            [ viewNav
            , main_ [] [ viewPage model.page ]
            ]
        ]
    }


pageTitle : Page -> String
pageTitle page =
    case page of
        HomePage _ ->
            "Articles"

        ArticlePage articleModel ->
            "Article " ++ String.fromInt articleModel.articleId

        SearchPage _ ->
            "Search"

        NotFoundPage ->
            "Not Found"


viewNav : Html msg
viewNav =
    nav []
        [ a [ href (Route.toPath Route.Home) ] [ text "Home" ]
        , a [ href (Route.toPath (Route.Search Nothing)) ] [ text "Search" ]
        ]


viewPage : Page -> Html Msg
viewPage page =
    case page of
        HomePage homeModel ->
            Page.Home.view homeModel

        ArticlePage articleModel ->
            Page.Article.view articleModel

        SearchPage searchModel ->
            Page.Search.view searchModel
                |> Html.map GotSearchMsg

        NotFoundPage ->
            Page.NotFound.view
