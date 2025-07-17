port module SignUp exposing (main)

import Browser
import Browser.Navigation exposing (load)
import File exposing (File)
import File.Select
import Html exposing (..)
import Html.Attributes exposing (class, for, id, name, required, src, type_)
import Html.Events as Events
import Http
import Task


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = viewDocument
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { username : String
    , password : String
    , confirmPassword : String
    , bio : String
    , profilePicture : Maybe File
    , profilePictureAsBase64 : String --this field to show the uploaded picture
    }


type alias DataToSend =
    { username : String
    , password : String
    , bio : String
    , profilePicture : File
    }


type alias Jwt_Token =
    String


port sendToken : Jwt_Token -> Cmd msg


initModel : Model
initModel =
    Model "" "" "" "" Nothing ""


init : () -> ( Model, Cmd Msg )
init () =
    ( initModel, Cmd.none )


type Msg
    = Submit
    | RequestSent (Result Http.Error String)
    | ChangeUserName String
    | ChangePassword String
    | ChangeConfirmPassword String
    | FileRequested
    | ChangeProfilePicture File
    | GotBase64 String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Submit ->
            case validateData model of
                Err _ ->
                    ( model, Cmd.none )

                Ok data ->
                    ( model, sendFormData data )

        RequestSent result ->
            case result of
                Ok jwtToken ->
                    ( model, Cmd.batch [ sendToken jwtToken, load ("http://localhost:3000/profile/" ++ model.username) ] )

                Err _ ->
                    ( model, Cmd.none )

        ChangeUserName name ->
            ( { model | username = name }, Cmd.none )

        ChangePassword password ->
            ( { model | password = password }, Cmd.none )

        ChangeConfirmPassword password ->
            ( { model | confirmPassword = password }, Cmd.none )

        FileRequested ->
            ( model, File.Select.file [ "image/*" ] ChangeProfilePicture )

        ChangeProfilePicture picture ->
            ( { model | profilePicture = Just picture }, Task.perform GotBase64 (File.toUrl picture) )

        GotBase64 str ->
            ( { model | profilePictureAsBase64 = str }, Cmd.none )


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = "Sign-Up", body = [ view_form model ] }


view_form : Model -> Html Msg
view_form model =
    div [ class "sign-form" ] [ mahrHeading, usernameInput, passwordInput, passwordConfirmInput, bioInput, profilePictureInput, profilePicturePreview model, submitButton ]


mahrHeading =
    div [ class "heading" ] [ text "mahr" ]


usernameInput =
    div []
        [ label [ for "username" ] [ text "user name : " ]
        , br [] []
        , input [ id "username", name "username", required True, type_ "text", Events.onInput ChangeUserName ] []
        ]


passwordInput =
    div []
        [ label [ for "password" ] [ text "password : " ]
        , br [] []
        , input [ id "password", name "pasword", required True, type_ "password", Events.onInput ChangePassword ] []
        ]


passwordConfirmInput =
    div []
        [ label [ for "password" ] [ text "password : " ]
        , br [] []
        , input [ id "password", name "pasword", type_ "password", Events.onInput ChangePassword ] []
        ]


bioInput =
    div []
        [ label [ for "bio" ] [ text "bio : " ]
        , br [] []
        , textarea [] []
        ]


profilePictureInput =
    div []
        [ label [ for "picture" ] [ text "profile picture : " ]
        , button [ id "picture", Events.onClick FileRequested ] [ text "select Picture" ]
        ]


profilePicturePreview model =
    let
        imgSrc =
            case model.profilePicture of
                Nothing ->
                    defaultProfilePicture

                Just _ ->
                    model.profilePictureAsBase64
    in
    div [] [ img [ src imgSrc ] [] ]


submitButton =
    div [] [ button [ class "submit-btn", type_ "submit", Events.onClick Submit ] [ text "submit" ] ]



-- http things


sendFormData model =
    Http.post { url = "/api/sign-up", body = body model, expect = Http.expectString RequestSent }


body : DataToSend -> Http.Body
body data =
    Http.multipartBody
        [ Http.stringPart "username" data.username
        , Http.stringPart "password" data.password
        , Http.stringPart "bio" data.bio
        , Http.filePart "profile_picture" data.profilePicture
        ]



-- defualt pricture to show


defaultProfilePicture =
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEBLAEsAAD/4QBWRXhpZgAATU0AKgAAAAgABAEaAAUAAAABAAAAPgEbAAUAAAABAAAARgEoAAMAAAABAAIAAAITAAMAAAABAAEAAAAAAAAAAAEsAAAAAQAAASwAAAAB/+0ALFBob3Rvc2hvcCAzLjAAOEJJTQQEAAAAAAAPHAFaAAMbJUccAQAAAgAEAP/hDIFodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvADw/eHBhY2tldCBiZWdpbj0n77u/JyBpZD0nVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkJz8+Cjx4OnhtcG1ldGEgeG1sbnM6eD0nYWRvYmU6bnM6bWV0YS8nIHg6eG1wdGs9J0ltYWdlOjpFeGlmVG9vbCAxMC4xMCc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp0aWZmPSdodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyc+CiAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICA8dGlmZjpYUmVzb2x1dGlvbj4zMDAvMTwvdGlmZjpYUmVzb2x1dGlvbj4KICA8dGlmZjpZUmVzb2x1dGlvbj4zMDAvMTwvdGlmZjpZUmVzb2x1dGlvbj4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6eG1wTU09J2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8nPgogIDx4bXBNTTpEb2N1bWVudElEPmFkb2JlOmRvY2lkOnN0b2NrOjZjYTBkY2U2LWE4ODAtNDQzNy1hNDEyLTUzMWVjM2E1ODEyZTwveG1wTU06RG9jdW1lbnRJRD4KICA8eG1wTU06SW5zdGFuY2VJRD54bXAuaWlkOjIxMWI3NDAzLWE1NWYtNGY4OS1iODEwLTM0YmFmODBmYTVmOTwveG1wTU06SW5zdGFuY2VJRD4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAo8P3hwYWNrZXQgZW5kPSd3Jz8+/9sAQwAFAwQEBAMFBAQEBQUFBgcMCAcHBwcPCwsJDBEPEhIRDxERExYcFxMUGhURERghGBodHR8fHxMXIiQiHiQcHh8e/8AACwgBaAFoAQERAP/EABwAAQADAQEBAQEAAAAAAAAAAAAEBgcFAgMBCP/EAD8QAQABAwECCQkFCAIDAAAAAAABAgMEBQYRBxIWITFBVZTRE1FhcXKBkaHBFSIjQrIUMjM2UmKisWPCF5KT/9oACAEBAAA/ALwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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"



-- validations


validateData : Model -> Result String DataToSend
validateData model =
    case model.profilePicture of
        Nothing ->
            Err "don't forget to add your picture"

        Just file ->
            Ok (DataToSend model.username model.password model.bio file)
