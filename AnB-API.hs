module Main
where
import Control.Monad
import Parser
import Ast
import Lexer
import System.Environment
import Data.List

getProtocolName (a,_,_,_,_,_) = a
getTypeDecls (_,a,_,_,_,_) = a
getSetDecls (_,_,a,_,_,_) = a
getFactDecls (_,_,_,a,_,_) = a
getSubprotocolDecls (_,_,_,_,a,_) = a
getAttackDecls (_,_,_,_,_,a) = a

--Protocol functions

compileProtocolName :: String -> String
compileProtocolName name = name ++ ";"

--Types functions

printType :: TypeDecl -> String
printType (identlist1,identlist2,set) =
    if (set)
        then (intercalate "," identlist1) ++ "\t: {" ++ (intercalate "," identlist2) ++ "};\n"
        else (intercalate "," identlist1) ++ "\t: " ++ (intercalate "," identlist2) ++ ";\n"

compileTypes :: TypeDecls -> String
compileTypes [] = ""
compileTypes (typedecl:rest) = (printType typedecl) ++ compileTypes rest

getTypeListFromTypeDecls :: TypeDecls -> [String]
getTypeListFromTypeDecls [] = []
getTypeListFromTypeDecls ((identlist1,identlist2,set):rest) = identlist1 ++ (getTypeListFromTypeDecls rest)

--Set functions

printSet :: SetDecl -> String
printSet (ident,identlist) = ident ++ "(" ++ (intercalate "," identlist) ++ ")"

compileSets :: SetDecls -> String
compileSets [] = ";"
compileSets (setdecl:rest)
    | null rest = (printSet setdecl) ++ compileSets rest
    | otherwise = (printSet setdecl) ++ ", " ++ compileSets rest

insetexpToSetexp :: InSetExp -> SetDecls -> SetExp
insetexpToSetexp (isident,isidentlist) [] = (isident,[]) -- If the user inputs the right set we should never get here
insetexpToSetexp isexp@(isident,isidentlist) ((sident,sidentlist):srest) =
    if (isident == sident)
        then (sident,sidentlist)
        else (insetexpToSetexp isexp srest)

--Function functions

compileFunctions :: String
compileFunctions = "public sign/2, scrypt/2, crypt/2, pair/2, h/2;\nprivate inv/1;"

--Fact functions

printFact :: FactDecl -> String
printFact (ident,int) = ident ++ "/" ++ show int

compileFacts :: FactDecls -> String
compileFacts [] = ";"
compileFacts (factdecl:rest)
    | null rest = (printFact factdecl) ++ compileFacts rest
    | otherwise = (printFact factdecl) ++ ", " ++ compileFacts rest

--Subprotocol functions

type Left = [Action]
type Center = [Action]
type Right = [Action]
type Agent = Ident

printset :: SetExp -> String
printset (ident, identlist) = ident ++ "(" ++ (intercalate "," identlist) ++ ")"

insertAction :: Action -> String
insertAction (Insert ident setexp) = ident ++ " in " ++ (printset setexp)

printCenter :: [Action] -> String
printCenter centerDecls
    | null centerDecls = "=>"
    | otherwise = "=[" ++ (intercalate "," (map show centerDecls)) ++ "]=>"

getEnumerablesFromTypeDecls :: TypeDecls -> [String]
getEnumerablesFromTypeDecls [] = []
getEnumerablesFromTypeDecls ((varnames,constants,set):rest) =
    if set
        then varnames ++ (getEnumerablesFromTypeDecls rest)
        else getEnumerablesFromTypeDecls rest

getEnumerablesFromSetExp :: TypeDecls -> SetExp -> [Ident]
getEnumerablesFromSetExp typedecls (ident,identlist) = intersect identlist (getEnumerablesFromTypeDecls typedecls)

getEnumerablesFromMsg :: Msg -> TypeDecls -> [Ident]
getEnumerablesFromMsg _ [] = []
getEnumerablesFromMsg msg@(Atom ident) ((_,_,set):rest) =
    if set
        then [ident]
        else (getEnumerablesFromMsg msg rest)
getEnumerablesFromMsg (Cat msg1 msg2) typedecls = (getEnumerablesFromMsg msg1 typedecls) ++ (getEnumerablesFromMsg msg2 typedecls)
getEnumerablesFromMsg (Key _) typedecls = []
getEnumerablesFromMsg (Crypt msg _) typedecls = getEnumerablesFromMsg msg typedecls
getEnumerablesFromMsg (Scrypt msg _) typedecls = getEnumerablesFromMsg msg typedecls
getEnumerablesFromMsg (FactExp _ msg) typedecls = getEnumerablesFromMsg msg typedecls

