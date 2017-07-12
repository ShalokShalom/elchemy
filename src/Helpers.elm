module Helpers exposing (..)

import Char
import Tuple exposing (..)
import List exposing (..)
import Regex exposing (..)
import Dict exposing (Dict)
import ExReserved
import Code exposing (..)


type MaybeUpper
    = Upper String
    | Lower String


notImplemented : String -> a -> String
notImplemented feature value =
    " ## ERROR: No "
        ++ feature
        ++ " implementation for "
        ++ toString value
        ++ " yet"
        ++ "\n"
        |> Debug.crash


toSnakeCase : Bool -> String -> String
toSnakeCase isntAtom s =
    let
        string =
            if isntAtom then
                ExReserved.maybeReplaceReserved s
            else
                s
    in
        if String.toUpper string == string then
            String.toLower string
        else
            string
                |> Regex.split Regex.All (Regex.regex "(?=[A-Z])")
                |> String.join "_"
                |> String.toLower


isUpper : String -> Bool
isUpper string =
    case String.uncons string of
        Just ( start, rest ) ->
            Char.isUpper start

        Nothing ->
            False


capitalize : String -> String
capitalize s =
    String.uncons s
        |> Maybe.map (\a -> String.cons (Char.toUpper (first a)) (second a))
        |> Maybe.withDefault ""


atomize : String -> String
atomize s =
    ":" ++ toSnakeCase False s


isCapitilzed : String -> Bool
isCapitilzed s =
    String.uncons s
        |> Maybe.map (\a -> a |> first |> Char.isUpper)
        |> Maybe.withDefault False


ind : Int -> String
ind i =
    "\n" ++ (List.repeat ((i + 1) * 2) " " |> String.join "")


ind_ : Code -> Int -> String
ind_ c plus =
    ind (c.context.indent + plus)


prependAll : String -> String -> String
prependAll with target =
    String.lines target
        |> List.map
            (\line ->
                if String.trim line == "" then
                    line
                else
                    with ++ line
            )
        |> String.join "\n"


indAll : Int -> String -> String
indAll i s =
    "\n" ++ prependAll (String.dropLeft 1 (ind i)) s


uncons : List a -> ( Maybe a, List a )
uncons list =
    case list of
        a :: b ->
            ( Just a, b )

        [] ->
            ( Nothing, [] )


lastAndRest : List a -> ( Maybe a, List a )
lastAndRest list =
    list
        |> List.reverse
        |> uncons
        |> Tuple.mapSecond List.reverse


unquoteSplicing : String -> String
unquoteSplicing =
    Regex.replace All (regex "(^\\{|\\}$)") (\_ -> "")


operators : Dict String String
operators =
    [ ( "||", "||" )
    , ( "&&", "&&" )
    , ( "==", "==" )
    , ( "/=", "!=" )
    , ( "<", "<" )
    , ( ">", ">" )
    , ( ">=", ">=" )
    , ( "<=", "<=" )
    , ( "++", "++" )
    , ( "+", "+" )
    , ( "-", "-" )
    , ( "*", "*" )
    , ( "/", "/" )
    , ( ">>", ">>>" )
    , ( "<|", "" )
    , ( "<<", "" )
    , ( "|>", "|>" )

    -- Exception
    , ( "%", "rem" )

    -- Exception
    , ( "//", "" )

    -- Exception
    , ( "rem", "" )

    -- Exception
    , ( "^", "" )

    -- Exception
    , ( "::", "cons" )
    , ( "not", "!" )
    , ( ",", "tuple2" )
    , ( ",,", "tuple3" )
    , ( ",,,", "tuple4" )
    , ( ",,,,", "tuple5" )
    , ( "as", "=" )
    ]
        |> List.foldl (uncurry Dict.insert) Dict.empty


type Operator
    = None
    | Builtin
    | Custom


isOperator : String -> Operator
isOperator name =
    let
        is_builtin =
            operators
                |> Dict.keys
                |> List.any ((==) name)

        is_custom =
            Regex.contains (regex "^[+\\-\\/*=.$<>:&|^?%#@~!]+$") name
    in
        case ( is_builtin, is_custom ) of
            ( True, _ ) ->
                Builtin

            ( False, True ) ->
                Custom

            _ ->
                None


translateOperator : String -> String
translateOperator op =
    case Dict.get op operators of
        Just "" ->
            Debug.crash
                (op
                    ++ " is not a valid or not implemented yet operator"
                )

        Just key ->
            key

        _ ->
            ExReserved.replaceOp op


trimIndentations : String -> String
trimIndentations line =
    Regex.replace All (regex "\\s+\\n") (always "\n") line


generateArguments : Int -> List String
generateArguments =
    generateArguments_ "x"


generateArguments_ : String -> Int -> List String
generateArguments_ str n =
    List.range 1 n
        |> List.map toString
        |> List.map ((++) str)


unescape : String -> String
unescape s =
    Regex.replace All (regex "\\\\\\\\") (always "\\") s


escape : String -> String
escape s =
    Regex.replace All (regex "\\\\") (always "\\\\") s


modulePath : List String -> String
modulePath list =
    list
        |> List.map
            (\a ->
                if isUpper a then
                    a
                else
                    toSnakeCase True a
            )
        |> List.map maybeReplaceStd
        |> String.join "."


isStdModule : String -> Bool
isStdModule a =
    List.member a
        [ "Basics"
        , "List"
        , "String"
        , "Maybe"
        , "Char"
        , "Result"
        , "Tuple"
        ]


maybeReplaceStd : String -> String
maybeReplaceStd s =
    if isStdModule s then
        "X" ++ s
    else
        s


maybeOr : Maybe a -> Maybe a -> Maybe a
maybeOr m1 m2 =
    case m1 of
        Just a ->
            m1

        Nothing ->
            m2
