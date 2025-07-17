module PostCar exposing (main)

import Browser
import Browser.Navigation exposing (load)
import File exposing (File)
import File.Select
import Html exposing (..)
import Html.Attributes exposing (class, for, id, name, type_)
import Html.Events as Events
import Http


main : Program String Model Msg
main =
    Browser.document
        { init = init
        , view = viewDocument
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { mark : String
    , color : String
    , modelDate : String
    , price : String
    , carPicture : Maybe File
    , validationErrMsgs : ValidationErrRecMsgs
    , jwtToken : String
    }



-- record will hold the messages of all validation errors, message will be "" if no error happens


type alias ValidationErrRecMsgs =
    { markErr : String
    , colorErr : String
    , modelDateErr : String
    , priceErr : String
    , pictureErr : String
    }



-- the model fields values after being validated before sending to server


type alias ValidatedModel =
    { mark : String
    , color : String
    , modelDate : String
    , price : String
    , carPicture : File
    }


initModel : String -> Model
initModel token =
    { mark = ""
    , color = ""
    , price = ""
    , modelDate = ""
    , carPicture = Nothing
    , validationErrMsgs = ValidationErrRecMsgs "" "" "" "" ""
    , jwtToken = token
    }


init : String -> ( Model, Cmd Msg )
init token =
    if token == "" then
        ( initModel token, load "/sign-in" )

    else
        ( initModel token, Cmd.none )


type Msg
    = ChangeMark String
    | ChangeColor String
    | ChangeDate String
    | ChangePrice String
    | PictureFileRequested
    | ChangePicture File
    | Submit
    | RequestSent (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeMark newVal ->
            ( { model | mark = newVal }, Cmd.none )

        ChangeColor newVal ->
            ( { model | color = newVal }, Cmd.none )

        ChangeDate newVal ->
            ( { model | modelDate = newVal }, Cmd.none )

        ChangePrice newVal ->
            ( { model | price = newVal }, Cmd.none )

        PictureFileRequested ->
            ( model, File.Select.file [ "image/*" ] ChangePicture )

        ChangePicture file ->
            ( { model | carPicture = Just file }, Cmd.none )

        Submit ->
            case validateFormInputs model of
                Ok validatedModel ->
                    ( model, sendCarInfo validatedModel )

                Err errRecMsgs ->
                    ( { model | validationErrMsgs = errRecMsgs }, Cmd.none )

        RequestSent result ->
            case result of
                Ok _ ->
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- view


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = "POST Car", body = [ view model ] }


view : Model -> Html Msg
view model =
    div [ class "sign-form" ] [ mahrHeading, markInput model, colorInput model, modelDateInput model, priceInput model, pictureInput model, submitButton ]


mahrHeading =
    div [ class "heading" ] [ text "mahr" ]


markInput : Model -> Html Msg
markInput model =
    div []
        [ label [ for "mark" ] [ text "Mark : " ]
        , br [] []
        , input [ type_ "text", id "mark", name "mark", Events.onInput ChangeMark ] []
        , div [ class "invalid-input-message" ] [ text model.validationErrMsgs.markErr ] -- a div represent a space for error message, will be empty if no validation errors
        ]


colorInput : Model -> Html Msg
colorInput model =
    div []
        [ label [ for "color" ] [ text "Color : " ]
        , br [] []
        , input [ type_ "text", id "color", name "color", Events.onInput ChangeColor ] []
        , div [ class "invalid-input-message" ] [ text model.validationErrMsgs.colorErr ] -- a div represent a space for error message, will be empty if no validation errors
        ]


modelDateInput : Model -> Html Msg
modelDateInput model =
    div []
        [ label [ for "date" ] [ text "Model date : " ]
        , br [] []
        , input [ type_ "number", id "date", name "date", Events.onInput ChangeDate ] []
        , div [ class "invalid-input-message" ] [ text model.validationErrMsgs.modelDateErr ]
        ]


priceInput : Model -> Html Msg
priceInput model =
    div []
        [ label [ for "price" ] [ text "Price : " ]
        , br [] []
        , input [ type_ "number", id "price", name "price", Events.onInput ChangePrice ] []
        , div [ class "invalid-input-message" ] [ text model.validationErrMsgs.priceErr ]
        ]


pictureInput : Model -> Html Msg
pictureInput model =
    div []
        [ label [ for "picture" ] [ text "Car Picture : " ]
        , button [ id "picture", name "picture", Events.onClick PictureFileRequested ] [ text "add a picture of the car" ]
        , div [ class "invalid-input-message" ] [ text model.validationErrMsgs.pictureErr ]
        ]


submitButton =
    div [] [ button [ class "submit-btn", type_ "submit", Events.onClick Submit ] [ text "submit" ] ]



-- validators


isCarMarkInValid : String -> Bool
isCarMarkInValid mark =
    if mark == "" then
        True

    else
        False


isCarColorInValid : String -> Bool
isCarColorInValid color =
    if color == "" then
        True

    else
        False


isCarModelDateInValid : String -> Bool
isCarModelDateInValid modelDate =
    if modelDate == "" then
        True

    else
        False


isCarPriceInValid : String -> Bool
isCarPriceInValid price =
    case String.toFloat price of
        Nothing ->
            True

        Just _ ->
            False


validateFormInputs : Model -> Result ValidationErrRecMsgs ValidatedModel
validateFormInputs inputs =
    case inputs.carPicture of
        Just pictureFile ->
            if isCarMarkInValid inputs.mark then
                Err (ValidationErrRecMsgs "the car mark is invalid" "" "" "" "")

            else if isCarColorInValid inputs.color then
                Err (ValidationErrRecMsgs "" "the car color is invalid" "" "" "")

            else if isCarPriceInValid inputs.price then
                Err (ValidationErrRecMsgs "" "" "" "the car price is invalid" "")

            else if isCarModelDateInValid inputs.modelDate then
                Err (ValidationErrRecMsgs "" "" "the car model is invalid" "" "")

            else
                Ok
                    { mark = inputs.mark
                    , color = inputs.color
                    , modelDate = inputs.modelDate
                    , price = inputs.price
                    , carPicture = pictureFile
                    }

        Nothing ->
            Err (ValidationErrRecMsgs "" "" "" "" "add a car picture")



-- http things


sendCarInfo model =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ "") ]
        , url = "/api/post-car"
        , body = body model
        , expect = Http.expectWhatever RequestSent
        , timeout = Nothing
        , tracker = Nothing
        }


body : ValidatedModel -> Http.Body
body model =
    Http.multipartBody
        [ Http.stringPart "mark" model.mark
        , Http.stringPart "color" model.color
        , Http.stringPart "model" model.modelDate
        , Http.stringPart "price" model.price
        , Http.filePart "picture" model.carPicture
        ]
