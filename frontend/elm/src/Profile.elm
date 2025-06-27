module Profile exposing (Model, Msg, initModel, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes as Attributes exposing (class)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = viewDocument
        , update = update
        , subscriptions = \_ -> Sub.none
        }


initModel : Model
initModel =
    Nothing


init : () -> ( Model, Cmd Msg )
init () =
    ( initModel, Cmd.none )


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


viewDocument : Model -> Browser.Document Msg
viewDocument _ =
    { title = "Profile Page", body = [ view ] }


view : Html Msg
view =
    div [] [ text "Profile" ]


type Model
    = Nothing
