port module Main exposing (main)

import Api
import Browser
import Dict
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
        { init = \_ -> ( Closed, Cmd.none )
        , view = view
        , update = update
        , subscriptions =
            \_ ->
                dialogCancel (\() -> CanceledNatively)
        }



-- MODEL


type Model
    = Closed
    | Wizard Wizard.Model
    | ThankYou Api.Submittable



-- UPDATE


type Msg
    = ClickedGiveFeedback
    | ThankYouTimedOut
    | GotWizardMsg Wizard.Msg
    | CanceledNatively


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
                            ( ThankYou submittable, doAfterMs 5000 ThankYouTimedOut )

                        Nothing ->
                            ( Wizard newWizardModel
                            , Cmd.map GotWizardMsg wizardCmd
                            )

                _ ->
                    ( model, Cmd.none )

        ThankYouTimedOut ->
            ( Closed, Cmd.none )

        CanceledNatively ->
            ( Closed, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        ( button, dialogContent, dialogOpen ) =
            case model of
                Closed ->
                    ( viewButton ClickedGiveFeedback "Give feedback"
                    , Html.text ""
                    , False
                    )

                Wizard wizardModel ->
                    ( Html.text ""
                    , Wizard.view wizardModel
                        |> Html.map GotWizardMsg
                    , True
                    )

                ThankYou data ->
                    ( Html.text ""
                    , viewThankYou data
                    , True
                    )
    in
    Html.div []
        [ button
        , Html.node "dialog"
            [ Attr.id "wizard-dialog"
            , Attr.class "m-auto p-2 rounded-xl outline-none backdrop:backdrop-blur-[4px]"
            , Attr.class <|
                if dialogOpen then
                    "open"

                else
                    "closed"
            ]
            [ dialogContent
            ]
        ]


viewThankYou : Api.Submittable -> Html msg
viewThankYou data =
    Html.div []
        [ Html.h1 [ Attr.class "text-xl" ]
            [ Html.text "Thank you for your feedback!" ]
        , Html.h3 [ Attr.class "text-lg" ]
            [ Html.text "You sent in the following:"
            ]
        , viewDataSentIn data
        , Html.span [ Attr.class "text-sm" ]
            [ Html.text "This dialog will close in 5 seconds" ]
        ]


viewButton : msg -> String -> Html msg
viewButton action label =
    Html.div
        [ Events.onClick action
        , Attr.class "fixed top-0 right-0 p-2 m-2 bg-[#5cee9a] rounded cursor-pointer"
        ]
        [ Html.text label ]


viewDataSentIn : Api.Submittable -> Html msg
viewDataSentIn =
    Dict.toList
        >> List.map (\( key, val ) -> Html.li [ Attr.class "whitespace-pre" ] [ Html.text <| key ++ ":\t\t" ++ val ])
        >> Html.ul []



-- CMD


doAfterMs : Float -> msg -> Cmd msg
doAfterMs time msg =
    Process.sleep time |> Task.perform (always msg)



-- PORTS


port dialogCancel : (() -> msg) -> Sub msg
