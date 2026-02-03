port module Main exposing (main)

import Api
import Browser
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Time
import Wizard



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( Closed, Cmd.none )
        , view = view
        , update = update
        , subscriptions =
            \model ->
                case model of
                    Wizard _ ->
                        dialogCancel (\() -> CanceledNatively)

                    ThankYou _ _ ->
                        Time.every 1000 (\_ -> ThankYouTick)

                    Closed ->
                        Sub.none
        }



-- MODEL


type Model
    = Closed
    | Wizard Wizard.Model
    | ThankYou Api.Submittable Int



-- UPDATE


type Msg
    = ClickedGiveFeedback
    | ThankYouTick
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
                            ( ThankYou submittable 5, Cmd.none )

                        Nothing ->
                            ( Wizard newWizardModel
                            , Cmd.map GotWizardMsg wizardCmd
                            )

                _ ->
                    ( model, Cmd.none )

        ThankYouTick ->
            case model of
                ThankYou _ 1 ->
                    ( Closed, Cmd.none )

                ThankYou submittable timer ->
                    ( ThankYou submittable (timer - 1), Cmd.none )

                _ ->
                    ( model, Cmd.none )

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

                ThankYou data timer ->
                    ( Html.text ""
                    , viewThankYou data timer
                    , True
                    )
    in
    Html.div []
        [ button
        , Html.node "dialog"
            [ Attr.id "wizard-dialog"
            , Attr.class "p-4 m-auto"
            , Attr.class "rounded-xl"
            , Attr.class "outline-none"
            , Attr.class "backdrop:backdrop-blur-[4px]"
            , Attr.class <|
                if dialogOpen then
                    "open"

                else
                    "closed"
            ]
            [ dialogContent
            ]
        ]


viewThankYou : Api.Submittable -> Int -> Html msg
viewThankYou data timer =
    let
        timerText =
            "This dialog will close in " ++ String.fromInt timer ++ " seconds"
    in
    Html.div []
        [ Html.h1 [ Attr.class "text-xl font-bold" ]
            [ Html.text "Thank you for your feedback!" ]
        , Html.h3 [ Attr.class "text-lg" ]
            [ Html.text "You sent in the following:"
            ]
        , viewDataSentIn data

        --, viewDataTable data
        , Html.span [ Attr.class "text-xs" ]
            [ Html.text timerText ]
        ]


viewButton : msg -> String -> Html msg
viewButton action label =
    Html.div
        [ Events.onClick action
        , Attr.class "fixed top-0 right-0"
        , Attr.class "p-2 m-2"
        , Attr.class "bg-[#5cee9a]"
        , Attr.class "rounded"
        , Attr.class "cursor-pointer"
        ]
        [ Html.text label ]


viewDataSentIn : Api.Submittable -> Html msg
viewDataSentIn =
    Dict.toList
        >> List.map (\( key, val ) -> Html.li [ Attr.class "whitespace-pre" ] [ Html.text <| key ++ ":\n\t\t" ++ val ])
        >> Html.ul
            [ Attr.class "p-2"
            , Attr.class "bg-gray-100"
            , Attr.class "rounded"
            ]



-- PORTS


port dialogCancel : (() -> msg) -> Sub msg
