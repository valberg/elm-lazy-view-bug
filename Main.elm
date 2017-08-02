module Main exposing (..)

import Html exposing (Html, div, text, a, h1, h4)
import Html.Attributes exposing (href)
import Html.Lazy exposing (lazy)
import Navigation exposing (program, Location)
import UrlParser exposing (Parser, (</>), oneOf, map, top, s, string, parseHash)
import Time exposing (Time, second)


main : Program Never Model Msg
main =
    program
        OnLocationChange
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = lazy view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (3 * second) GetData


type alias Model =
    { loaded : Bool
    , route : Route
    }


init : Location -> ( Model, Cmd msg )
init location =
    let
        currentRoute =
            parseLocation location

        model =
            Model False currentRoute
    in
        model ! []


type Route
    = Index
    | SomePage String
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Index top
        , map SomePage (s "page" </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    parseHash matchers location
        |> Maybe.withDefault NotFoundRoute


type Msg
    = NoOp
    | GetData Time
    | OnLocationChange Location


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        GetData time ->
            { model | loaded = True } ! []

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                { model | route = newRoute } ! []


view : Model -> Html Msg
view model =
    case model.loaded of
        True ->
            div []
                [ h1 [] [ text "Lazy bug" ]
                , case model.route of
                    Index ->
                        div []
                            [ text "Index"
                            , a [ href "#/page/some" ] [ text "Some Page" ]
                            ]

                    SomePage str ->
                        somePageView str model

                    NotFoundRoute ->
                        div [] [ text "Not found!" ]
                ]

        False ->
            -- NOTE!: If the following `h4` is turned into a `div` the error does not occur.
            h4 [] [ text "Loading..." ]


somePageView str model =
    div [] [ text <| "Page: " ++ str, a [ href "#" ] [ text "Index" ] ]
