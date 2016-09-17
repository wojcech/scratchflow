import Html
import Html.Attributes
import Array

import Tree exposing (..)
import Crawl exposing (..)

main = let
    {-
    tree = {
        nodes = [
            {
                id = 1,
                nodeType = Constant (Scalar 1),
                inputs = Array.empty,
                outputs = Array.fromList [Just 3]
            },
            {
                id = 2,
                nodeType = Constant (Scalar 2),
                inputs = Array.empty,
                outputs = Array.fromList [Just 3]
            },
            {
                id = 3,
                nodeType = AddType,
                inputs = Array.fromList [Just 1, Just 2],
                outputs = Array.fromList [Just 4]
            },
            {
                id = 4,
                nodeType = Output,
                inputs = Array.fromList [Just 3],
                outputs = Array.empty
            }
        ]
    }
    -}
    tree = newTree
     |> addNode (Constant (Vector [1,2])) 1
     |> addNode (Constant (Vector [2,3])) 2
     |> addNode Add 3
     |> addNode Output 4
     |> addNode (RandomNormal 1 0.5) 5
     --|> toString
    code = case bindNodes (1,0) (3,0) tree of
        Just t1 -> case bindNodes (2,0) (3,1) t1 of
            Just t2 -> case bindNodes (3,0) (5,0) t2 of
                Just t3 -> case bindNodes (5,0) (4,0) t3 of
                    Just t4 -> crawl t4
                    _ -> ""
                _ -> ""
            _ -> ""
        _ -> ""
     --|> toString
    in Html.textarea [Html.Attributes.cols 80, Html.Attributes.rows 25] [Html.text code]