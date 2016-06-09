module Main
where
import Control.Monad
import Parser
import Ast
import Lexer
import System.Environment
import Data.List
import Data.List.Split
import Data.Char

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
printType (identlist1,(Set slist)) = (intercalate "," identlist1) ++ "\t: {" ++ (intercalate "," slist) ++ "};\n"
printType (identlist1,(Value)) = (intercalate "," identlist1) ++ "\t: value;\n"
printType (identlist1,(Untyped)) = (intercalate "," identlist1) ++ "\t: untyped;\n"

compileTypes :: TypeDecls -> String
compileTypes [] = ""
compileTypes (typedecl:rest) = (printType typedecl) ++ compileTypes rest

containsSet :: String -> TypeDecls -> Bool
containsSet _ [] = False
containsSet name (((ident:_),_):rest) =
    if (name == ident)
        then True
        else containsSet name rest

errorCheckTypes :: TypeDecls -> TypeDecls
errorCheckTypes typedecls =
    if (not (containsSet "Agents" typedecls))
        then error("The Agents variable has not been defined")
        else if (not (containsSet "Dishonest" typedecls))
            then error ("The Dishonest variable has not been defined")
            else typedecls

addIntruderTypes :: TypeDecls -> TypeDecls
addIntruderTypes typedecls = typedecls ++ [(["M1","M2"],(Untyped))]

getTypeListFromTypeDecls :: TypeDecls -> [String]
getTypeListFromTypeDecls [] = []
getTypeListFromTypeDecls ((identlist1,_):rest) = identlist1 ++ (getTypeListFromTypeDecls rest)

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
compileFunctions = "public sign/2, scrypt/2, crypt/2, pair/2, pk/1, h/2;\nprivate inv/1;"

--Fact functions

printFact :: FactDecl -> String
printFact (ident,int) = ident ++ "/" ++ show int

compileFacts :: FactDecls -> String
compileFacts [] = "iknows/1, attack/0;"
compileFacts (factdecl:rest)
    | null rest = (printFact factdecl) ++ ", iknows/1, attack/0;"
    | otherwise = (printFact factdecl) ++ ", " ++ compileFacts rest

--Subprotocol functions

getIntruderRules :: TypeDecls -> String
getIntruderRules typedecls =
    if (containsSet "HashConstants" typedecls)
        then
            "%INTRUDER RULES START\n\
            \%Intruder knows all parties\n\
            \\\Agents. => iknows(Agents);\n\
            \\n\
            \%Intruder knows all public keys\n\
            \\\Agents. => iknows(pk(Agents));\n\
            \\n\
            \%All dishonest users know all dishonest user's private keys\n\
            \\\Dishonest. => iknows(inv(pk(Dishonest)));\n\
            \\n\
            \%Intruder can hash messages\n\
            \\\HashConstants. iknows(M1) => iknows(h(HashConstants,M1));\n\
            \\n\
            \%Intruder can make/take apart pairs\n\
            \iknows(pair(M1,M2)) => iknows(M1).iknows(M2);\n\
            \iknows(M1).iknows(M2) => iknows(pair(M1,M2));\n\
            \\n\
            \%Intruder can symmetrically encrypt/decrypt messages\n\
            \iknows(scrypt(M2,M1)).iknows(M2) => iknows(M1);\n\
            \iknows(M1).iknows(M2) => iknows(scrypt(M2,M1));\n\
            \\n\
            \%Intruder can asymmetrically encrypt/decrypt messages\n\
            \iknows(crypt(M2,M1)).iknows(inv(M2)) => iknows(M1);\n\
            \iknows(M1).iknows(M2) => iknows(crypt(M2,M1));\n\
            \\n\
            \%Intruder can sign and decipher signed messages\n\
            \iknows(sign(M1,M2)) => iknows(M2);\n\
            \iknows(M1).iknows(M2) => iknows(sign(M1,M2));\n\
            \%INTRUDER RULES END\n\n"
        else
            "%INTRUDER RULES START\n\
            \%Intruder knows all parties\n\
            \\\Agents. => iknows(Agents);\n\
            \\n\
            \%Intruder knows all public keys\n\
            \\\Agents. => iknows(pk(Agents));\n\
            \\n\
            \%All dishonest users know all dishonest user's private keys\n\
            \\\Dishonest. => iknows(inv(pk(Dishonest)));\n\
            \\n\
            \%Intruder can make/take apart pairs\n\
            \iknows(pair(M1,M2)) => iknows(M1).iknows(M2);\n\
            \iknows(M1).iknows(M2) => iknows(pair(M1,M2));\n\
            \\n\
            \%Intruder can symmetrically encrypt/decrypt messages\n\
            \iknows(scrypt(M2,M1)).iknows(M2) => iknows(M1);\n\
            \iknows(M1).iknows(M2) => iknows(scrypt(M2,M1));\n\
            \\n\
            \%Intruder can asymmetrically encrypt/decrypt messages\n\
            \iknows(crypt(M2,M1)).iknows(inv(M2)) => iknows(M1);\n\
            \iknows(M1).iknows(M2) => iknows(crypt(M2,M1));\n\
            \\n\
            \%Intruder can sign and decipher signed messages\n\
            \iknows(sign(M1,M2)) => iknows(M2);\n\
            \iknows(M1).iknows(M2) => iknows(sign(M1,M2));\n\
            \%INTRUDER RULES END\n\n"

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
getEnumerablesFromTypeDecls ((varnames,(Set _)):rest) = varnames ++ (getEnumerablesFromTypeDecls rest)
getEnumerablesFromTypeDecls ((varnames,_):rest) = getEnumerablesFromTypeDecls rest

