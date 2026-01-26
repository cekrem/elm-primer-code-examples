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
    | Confirm Api.Submittable
    | ThankYou



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( OpenWizard, _ ) ->
            ( Welcome, Cmd.none )

        ( StartBugReport, _ ) ->
            ( ReportBug Bug.init, Cmd.none )

        ( StartFeatureRequest, _ ) ->
            ( RequestFeature Feature.init, Cmd.none )

        ( GotBugMsg bugMsg, ReportBug bugModel ) ->
            Bug.update bugMsg bugModel
                |> updateWith ReportBug

        ( GotFeatureMsg featureMsg, RequestFeature featureModel ) ->
            Feature.update featureMsg featureModel
                |> updateWith RequestFeature

        ( Submit data, _ ) ->
            ( ThankYou
            , Cmd.batch
                [ Api.submit data
                , doAfterMs 3000 CloseWizard
                ]
            )

        ( CloseWizard, _ ) ->
            ( Closed, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


updateWith : (childModel -> Model) -> Api.Step childModel -> ( Model, Cmd Msg )
updateWith toModel step =
    case step of
        Api.Continue childModel ->
            ( toModel childModel, Cmd.none )

        Api.Done data ->
            ( Confirm data, Cmd.none )


type Msg
    = OpenWizard
    | StartBugReport
    | StartFeatureRequest
    | GotBugMsg Bug.Msg
    | GotFeatureMsg Feature.Msg
    | Submit Api.Submittable
    | CloseWizard



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Closed ->
            viewButton OpenWizard "Give feedback"

        Welcome ->
            viewWelcomeScreen

        ReportBug bugModel ->
            Bug.view bugModel |> Html.map GotBugMsg

        RequestFeature featureModel ->
            Feature.view featureModel |> Html.map GotFeatureMsg

        Confirm data ->
            viewConfirmScreen data

        ThankYou ->
            viewThankYouScreen


viewWelcomeScreen : Html Msg
viewWelcomeScreen =
    Html.div []
        [ Html.span [] [ Html.text "Please choose feedback type:" ]
        , viewRow
            [ viewButton StartBugReport "Report bug"
            , viewButton StartFeatureRequest "Request feature"
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
            [ viewButton (Submit data) "Submit" ]
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
