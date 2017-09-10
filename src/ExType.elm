module ExType exposing (typeAliasConstructor, typespec, uniontype)

import Ast.Statement exposing (Type(..))
import ExContext exposing (Context, indent)
import Ast.Expression exposing (Expression(..))
import Helpers
    exposing
        ( typeApplicationToList
        , toSnakeCase
        , lastAndRest
        , filterMaybe
        , ind
        , atomize
        )


{-| Enocde any elm type
-}
elixirT : Bool -> Context -> Type -> String
elixirT flatten c t =
    case t of
        TypeTuple [] ->
            "no_return"

        TypeTuple [ a ] ->
            elixirT flatten c a

        TypeTuple ((a :: rest) as list) ->
            "{"
                ++ (List.map (elixirT flatten c) list |> String.join ", ")
                ++ "}"

        TypeVariable "number" ->
            "number"

        (TypeVariable name) as var ->
            case String.uncons name of
                Just ( '@', name ) ->
                    toSnakeCase True name

                any ->
                    "any"

        TypeConstructor [ t ] any ->
            elixirType flatten c t any

        TypeConstructor t args ->
            case lastAndRest t of
                ( Just last, a ) ->
                    ExContext.getAlias c.mod last c
                        |> filterMaybe (.aliasType >> (==) ExContext.TypeAlias)
                        |> Maybe.map (\{ getTypeBody } -> getTypeBody args)
                        |> Maybe.map (elixirT flatten c)
                        |> (Maybe.withDefault <|
                                String.join "." a
                                    ++ "."
                                    ++ toSnakeCase True last
                           )

                _ ->
                    Debug.crash "Shouldn't ever happen"

        TypeRecord fields ->
            "%{"
                ++ ind (c.indent + 1)
                ++ (fields
                        |> List.map (\( k, v ) -> k ++ ": " ++ elixirT flatten (indent c) v)
                        |> String.join ("," ++ ind (c.indent + 1))
                   )
                ++ ind (c.indent)
                ++ "}"

        (TypeRecordConstructor _ _) as tr ->
            "%{"
                ++ ind (c.indent + 1)
                ++ ((typeRecordFields (indent c) flatten tr)
                        |> String.join (", " ++ ind (c.indent + 1))
                   )
                ++ ind (c.indent)
                ++ "}"

        TypeApplication l r ->
            if flatten then
                typeApplicationToList r
                    |> lastAndRest
                    |> \( last, rest ) ->
                        "("
                            ++ ((l :: rest)
                                    |> List.map (elixirT flatten (indent c))
                                    |> String.join ", "
                               )
                            ++ " -> "
                            ++ (last
                                    |> Maybe.map (elixirT flatten c)
                                    |> Maybe.withDefault ""
                               )
                            ++ ")"
            else
                "("
                    ++ elixirT flatten c l
                    ++ " -> "
                    ++ elixirT flatten c r
                    ++ ")"


{-| alias for elixirT with flatting of type application
-}
elixirTFlat : Context -> Type -> String
elixirTFlat =
    elixirT True


{-| alias for elixirT without flatting of type application
-}
elixirTNoFlat : Context -> Type -> String
elixirTNoFlat =
    elixirT False


{-| Return fieilds of type record as a list of string key value pairs
-}
typeRecordFields : Context -> Bool -> Type -> List String
typeRecordFields c flatten t =
    let
        keyValuePair ( k, v ) =
            k ++ ": " ++ elixirT flatten c v
    in
        case t of
            TypeRecordConstructor (TypeConstructor [ name ] args) fields ->
                let
                    inherited =
                        ExContext.getAlias c.mod name c
                            |> Maybe.map (\{ getTypeBody } -> getTypeBody args)
                            |> Maybe.map (typeRecordFields c flatten)
                in
                    List.map keyValuePair fields
                        ++ (Maybe.withDefault [ "" ] inherited)

            TypeRecordConstructor (TypeRecord inherited) fields ->
                List.map keyValuePair <| fields ++ inherited

            TypeRecordConstructor (TypeVariable _) fields ->
                List.map keyValuePair fields

            TypeRecordConstructor (TypeTuple [ a ]) fields ->
                typeRecordFields c flatten (TypeRecordConstructor a fields)

            TypeRecordConstructor ((TypeRecordConstructor _ _) as tr) fields ->
                List.map keyValuePair fields
                    ++ typeRecordFields c flatten tr

            (TypeRecord fields) as tr ->
                List.map keyValuePair fields

            any ->
                Debug.crash ("Wrong type record constructor " ++ toString any)


