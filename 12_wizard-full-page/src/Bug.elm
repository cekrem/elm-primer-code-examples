module Bug exposing (Model, Msg, init, update, view)

import Api
import Dict
import Flow exposing (Flow)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events



-- MODEL


type Model
    = SelectType
    | Describe BugType String
    | StepsToReproduce BugType String String


type BugType
    = Visual
    | Functional
    | Performance
    | Other


init : Model
init =
    SelectType



-- UPDATE


type Msg
    = ClickedBugType BugType
    | ChangedDescription String
    | ClickedSubmitDescription
    | ChangedSteps String
    | ClickedDone
    | ClickedGoBack


update : Msg -> Model -> Flow Model
update msg model =
    case msg of
        ClickedBugType bugType ->
            Flow.Continue (Describe bugType "")

        ChangedDescription text ->
            case model of
                Describe bugType _ ->
                    Flow.Continue (Describe bugType text)

                _ ->
                    Flow.Continue model

        ClickedSubmitDescription ->
            case model of
                Describe bugType description ->
                    if String.isEmpty (String.trim description) then
                        Flow.Continue model

                    else
                        Flow.Continue (StepsToReproduce bugType description "")

                _ ->
                    Flow.Continue model

        ChangedSteps text ->
            case model of
                StepsToReproduce bugType description _ ->
                    Flow.Continue (StepsToReproduce bugType description text)

                _ ->
                    Flow.Continue model

        ClickedDone ->
            case model of
                StepsToReproduce bugType description steps ->
                    Flow.Done
                        (Dict.fromList
                            [ ( "Type", "Bug Report" )
                            , ( "Category", bugTypeToString bugType )
                            , ( "Description", description )
                            , ( "Steps to Reproduce", steps )
                            ]
                        )

                _ ->
                    Flow.Continue model

        ClickedGoBack ->
            case model of
                Describe bugType description ->
                    Flow.Continue SelectType

                StepsToReproduce bugType description _ ->
                    Flow.Continue (Describe bugType description)

                _ ->
                    Flow.Continue model



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        SelectType ->
            viewSelectType

        Describe bugType description ->
            viewDescribe bugType description

        StepsToReproduce _ _ steps ->
            viewStepsToReproduce steps


viewSelectType : Html Msg
viewSelectType =
    Html.div []
        [ Html.p [] [ Html.text "What kind of bug are you experiencing?" ]
        , viewRow
            [ viewButton (ClickedBugType Visual) "Visual/UI"
            , viewButton (ClickedBugType Functional) "Functional"
            , viewButton (ClickedBugType Performance) "Performance"
            , viewButton (ClickedBugType Other) "Other"
            ]
        ]


viewDescribe : BugType -> String -> Html Msg
viewDescribe bugType description =
    Html.div []
        [ Html.p []
            [ Html.text ("Describe the " ++ String.toLower (bugTypeToString bugType) ++ " bug:") ]
        , Html.textarea
            [ Attr.value description
            , Attr.placeholder "What happened? What did you expect?"
            , Attr.class "w-full p-2 border rounded"
            , Attr.rows 4
            , Events.onInput ChangedDescription
            ]
            []
        , viewRow
            [ viewButton ClickedGoBack "Back"
            , viewButton ClickedSubmitDescription "Next"
            ]
        ]


viewStepsToReproduce : String -> Html Msg
viewStepsToReproduce steps =
    Html.div []
        [ Html.p [] [ Html.text "How can we reproduce this bug?" ]
        , Html.textarea
            [ Attr.value steps
            , Attr.placeholder "1. Go to...\n2. Click on...\n3. See error"
            , Attr.class "w-full p-2 border rounded"
            , Attr.rows 4
            , Events.onInput ChangedSteps
            ]
            []
        , viewRow
            [ viewButton ClickedGoBack "Back"
            , viewButton ClickedDone "Done"
            ]
        ]



-- HELPERS


bugTypeToString : BugType -> String
bugTypeToString bugType =
    case bugType of
        Visual ->
            "Visual/UI"

        Functional ->
            "Functional"

        Performance ->
            "Performance"

        Other ->
            "Other"


viewRow : List (Html msg) -> Html msg
viewRow =
    Html.div [ Attr.class "flex gap-2 items-center mt-2" ]


viewButton : msg -> String -> Html msg
viewButton action label =
    Html.button
        [ Events.onClick action
        , Attr.class "p-2 bg-blue-200 rounded cursor-pointer"
        ]
        [ Html.text label ]