getAgentsFromAction :: Action -> TypeDecls -> [Ident]
getAgentsFromAction (Insert ident setexp) typedecls = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Delete ident setexp) typedecls = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Select ident setexp) typedecls = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Create ident) typedecls = [] -- create expressions don't contribute to enumerables description
getAgentsFromAction (Ifnotin ident insetexp) typedecls = [] -- inset expressions don't contribute to enumerables description
getAgentsFromAction (Ifin ident insetexp) typedecls = [] -- ifin expressions are translated to select expressions so there should'nt be any at this stage
getAgentsFromAction (Fact (ident,msg)) typedecls = getEnumerablesFromMsg msg typedecls
getAgentsFromAction (Iffact (ident,msg)) typedecls = getEnumerablesFromMsg msg typedecls
getAgentsFromAction (Transmission ("_",receiver) msg) typedecls = getEnumerablesFromMsg msg typedecls
getAgentsFromAction (Transmission (sender,"_") msg) typedecls = getEnumerablesFromMsg msg typedecls
getAgentsFromAction (Transmission (sender,receiver) msg) typedecls = getEnumerablesFromMsg msg typedecls
getAgentsFromAction (Sync channel) typedecls = [] -- sync expressions don't contribute to enumerables description

getEnumerablesForRule :: TypeDecls -> Left -> Right -> [Ident]
getEnumerablesForRule typedecls (laction:lrest) (raction:rrest) =
    (getAgentsFromAction laction typedecls) ++ (getEnumerablesForRule typedecls lrest [])
    ++
    ((getAgentsFromAction raction typedecls) ++ (getEnumerablesForRule typedecls rrest []))
getEnumerablesForRule typedecls (action:rest) _ = (getAgentsFromAction action typedecls) ++ (getEnumerablesForRule typedecls rest [])
getEnumerablesForRule typedecls [] _ = []

removeDuplicates :: [String] -> [String]
removeDuplicates = map head . group . sort

getAgentDescription :: TypeDecls -> Left -> Right -> String
getAgentDescription typedecls l r
    | null (getEnumerablesForRule typedecls l r) = ""
    | otherwise = "\\" ++ (intercalate "," (removeDuplicates (getEnumerablesForRule typedecls l r))) ++ ".\n"

getUnderscoredVariables0 :: [InSetIdent] -> [Ident] -> [String]
getUnderscoredVariables0 [] _ = []
getUnderscoredVariables0 ((Ident varname):isrest) (ident:irest) = getUnderscoredVariables0 isrest irest
getUnderscoredVariables0 ((Underscore underscore):isrest) (ident:irest) = [ident] ++ getUnderscoredVariables0 isrest irest

getUnderscoredVariables :: InSetExp -> SetDecls -> String
getUnderscoredVariables _ [] = ""
getUnderscoredVariables insetexp@(setname,insetidentlist) ((ident,identlist):srest) =
    if (setname == ident)
        then intercalate "," (getUnderscoredVariables0 insetidentlist identlist)
        else getUnderscoredVariables insetexp srest

getSetDeclaration :: Ident -> SetDecls -> String
getSetDeclaration _ [] = ""
getSetDeclaration setname (set@(ident,identlist):srest) =
    if (setname == ident)
        then printSet set
        else getSetDeclaration setname srest

showleft0 :: Action -> SetDecls -> String
showleft0 (Ifnotin ident inset@(setname,insetidentlist)) setdecls = "forall " ++ (getUnderscoredVariables inset setdecls) ++ ". " ++ ident ++ " notin " ++ (getSetDeclaration setname setdecls)
showleft0 action setdecls = show action

showleft :: [Action] -> SetDecls -> [String]
showleft [] _ = []
showleft (action:rest) setdecls = [(showleft0 action setdecls)] ++ (showleft rest setdecls)

compileSubprotocol0 :: Subprotocol -> Left -> Center -> Right -> Agent -> TypeDecls -> SetDecls -> String
compileSubprotocol0 [] l c r agent typedecls setdecls =
    (getAgentDescription typedecls l r)
    ++ (intercalate "." (showleft l setdecls))
    ++ "\n"
    ++ (printCenter c)
    ++ "\n"
    ++ (intercalate "." (map show r))
    ++ "\n\n"