{-| Translate and encode Elm type to Elixir type
-}
elixirType : Bool -> Context -> String -> List Type -> String
elixirType flatten c name args =
    case ( name, args ) of
        ( "Result", [ a, b ] ) ->
            "{:ok, "
                ++ elixirT flatten c a
                ++ "} | {:error, "
                ++ elixirT flatten c b
                ++ "}"

        ( "String", [] ) ->
            "String.t"

        ( "Char", [] ) ->
            "integer"

        ( "Bool", [] ) ->
            "boolean"

        ( "Int", [] ) ->
            "integer"

        ( "Pid", [] ) ->
            "pid"

        ( "Float", [] ) ->
            "float"

        ( "List", [ t ] ) ->
            "list(" ++ elixirT flatten c t ++ ")"

        ( "Dict", [ key, val ] ) ->
            "%{}"

        ( "Maybe", [ t ] ) ->
            "{" ++ elixirT flatten c t ++ "} | nil"

        ( "Nothing", [] ) ->
            "nil"

        ( "Just", [ t ] ) ->
            elixirT flatten c t

        ( "Err", [ t ] ) ->
            "{:error, " ++ elixirT flatten c t ++ "}"

        ( "Ok", [ t ] ) ->
            if t == TypeTuple [] then
                "ok"
            else
                "{:ok," ++ elixirT flatten c t ++ "}"

        ( t, [] ) ->
            aliasOr c t [] (atomize t)

        ( t, list ) ->
            aliasOr c t list <|
                "{"
                    ++ atomize t
                    ++ ", "
                    ++ (List.map (elixirT flatten c) list |> String.join ", ")
                    ++ "}"


{-| Enocde a typespec with 0 arity
-}
typespec0 : Context -> Type -> String
typespec0 c t =
    "() :: " ++ elixirTNoFlat c t


{-| Encode a typespec
-}
typespec : Context -> Type -> String
typespec c t =
    case lastAndRest (typeApplicationToList t) of
        ( Just last, args ) ->
            "("
                ++ (List.map (elixirTNoFlat c) args
                        |> String.join ", "
                   )
                ++ ") :: "
                ++ elixirTNoFlat c last

        ( Nothing, _ ) ->
            Debug.crash "impossible"


{-| Encode a union type
-}
uniontype : Context -> Type -> String
uniontype c t =
    case t of
        TypeConstructor [ name ] [] ->
            atomize name

        TypeConstructor [ name ] list ->
            "{"
                ++ atomize name
                ++ ", "
                ++ (List.map (elixirTNoFlat c) list |> String.join ", ")
                ++ "}"

        other ->
            Debug.crash ("I am looking for union type constructor. But got " ++ toString other)