getEnumerablesFromSetExp :: TypeDecls -> SetExp -> [Ident]
getEnumerablesFromSetExp typedecls (ident,identlist) = intersect identlist (getEnumerablesFromTypeDecls typedecls)

getAgentsFromAction :: Action -> TypeDecls -> SetDecls -> [Ident]
getAgentsFromAction (Insert ident setexp) typedecls setdecls = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Delete ident setexp) typedecls setdecls = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Select ident setexp) typedecls setdecls = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Create ident) typedecls setdecls = [] -- create expressions don't contribute to enumerables description
getAgentsFromAction (Ifnotin ident insetexp) typedecls setdecls = []-- ifnotin expressions don't contribute getEnumerablesFromSetExp typedecls (insetexpToSetexp insetexp setdecls)
getAgentsFromAction (Ifin ident insetexp) typedecls setdecls = [] -- ifin expressions are translated to select expressions before this stage so there shouldn't be any here
getAgentsFromAction (Fact (ident,msg)) typedecls setdecls = [] -- fact expressions don't contribute to enumerables description
getAgentsFromAction (Iffact (ident,msg)) typedecls setdecls = [] -- iffact expressions don't contribute to enumerables description
getAgentsFromAction (Transmission ("_",receiver) msg) typedecls setdecls = [] -- transmission expressions don't contribute to enumerables description
getAgentsFromAction (Transmission (sender,"_") msg) typedecls setdecls = [] -- transmission expressions don't contribute to enumerables description
getAgentsFromAction (Transmission (sender,receiver) msg) typedecls setdecls = [] -- transmission expressions don't contribute to enumerables description
getAgentsFromAction (Sync channel) typedecls setdecls = [] -- sync expressions don't contribute to enumerables description
getAgentsFromAction (ToRefAction msg) typedecls setdecls = []
getAgentsFromAction (RefSelect ident setexp) typedecls setdecls = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (RefIfnotin ident insetexp) typedecls setdecls = []
getAgentsFromAction (RefIfin ident insetexp) typedecls setdecls = []
getAgentsFromAction (RefIffact factexp) typedecls setdecls = []

getEnumerablesForRule0 :: TypeDecls -> [Action] -> SetDecls -> [Ident]
getEnumerablesForRule0 typedecls [] _ = []
getEnumerablesForRule0 typedecls (action:rest) setdecls=
    (getAgentsFromAction action typedecls setdecls) ++ (getEnumerablesForRule0 typedecls rest setdecls)

