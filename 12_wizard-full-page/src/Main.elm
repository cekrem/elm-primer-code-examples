module Main exposing (main)

import Api
import Browser
import Dict
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
      -- | ReportBug Bug.Model
      -- | RequestFeature Feature.Model
    | Confirm Model Api.Submittable
    | ThankYou



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenWizard ->
            ( Welcome, Cmd.none )

        RollbackState rollbackTo ->
            ( rollbackTo, Cmd.none )

        ConfirmData data ->
            ( Confirm model data, Cmd.none )

        Submit data ->
            ( ThankYou
            , Cmd.batch
                [ Api.submit data
                , doAfterMs 3000 CloseWizard
                ]
            )

        CloseWizard ->
            ( Closed, Cmd.none )


type Msg
    = OpenWizard
      --  | ReportBug
      --  | RequestFeature
    | RollbackState Model
    | ConfirmData Api.Submittable
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

        Confirm prev data ->
            viewConfirmScreen (RollbackState prev) (Submit data) data

        ThankYou ->
            viewThankYouScreen


viewWelcomeScreen : Html Msg
viewWelcomeScreen =
    Html.div []
        [ Html.span [] [ Html.text "Please choose feedback type:" ]
        , viewRow
            [ viewButton OpenWizard "Report bug (TODO)"
            , viewButton OpenWizard "Request feature (TODO)"
            , viewButton (ConfirmData mockConfirmData) "Confirm data (mock)"
            ]
        ]


mockConfirmData : Dict.Dict String String
mockConfirmData =
    [ ( "Type", "Bug report (mocked)" )
    , ( "Some data", "Yes" )
    , ( "Some data", "Yes" )
    , ( "Some data", "Yes" )
    , ( "Some other data", "No" )
    ]
        |> Dict.fromList


viewConfirmScreen : Msg -> Msg -> Api.Submittable -> Html Msg
viewConfirmScreen rollback submit data =
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
            [ viewButton submit "Submit"
            , viewButton rollback "Go back"
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



-- Cmd


doAfterMs : Float -> msg -> Cmd msg
doAfterMs time msg =
    Process.sleep time |> Task.perform (always msg)
