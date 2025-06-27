module SearchCars exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, name, value)
import Html.Events as Events
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
    { mark : String
    , color : String
    , modelDate : Int
    , price : Float
    }


carsList : List Car
carsList =
    [ Car "Honda" "white" 2000 500000
    , Car "Honda" "black" 2000 500000
    , Car "Honda" "red" 2005 500000

    -----
    , Car "Toyota" "silver" 2000 600000
    , Car "Toyota" "red" 2000 600000
    , Car "Toyota" "blue" 2003 600000

    -----
    , Car "Ford" "green" 2000 500000
    , Car "Ford" "blue" 2000 900000
    , Car "Ford" "white" 2000 900000

    -----
    , Car "BMW" "white" 2002 1000000
    , Car "BMW" "white" 2009 1000000
    , Car "BMW" "white" 2010 1000000

    -----
    , Car "Mercedes-Benz" "white" 2002 500000
    , Car "Mercedes-Benz" "silver" 2001 500000
    , Car "Mercedes-Benz" "black" 2000 500000

    -----
    , Car "Lancer" "red" 1999 500000
    , Car "Nissan" "red" 1999 500000

    -----
    , Car "Nissan" "blue" 2006 400000
    , Car "Nissan" "silver" 2001 400000
    , Car "Nissan" "white" 2010 400000
    ]


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
    Model carsList PriceInc


init : () -> ( Model, Cmd Msg )
init () =
    ( initModel, Cmd.none )


type Msg
    = ChangeOrdering String


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


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = "Search", body = [ viewHeader model, viewMain model ] }


viewHeader : Model -> Html Msg
viewHeader model =
    header [] [ resultDescription model, orderByControl ]


resultDescription model =
    div [] [ text ("number of results : " ++ String.fromInt (List.length model.cars)) ]


orderByControl =
    div []
        [ select [ name "order-by", class "order-by", onChange ChangeOrdering ]
            [ option [ value "PriceInc" ] [ text "Price Inc" ]
            , option [ value "PriceDec" ] [ text "Price Dec" ]
            , option [ value "ModelInc" ] [ text "Model Inc" ]
            , option [ value "ModelDec" ] [ text "Model Dec" ]
            ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    main_ [] [ viewCarsTable model ]


viewCarsTable model =
    table [ class "" ] [ carsTableHead, carsTableBody model ]


carsTableHead =
    thead []
        [ tr []
            [ th [] [ text "Mark" ]
            , th [] [ text "Color" ]
            , th [] [ text "Model" ]
            , th [] [ text "Price" ]
            ]
        ]


carsTableBody : Model -> Html Msg
carsTableBody model =
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
    tbody [] (List.map carToRow orderedCars)


carToRow : Car -> Html Msg
carToRow car =
    tr []
        [ td [] [ text car.mark ]
        , td [] [ text car.color ]
        , td [] [ car.modelDate |> String.fromInt |> text ]
        , td [] [ car.price |> String.fromFloat |> text ]
        ]



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



-- elm Html.event lack pre built onChange event, so we implement it


onChange : (String -> msg) -> Attribute msg
onChange func =
    Events.stopPropagationOn "input" <|
        D.map alwaysStop (D.map func Events.targetValue)


alwaysStop : a -> ( a, Bool )
alwaysStop x =
    ( x, True )
