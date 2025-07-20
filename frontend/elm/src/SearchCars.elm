module SearchCars exposing (main)

import Browser
import Debug
import Html exposing (..)
import Html.Attributes exposing (class, name, src, value)
import Html.Events as Events
import Http
import Json.Decode as D


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = viewDocument
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Car =
    { id : Int
    , mark : String
    , color : String
    , modelDate : Int
    , price : Float
    , fileName : String
    }


type alias Cars =
    List Car


type OrderBy
    = PriceInc
    | PriceDec
    | ModelInc
    | ModelDec


type alias Model =
    { cars : List Car
    , ordering : OrderBy
    }


initModel : Model
initModel =
    Model [] PriceInc


init : () -> ( Model, Cmd Msg )
init () =
    ( initModel, getCarsList )


type Msg
    = ChangeOrdering String
    | GotCarsList (Result Http.Error Cars)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeOrdering orderBy ->
            let
                ordering =
                    if orderBy == "PriceInc" then
                        PriceInc

                    else if orderBy == "PriceDec" then
                        PriceDec

                    else if orderBy == "ModelInc" then
                        ModelInc

                    else if orderBy == "ModelDec" then
                        ModelDec

                    else
                        -- should not happen though
                        PriceInc
            in
            ( { model | ordering = ordering }, Cmd.none )

        GotCarsList result ->
            case result of
                Ok cars ->
                    ( { model | cars = cars }, Cmd.none )

                Err httpErr ->
                    ( Debug.log "error" model, Cmd.none )


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = "Search", body = [ viewHeader model, viewMain model ] }


viewHeader : Model -> Html Msg
viewHeader model =
    header [ class "toolbar" ] [ resultDescription model, orderByControl ]


resultDescription model =
    div [] [ text ("number of results : " ++ String.fromInt (List.length model.cars)) ]


orderByControl =
    div []
        [ label [] [ text "sort by : " ]
        , select [ name "order-by", class "order-by", onChange ChangeOrdering ]
            [ option [ value "PriceInc" ] [ text "Price Inc" ]
            , option [ value "PriceDec" ] [ text "Price Dec" ]
            , option [ value "ModelInc" ] [ text "Model Inc" ]
            , option [ value "ModelDec" ] [ text "Model Dec" ]
            ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    main_ [] [ carCardContainer model ]


carCardContainer : Model -> Html Msg
carCardContainer model =
    let
        orderedCars =
            case model.ordering of
                PriceInc ->
                    orederCarsByPriceInc model.cars

                PriceDec ->
                    orederCarsByPriceDec model.cars

                ModelInc ->
                    orederCarsByModelInc model.cars

                ModelDec ->
                    orederCarsByModelDec model.cars
    in
    div [ class "car-card-container" ] (List.map carToCard orderedCars)


carToCard : Car -> Html Msg
carToCard car =
    let
        imgUrl =
            "/uploads/" ++ car.fileName

        head =
            div [ class "head" ] [ img [ src imgUrl ] [] ]

        mid =
            div [ class "mid" ]
                [ span [ class "model" ] [ text <| car.mark ++ " " ++ String.fromInt car.modelDate ]
                , div [ class "vl" ] []
                , span [ class "price" ] [ text <| "$" ++ String.fromFloat car.price ]
                ]
    in
    div [ class "car-card" ]
        [ head, hr [] [], mid, div [ class "btn" ] [ button [ class "submit-btn" ] [ text "Buy this car" ] ] ]



-- utils


orederCarsByPriceInc : List Car -> List Car
orederCarsByPriceInc xs =
    List.sortBy .price xs


orederCarsByPriceDec : List Car -> List Car
orederCarsByPriceDec xs =
    List.reverse (List.sortBy .price xs)


orederCarsByModelInc : List Car -> List Car
orederCarsByModelInc xs =
    List.sortBy .modelDate xs


orederCarsByModelDec : List Car -> List Car
orederCarsByModelDec xs =
    List.reverse (List.sortBy .modelDate xs)



-- elm Html.event lacks pre built onChange event, so we implement it


onChange : (String -> msg) -> Attribute msg
onChange func =
    Events.stopPropagationOn "input" <|
        D.map alwaysStop (D.map func Events.targetValue)


alwaysStop : a -> ( a, Bool )
alwaysStop x =
    ( x, True )



-- Http things


getCarsList : Cmd Msg
getCarsList =
    Http.get { url = "/api/get-buyable-cars", expect = Http.expectJson GotCarsList carsDecoder }



-- json decoder


carsDecoder : D.Decoder Cars
carsDecoder =
    D.list carDecoder


carDecoder : D.Decoder Car
carDecoder =
    D.map6 Car
        (D.field "id" D.int)
        (D.field "mark" D.string)
        (D.field "color" D.string)
        (D.field "model" D.int)
        (D.field "price" D.float)
        (D.field "picture_file_name" D.string)