getEnumerablesForRule :: TypeDecls -> SetDecls -> Left -> Right -> [Ident]
getEnumerablesForRule typedecls setdecls left right =
    (getEnumerablesForRule0 typedecls left setdecls) ++ (getEnumerablesForRule0 typedecls right setdecls)

removeDuplicates :: [String] -> [String]
removeDuplicates = map head . group . sort

getEnumerablesDescription :: TypeDecls -> SetDecls -> Left -> Right -> String
getEnumerablesDescription typedecls setdecls l r
    | null (getEnumerablesForRule typedecls setdecls l r) = ""
    | otherwise = "\\" ++ (intercalate "," (removeDuplicates (getEnumerablesForRule typedecls setdecls l r))) ++ ". "

getUnderscoredVariables0 :: [InSetIdent] -> [Ident] -> [String]
getUnderscoredVariables0 [] _ = []
getUnderscoredVariables0 ((Ident varname):isrest) (ident:irest) = getUnderscoredVariables0 isrest irest
getUnderscoredVariables0 ((Underscore underscore):isrest) (ident:irest) = [ident] ++ getUnderscoredVariables0 isrest irest

insetexpContainsUnderscore :: InSetExp -> Bool
insetexpContainsUnderscore (ident,(isident:[])) = False
insetexpContainsUnderscore (ident,((Underscore u):isrest)) = True
insetexpContainsUnderscore (ident,((Ident i):isrest)) = insetexpContainsUnderscore (ident,isrest)

getUnderscoredVariables :: InSetExp -> SetDecls -> String
getUnderscoredVariables _ [] = ""
getUnderscoredVariables insetexp@(setname,insetidentlist) ((ident,identlist):srest) =
    if (insetexpContainsUnderscore insetexp)
        then if (setname == ident)
            then intercalate "," (getUnderscoredVariables0 insetidentlist identlist)
            else getUnderscoredVariables insetexp srest
        else if (setname == ident)
            then (intercalate "," (identlist))
            else getUnderscoredVariables insetexp srest

getSetDeclaration :: Ident -> SetDecls -> String
getSetDeclaration _ [] = ""
getSetDeclaration setname (set@(ident,identlist):srest) =
    if (setname == ident)
        then printSet set
        else getSetDeclaration setname srest

getVariablesFromInSetExpression :: InSetExp -> [Ident]
getVariablesFromInSetExpression (ident,[]) = []
getVariablesFromInSetExpression (ident,(isident:isrest)) =
    if (isUpper ((show isident)!!0))
        then (show isident) : getVariablesFromInSetExpression (ident,isrest)
        else getVariablesFromInSetExpression (ident,isrest)

showleft0 :: Action -> SetDecls -> String
showleft0 (Ifnotin ident inset@(setname,insetidentlist)) setdecls=
    if (insetexpContainsUnderscore inset)
        then
            "forall "
            ++ (getUnderscoredVariables inset setdecls)
            ++ ". "
            ++ ident
            ++ " notin "
            ++ (getSetDeclaration setname setdecls)
        else
            "forall "
            ++ (intercalate "," (getVariablesFromInSetExpression inset))
            ++ ". "
            ++ ident
            ++ " notin "
            ++ setname ++ "(" ++ (intercalate "," (map show insetidentlist)) ++ ")"
showleft0 (RefIfnotin ident inset@(setname,insetidentlist)) setdecls=
    if (insetexpContainsUnderscore inset)
        then
            "forall "
            ++ (getUnderscoredVariables inset setdecls)
            ++ ". "
            ++ ident
            ++ " notin "
            ++ (getSetDeclaration setname setdecls)
        else
            "forall "
            ++ (intercalate "," (getVariablesFromInSetExpression inset))
            ++ ". "
            ++ ident
            ++ " notin "
            ++ setname ++ "(" ++ (intercalate "," (map show insetidentlist)) ++ ")"
showleft0 action setdecls = show action

showleft :: Left -> SetDecls -> [String]
showleft [] _ = []
showleft (action:rest) setdecls = [(showleft0 action setdecls)] ++ (showleft rest setdecls)

compileSubprotocol0 :: Subprotocol -> Left -> Center -> Right -> Agent -> TypeDecls -> SetDecls -> String
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
    compileSubprotocol0 rest (l ++ [a]) c r agent typedecls setdecls