{-| Change a constructor of a type alias into an expression after resolving it from contextual alias
-}
typeAliasConstructor : List Expression -> ExContext.Alias -> Maybe Expression
typeAliasConstructor args ({ parentModule, aliasType, arity, body, getTypeBody } as ali) =
    case ( aliasType, body ) of
        ( ExContext.Type, _ ) ->
            Nothing

        ( _, TypeConstructor [ name ] _ ) ->
            Nothing

        ( _, TypeRecord kvs ) ->
            let
                params =
                    List.length kvs
                        |> (+) (0 - List.length args)
                        |> List.range 1
                        |> List.map (toString >> (++) "arg")
                        |> List.map (List.singleton >> Variable)

                varargs =
                    kvs
                        |> List.map2 (flip (,)) (args ++ params)
                        |> List.map (Tuple.mapFirst Tuple.first)
            in
                Record varargs
                    |> Lambda (params)
                    |> Just

        -- Error in AST. Single TypeTuple are just paren app
        ( _, TypeTuple [ app ] ) ->
            typeAliasConstructor args { ali | getTypeBody = (\_ -> app) }

        ( _, TypeTuple kvs ) ->
            let
                args =
                    List.length kvs
                        |> List.range 1
                        |> List.map (toString >> (++) "arg")
                        |> List.map (List.singleton >> Variable)
            in
                Just (Lambda (args) (Tuple args))

        ( _, TypeVariable name ) ->
            Just (Variable [ name ])

        other ->
            Nothing


{-| Apply alias, orelse return the provided default value
-}
aliasOr : Context -> String -> List Type -> String -> String
aliasOr c name args default =
    ExContext.getAlias c.mod name c
        |> (Maybe.map <|
                \{ parentModule, getTypeBody, aliasType } ->
                    if parentModule == c.mod then
                        elixirTNoFlat c (getTypeBody args)
                    else
                        case aliasType of
                            ExContext.Type ->
                                parentModule ++ "." ++ elixirTNoFlat c (getTypeBody args)

                            ExContext.TypeAlias ->
                                getTypeBody args
                                    |> elixirTNoFlat { c | mod = parentModule }
           )
        |> Maybe.withDefault default


hasReturnedType : Type -> Type -> Bool
hasReturnedType desired t =
    let
        forAll l r =
            (map2 (,) l r |> map (uncurry hasReturnedType) |> foldl (&&) True)
    in
        case ( desired, t ) of
            ( TypeApplication l1 r1, TypeApplication l2 r2 ) ->
                hasReturnedType l1 l2 && hasReturnedType r1 r2

            ( TypeConstructor lnames largs, TypeConstructor rnames rargs ) ->
                (lnames == rnames)
                    && (length largs)
                    == length (rargs)
                    && forAll largs rargs

<<<<<<< HEAD
aliasOr : Context -> String -> List Type -> String -> String
aliasOr c name args default =
    ExAlias.maybeAlias c.aliases name
        |> Maybe.map
            (\{ mod, getTypeBody, aliasType } ->
                if mod == c.mod then
                    elixirTNoFlat c (getTypeBody args)
                else
                    case aliasType of
                        ExContext.Type ->
                            mod ++ "." ++ elixirTNoFlat c (getTypeBody args)

                        ExContext.TypeAlias ->
                            elixirTNoFlat c (getTypeBody args)
            )
        |> Maybe.withDefault default


hasReturnedType : Type -> Type -> Bool
hasReturnedType desired t =
    let
        forAll l r =
            (map2 (,) l r |> map (uncurry hasReturnedType) |> foldl (&&) True)
    in
        case ( desired, t ) of
            ( TypeApplication l1 r1, TypeApplication l2 r2 ) ->
                hasReturnedType l1 l2 && hasReturnedType r1 r2

            ( TypeConstructor lnames largs, TypeConstructor rnames rargs ) ->
                (lnames == rnames)
                    && (length largs)
                    == length (rargs)
                    && forAll largs rargs

=======
>>>>>>> dev
            ( TypeVariable lname, TypeVariable rname ) ->
                True

            ( TypeTuple ltypes, TypeTuple rtypes ) ->
                (length ltypes == length rtypes)
                    && forAll ltypes rtypes

            ( _, TypeApplication _ right ) ->
                hasReturnedType desired right

            ( TypeVariable _, _ ) ->
                True

            ( _, TypeVariable _ ) ->
                True

            ( _, _ ) ->
                False
