port module SignIn exposing (main)

import Browser
import Browser.Navigation exposing (load)
import Html exposing (..)
import Html.Attributes exposing (class, for, id, name, type_)
import Html.Events as Events
import Http
import Profile exposing (view)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = viewDocument
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Jwt_Token =
    String


port sendToken : Jwt_Token -> Cmd msg


type alias Model =
    { username : String
    , password : String
    }


initModel : Model
initModel =
    Model "" ""


init : () -> ( Model, Cmd Msg )
init () =
    ( initModel, Cmd.none )


type Msg
    = Submit
    | RequestSent (Result Http.Error String)
    | ChangeUserName String
    | ChangePassword String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Submit ->
            ( model, sendFormData model )

        RequestSent result ->
            case result of
                Ok jwtToken ->
                    ( model, Cmd.batch [ sendToken jwtToken, load ("http://localhost:3000/profile/" ++ model.username) ] )

                Err httpErr ->
                    case httpErr of
                        Http.BadBody str ->
                            Debug.todo ("bad body" ++ str)

                        Http.NetworkError ->
                            Debug.todo "Network error"

                        _ ->
                            Debug.todo "unknown error"

        ChangeUserName name ->
            ( { model | username = name }, Cmd.none )

        ChangePassword password ->
            ( { model | password = password }, Cmd.none )


viewDocument : Model -> Browser.Document Msg
viewDocument _ =
    { title = "", body = [ view ] }


view =
    div [ class "sign-form" ] [ mahrHeading, usernameInput, passwordInput, submitButton ]


mahrHeading =
    div [ class "heading" ] [ text "mahr" ]


usernameInput =
    div []
        [ label [ for "username" ] [ text "user name : " ]
        , br [] []
        , input [ id "username", name "username", type_ "text", Events.onInput ChangeUserName ] []
        ]


passwordInput =
    div []
        [ label [ for "password" ] [ text "password : " ]
        , br [] []
        , input [ id "password", name "pasword", type_ "password", Events.onInput ChangePassword ] []
        ]


submitButton =
    div [] [ button [ class "submit-btn", Events.onClick Submit ] [ text "submit" ] ]



-- http things


sendFormData model =
    Http.post { url = "/api/sign-in", body = body model, expect = Http.expectString RequestSent }


body : Model -> Http.Body
body model =
    Http.multipartBody
        [ Http.stringPart "username" model.username
        , Http.stringPart "password" model.password
        ]