compileSubprotocol0 (a@(Sync (sender,receiver)):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest l c r receiver typedecls setdecls
compileSubprotocol0 (a@(Transmission ("_",receiver) msg):rest) l c r agent typedecls setdecls =
    compileSubprotocol0 rest (l ++ [a]) c r receiver typedecls setdecls
compileSubprotocol0 (a@(Transmission (sender,receiver) msg):rest) l c r agent typedecls setdecls
    | null rest = --This corresponds to the sendlast translation rule
        (getEnumerablesDescription typedecls setdecls l r)
        ++ (intercalate "." (showleft l setdecls))
        ++ "\n"
        ++ (printCenter c)
        ++ "\n"
        ++ (intercalate "." (map show (r ++ [a])))
        ++ ";\n\n"
    | otherwise = --This corresponds to the send translation rule
        (getEnumerablesDescription typedecls setdecls l r)
        ++ (intercalate "." (showleft l setdecls))
        ++ "\n"
        ++ (printCenter c)
        ++ "\n"
        ++ (intercalate "." (map show (r ++ [a])))
        ++ ";\n\n"
        ++ compileSubprotocol0 ((Transmission ("_",receiver) msg) : rest) [] [] [] receiver typedecls setdecls
compileSubprotocol0 [] l c r agent typedecls setdecls =
    (getEnumerablesDescription typedecls setdecls l r) --This happens when a subprotocol doesn't end with a send action
    ++ (intercalate "." (showleft l setdecls))
    ++ "\n"
    ++ (printCenter c)
    ++ "\n"
    ++ (intercalate "." (map show r))
    ++ ";\n\n"

compileRules :: Subprotocol -> TypeDecls -> SetDecls -> String
compileRules actions typedecls setdecls = compileSubprotocol0 actions [] [] [] "_" typedecls setdecls

compileSubprotocols :: Subprotocols -> TypeDecls -> SetDecls -> String
compileSubprotocols [] _ _ = ""
compileSubprotocols (subprotocol:rest) typedecls setdecls =
    (compileRules subprotocol typedecls setdecls)
    ++ (compileSubprotocols rest typedecls setdecls)

-- Attacks functions

isexpidentlistToSexpidentlist :: InSetExp -> [Ident]
isexpidentlistToSexpidentlist (ident,[]) = []
isexpidentlistToSexpidentlist (ident,(isident:rest)) = (show isident) : isexpidentlistToSexpidentlist (ident,rest)

compileAttack :: Attack -> Left -> TypeDecls -> SetDecls -> String
compileAttack (a@(RefIfin ident insetexp@(isident,isidentlist)):rest) l typedecls setdecls = compileAttack rest (l ++ [(Select ident ((isident,isexpidentlistToSexpidentlist insetexp)))]) typedecls setdecls
compileAttack (action:rest) l typedecls setdecls = compileAttack rest (l ++ [action]) typedecls setdecls
compileAttack [] l typedecls setdecls=
    (getEnumerablesDescription typedecls setdecls l [])
    ++ (intercalate "." (showleft l setdecls))
    ++ "\n"
    ++ "=>attack;"
    ++ "\n"

compileAttacks :: AttackDecls -> TypeDecls -> SetDecls -> String
compileAttacks [] typedecls setdecls = ""
compileAttacks (attack:rest) typedecls setdecls = (compileAttack attack [] typedecls setdecls) ++ (compileAttacks rest typedecls setdecls)

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
    ++ (compileTypes (errorCheckTypes (addIntruderTypes types)))
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
    ++ getIntruderRules types
    ++ (compileSubprotocols subs types sets)
    ++ "\n"

    --Compile Attacks
    ++ (compileAttacks attacks types sets)

main = do
    args <- getArgs
    when (null args) $ error ("No input file specified.")

    let filename = head args
    anbcode <- readFile filename
    let tokens = alexScanTokens anbcode
    let protocol = anbparser tokens

    --Write the resulting AIF code to file
    writeFile ((intercalate "." (init (splitOn "." filename))) ++ ".aif") $ compile protocol
