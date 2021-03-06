module GraphicalNode exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)

import Html.Events exposing (on)

import Json.Decode as Json exposing ((:=))
import Json.Decode
import Mouse exposing (Position)
import Task
import Tree

-- MODEL


type alias Model =

    {   position : Position,
        drag : Maybe Drag,
        text:String,
        id:Int,
        nodeType:Tree.NodeType
    }


type alias Drag =
    { start : Position
    , current : Position
    }


-- UPDATE

type OutMsg=ReleasedAt Int Int Int
            |EdgeNode Int

type Msg
    = DragStart Position Int
    | DragAt Position Int
    | DragEnd Position Int
    |StartEdge Int
    |NoOp


update : Msg -> Model -> ( Model, Cmd Msg,Maybe OutMsg )
update msg ({position, drag,text,id, nodeType} as model) =
  let 
      outmsg=case  msg of 
          DragEnd xy id-> let pos=(getPosition model)in Just (ReleasedAt pos.x pos.y id)
          StartEdge id -> Just (EdgeNode id)
          _-> Nothing
      newmodel= case  msg of
        DragStart xy id->
          Model position (Just (Drag xy xy)) text id nodeType

        DragAt xy id->
          Model position (Maybe.map (\{start} -> Drag start xy) drag) text id nodeType

        DragEnd p id->
          Model (getPosition model) Nothing text id nodeType
        StartEdge id -> model
        NoOp -> model
  in (newmodel,Cmd.none,outmsg)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.drag of
    Nothing ->
      Sub.none

    Just _ ->
      Sub.batch [ Mouse.moves (\p ->DragAt  p model.id) , Mouse.ups (\p -> DragEnd p model.id)]



-- VIEW


(=>) = (,)

leftBarWidth=20
rightAreaWidth=100-leftBarWidth
leftBarStyle = style ["background-color"=>"red",
    "width"=> (toString leftBarWidth  ++ "%"),
    "float"=>"left",
    "border-right-width"=>"2px",
    "border-right-style"=>"solid",
    "height"=>"100%"]
rightAreaStyle = style ["background-color"=>"green",
    "margin-left"=> (toString leftBarWidth ++ "%"),
    "height"=>"100%"]

view : Model -> Html Msg
view model =
    let
        realPosition =
            getPosition model
        color="red"
    in
               div 
               [
                   onMouseDown model.id,
                   onShiftClick model.id,
                    style
                   [ "background-color" => color--"#3C8D2F"
                   , "cursor" => "move"

                   , "width" => "100px"
                   , "height" => "100px"
                   , "border-radius" => "4px"
                   , "position" => "absolute"
                   , "left" => px realPosition.x
                   , "top" => px realPosition.y

                   , "color" => "white"
                   , "display" => "flex"
                   , "align-items" => "center"
                   , "justify-content" => "center"
                   ]
               ]
               [ 
               text model.text
               ]


px : Int -> String
px number =
  toString number ++ "px"


getPosition : Model -> Position
getPosition {position, drag} =
  case drag of
    Nothing ->
      position

    Just {start,current} ->
      Position
        (position.x + current.x - start.x)
        (position.y + current.y - start.y)


onMouseDown : Int->Attribute Msg
onMouseDown id =
  on "mousedown" (Json.map (\p->DragStart p id) Mouse.position )

onShiftClick:Int-> Attribute Msg
onShiftClick id=
    on "click" (Json.map (\t -> if t then StartEdge id else NoOp) shiftdec_a)



shiftdec_a=
    (Json.Decode.at ["shiftKey"] Json.Decode.bool)




---plan
--- write update/model/view architecture for node generation
