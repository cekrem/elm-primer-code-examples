module Main exposing (main)

import Api
import Browser
import Bug
import Dict
import Feature
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Process
import Flow
import Task



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = always ( Closed, Cmd.none )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }



-- MODEL


type Model
    = Closed
    | Welcome
    | ReportBug Bug.Model
    | RequestFeature Feature.Model
    | Confirm Api.Submittable Model
    | ThankYou



-- UPDATE


type Msg
    = ClickedGiveFeedback
    | ClickedReportBug
    | ClickedRequestFeature
    | GotBugMsg Bug.Msg
    | GotFeatureMsg Feature.Msg
    | ClickedGoBack
    | ClickedSubmit Api.Submittable
    | ThankYouTimerExpired


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedGiveFeedback ->
            ( Welcome, Cmd.none )

        ClickedReportBug ->
            ( ReportBug Bug.init, Cmd.none )

        ClickedRequestFeature ->
            ( RequestFeature Feature.init, Cmd.none )

        GotBugMsg bugMsg ->
            case model of
                ReportBug bugModel ->
                    Bug.update bugMsg bugModel
                        |> handleStep model ReportBug

                _ ->
                    ( model, Cmd.none )

        GotFeatureMsg featureMsg ->
            case model of
                RequestFeature featureModel ->
                    Feature.update featureMsg featureModel
                        |> handleStep model RequestFeature

                _ ->
                    ( model, Cmd.none )

        ClickedGoBack ->
            case model of
                Confirm _ previousModel ->
                    ( previousModel, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ClickedSubmit data ->
            ( ThankYou
            , Cmd.batch
                [ Api.submit data
                , doAfterMs 3000 ThankYouTimerExpired
                ]
            )

        ThankYouTimerExpired ->
            ( Closed, Cmd.none )


handleStep : Model -> (childModel -> Model) -> Flow.Flow childModel -> ( Model, Cmd Msg )
handleStep previousModel toModel step =
    case step of
        Flow.Continue childModel ->
            ( toModel childModel, Cmd.none )

        Flow.Done data ->
            ( Confirm data previousModel, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Closed ->
            viewButton ClickedGiveFeedback "Give feedback"

        Welcome ->
            viewWelcomeScreen

        ReportBug bugModel ->
            Bug.view bugModel |> Html.map GotBugMsg

        RequestFeature featureModel ->
            Feature.view featureModel |> Html.map GotFeatureMsg

        Confirm data _ ->
            viewConfirmScreen data

        ThankYou ->
            viewThankYouScreen


viewWelcomeScreen : Html Msg
viewWelcomeScreen =
    Html.div []
        [ Html.span [] [ Html.text "Please choose feedback type:" ]
        , viewRow
            [ viewButton ClickedReportBug "Report bug"
            , viewButton ClickedRequestFeature "Request feature"
            ]
        ]


viewConfirmScreen : Api.Submittable -> Html Msg
viewConfirmScreen data =
    Html.div []
        [ Html.text "You entered the following data"
        , Html.ul []
            (data
                |> Dict.toList
                |> List.map
                    (\( key, value ) ->
                        Html.div [ Attr.class "flex gap-2" ]
                            [ Html.div [] [ Html.text key ]
                            , Html.div [] [ Html.text value ]
                            ]
                    )
            )
        , viewRow
            [ viewButton ClickedGoBack "Go back"
            , viewButton (ClickedSubmit data) "Submit"
            ]
        ]


viewThankYouScreen : Html Msg
viewThankYouScreen =
    Html.div []
        [ Html.text "Thanks for your input, we'll look at it ASAP!"
        ]


viewRow : List (Html msg) -> Html msg
viewRow =
    Html.div [ Attr.class "flex gap-2 items-center" ]


viewButton : msg -> String -> Html msg
viewButton action label =
    Html.button
        [ Events.onClick action
        , Attr.class "p-2 bg-blue-200 rounded cursor-pointer"
        ]
        [ Html.text label ]



-- CMD


doAfterMs : Float -> msg -> Cmd msg
doAfterMs time msg =
    Process.sleep time |> Task.perform (always msg)
