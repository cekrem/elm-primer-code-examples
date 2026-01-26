module Bug exposing (Model, Msg, init, update, view)

import Api
import Dict
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
    = ChooseType BugType
    | UpdateDescription String
    | SubmitDescription
    | UpdateSteps String
    | SubmitSteps


update : Msg -> Model -> Api.Step Model
update msg model =
    case ( msg, model ) of
        ( ChooseType bugType, SelectType ) ->
            Api.Continue (Describe bugType "")

        ( UpdateDescription text, Describe bugType _ ) ->
            Api.Continue (Describe bugType text)

        ( SubmitDescription, Describe bugType description ) ->
            if String.isEmpty (String.trim description) then
                Api.Continue model

            else
                Api.Continue (StepsToReproduce bugType description "")

        ( UpdateSteps text, StepsToReproduce bugType description _ ) ->
            Api.Continue (StepsToReproduce bugType description text)

        ( SubmitSteps, StepsToReproduce bugType description steps ) ->
            Api.Done
                (Dict.fromList
                    [ ( "Type", "Bug Report" )
                    , ( "Category", bugTypeToString bugType )
                    , ( "Description", description )
                    , ( "Steps to Reproduce", steps )
                    ]
                )

        _ ->
            Api.Continue model



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        SelectType ->
            viewSelectType

        Describe bugType description ->
            viewDescribe bugType description

        StepsToReproduce bugType description steps ->
            viewStepsToReproduce bugType description steps


viewSelectType : Html Msg
viewSelectType =
    Html.div []
        [ Html.p [] [ Html.text "What kind of bug are you experiencing?" ]
        , viewRow
            [ viewButton (ChooseType Visual) "Visual/UI"
            , viewButton (ChooseType Functional) "Functional"
            , viewButton (ChooseType Performance) "Performance"
            , viewButton (ChooseType Other) "Other"
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
            , Events.onInput UpdateDescription
            ]
            []
        , viewRow
            [ viewButton SubmitDescription "Next" ]
        ]


viewStepsToReproduce : BugType -> String -> String -> Html Msg
viewStepsToReproduce _ _ steps =
    Html.div []
        [ Html.p [] [ Html.text "How can we reproduce this bug?" ]
        , Html.textarea
            [ Attr.value steps
            , Attr.placeholder "1. Go to...\n2. Click on...\n3. See error"
            , Attr.class "w-full p-2 border rounded"
            , Attr.rows 4
            , Events.onInput UpdateSteps
            ]
            []
        , viewRow
            [ viewButton SubmitSteps "Done" ]
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