compileSubprotocol0 (a@(Insert ident setexp):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest l c (r ++ [a]) agent typedecls setdecls
compileSubprotocol0 (a@(Delete ident setexp):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest l c (delete (Select ident setexp) r) agent typedecls setdecls
compileSubprotocol0 (a@(Select ident setexp):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest (l ++ [a]) c (r ++ [a]) agent typedecls setdecls
compileSubprotocol0 (a@(Create ident):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest l (c ++ [a]) r agent typedecls setdecls
compileSubprotocol0 (a@(Ifnotin ident insetexp):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest (l ++ [a]) c r agent typedecls setdecls
compileSubprotocol0 (a@(Ifin ident insetexp):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest (l ++ [(Select ident (insetexpToSetexp insetexp setdecls))]) c (r ++ [(Select ident (insetexpToSetexp insetexp setdecls))]) agent typedecls setdecls
compileSubprotocol0 (a@(Fact factexp):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest l c (r ++ [a]) agent typedecls setdecls
compileSubprotocol0 (a@(Iffact factexp):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest (l ++ [a]) c (r ++ [a]) agent typedecls setdecls
compileSubprotocol0 (a@(Sync (sender,receiver)):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest l c r receiver typedecls setdecls
compileSubprotocol0 (a@(Transmission ("_",receiver) msg):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest (l ++ [a]) c r receiver typedecls setdecls
compileSubprotocol0 (a@(Transmission (sender,"_") msg):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest l c (r ++ [a]) "_" typedecls setdecls
compileSubprotocol0 (a@(Transmission (sender,receiver) msg):rest) l c r agent typedecls setdecls
    | null rest = --This corresponds to the sendlast translation rule
        (getAgentDescription typedecls l r)
        ++ (intercalate "." (showleft l setdecls))
        ++ "\n"
        ++ (printCenter c)
        ++ "\n"
        ++ (intercalate "." (map show (r ++ [a])))
        ++ "\n\n"
    | otherwise = --This corresponds to the send translation rule
        (getAgentDescription typedecls l r)
        ++ (intercalate "." (showleft l setdecls))
        ++ "\n"
        ++ (printCenter c)
        ++ "\n"
        ++ (intercalate "." (map show (r ++ [a])))
        ++ "\n\n"
        ++ compileSubprotocol0 ((Transmission ("_",receiver) msg) : rest) [] [] [] "_" typedecls setdecls

compileRules :: Subprotocol -> TypeDecls -> SetDecls -> String
compileRules actions typedecls setdecls = compileSubprotocol0 actions [] [] [] "_" typedecls setdecls

compileSubprotocols :: Subprotocols -> TypeDecls -> SetDecls -> String
compileSubprotocols [] _ _ = "\n"
compileSubprotocols (subprotocol:rest) typedecls setdecls =
    (compileRules subprotocol typedecls setdecls)
    ++ (compileSubprotocols rest typedecls setdecls)

compile :: Protocol -> String
compile p =
    --Protocol name
    let prot = getProtocolName p
        types = getTypeDecls p
        sets = getSetDecls p
        facts = getFactDecls p
        subs = getSubprotocolDecls p
        attacks = getAttackDecls p
    in

    --Compile Protocol name
    "Problem: "
    ++ (compileProtocolName prot)
    ++ "\n\n"

    --Compile Types
    ++ ("Types:\n")
    ++ (compileTypes types)
    ++ "\n"

    -- Compile Sets
    ++ "Sets:\n"
    ++ (compileSets sets)
    ++ "\n\n"

    -- Compile Functions
    ++ "Functions:\n"
    ++ (compileFunctions)
    ++ "\n\n"

    --Compile Facts
    ++ "Facts:\n"
    ++ (compileFacts facts)
    ++ "\n\n"

    --Compile Subprotocols
    ++ "Rules:\n"
    ++ (compileSubprotocols subs types sets)
    ++ "\n\n"

    --Compile Attacks
    -- ++ (compileAttacs attacks)
    -- ++ "\n"

main = do
    args <- getArgs
    when (null args) $ error ("No input file specified.")

    let filename = head args
    anbcode <- readFile filename
    let tokens = alexScanTokens anbcode
    let protocol = anbparser tokens

    --Write the resulting AIF to file
    writeFile (filename ++ ".aif") $ compile protocol
