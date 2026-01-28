module Main exposing (main)

import Api
import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Process
import Task
import Wizard



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
    | Wizard Wizard.Model
    | ThankYou



-- UPDATE


type Msg
    = ClickedGiveFeedback
    | ThankYouTimedOut
    | GotWizardMsg Wizard.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedGiveFeedback ->
            ( Wizard Wizard.init, Cmd.none )

        GotWizardMsg wizardMsg ->
            case model of
                Wizard wizardModel ->
                    let
                        ( newWizardModel, wizardCmd, maybeOutMsg ) =
                            Wizard.update wizardMsg wizardModel
                    in
                    case maybeOutMsg of
                        Just Wizard.Cancel ->
                            ( Closed, Cmd.none )

                        Just (Wizard.Complete submittable) ->
                            ( ThankYou, doAfterMs 5000 ThankYouTimedOut )

                        Nothing ->
                            ( Wizard newWizardModel
                            , Cmd.map GotWizardMsg wizardCmd
                            )

                _ ->
                    ( model, Cmd.none )

        ThankYouTimedOut ->
            ( Closed, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Closed ->
            viewButton ClickedGiveFeedback "Give feedback"

        Wizard wizardModel ->
            Wizard.view wizardModel
                |> Html.map GotWizardMsg

        ThankYou ->
            Debug.todo "branch 'ThankYou' not implemented"


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
