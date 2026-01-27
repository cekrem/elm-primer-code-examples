module Feature exposing (Model, Msg, init, update, view)

import Api
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Flow exposing (Flow)



-- MODEL


type Model
    = Describe String
    | Elaborate String String


init : Model
init =
    Describe ""



-- UPDATE


type Msg
    = ChangedDescription String
    | ClickedSubmitDescription
    | ChangedUseCase String
    | ClickedDone
    | ClickedGoBack


update : Msg -> Model -> Flow Model
update msg model =
    case msg of
        ChangedDescription text ->
            case model of
                Describe _ ->
                    Flow.Continue (Describe text)

                _ ->
                    Flow.Continue model

        ClickedSubmitDescription ->
            case model of
                Describe description ->
                    if String.isEmpty (String.trim description) then
                        Flow.Continue model

                    else
                        Flow.Continue (Elaborate description "")

                _ ->
                    Flow.Continue model

        ChangedUseCase text ->
            case model of
                Elaborate description _ ->
                    Flow.Continue (Elaborate description text)

                _ ->
                    Flow.Continue model

        ClickedDone ->
            case model of
                Elaborate description useCase ->
                    Flow.Done
                        (Dict.fromList
                            [ ( "Type", "Feature Request" )
                            , ( "Description", description )
                            , ( "Use Case", useCase )
                            ]
                        )

                _ ->
                    Flow.Continue model

        ClickedGoBack ->
            case model of
                Elaborate description _ ->
                    Flow.Continue (Describe description)

                _ ->
                    Flow.Continue model



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Describe description ->
            viewDescribe description

        Elaborate _ useCase ->
            viewElaborate useCase


viewDescribe : String -> Html Msg
viewDescribe description =
    Html.div []
        [ Html.p [] [ Html.text "What feature would you like to see?" ]
        , Html.textarea
            [ Attr.value description
            , Attr.placeholder "Describe the feature you'd like..."
            , Attr.class "w-full p-2 border rounded"
            , Attr.rows 4
            , Events.onInput ChangedDescription
            ]
            []
        , viewRow
            [ viewButton ClickedSubmitDescription "Next" ]
        ]


viewElaborate : String -> Html Msg
viewElaborate useCase =
    Html.div []
        [ Html.p [] [ Html.text "How would this feature help you? (optional)" ]
        , Html.textarea
            [ Attr.value useCase
            , Attr.placeholder "This would help me because..."
            , Attr.class "w-full p-2 border rounded"
            , Attr.rows 3
            , Events.onInput ChangedUseCase
            ]
            []
        , viewRow
            [ viewButton ClickedGoBack "Back"
            , viewButton ClickedDone "Done"
            ]
        ]



-- HELPERS


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
