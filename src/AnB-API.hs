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

--Tools

anbapiPrint :: Action -> String
anbapiPrint (Delete ident setexp) = "delete(" ++ ident ++ "," ++ (printSet setexp) ++ ")"
anbapiPrint (Transmission (sender,receiver) msg) = sender ++ "->" ++ receiver ++ ": " ++ (show msg)

-- getKeyIdent :: Key -> [Ident]
-- getKeyIdent (GenericKey ident) = [ident]
-- getKeyIdent (PublicKey ident) = [ident]
-- getKeyIdent (PrivateKey ident) = [ident]
-- getKeyIdent (SharedKey identlist) = identlist
--
-- isKeyCreated :: Key -> [Action] -> Bool
-- isKeyCreated key ((Select ident _):rest) =
--     if (elem ident (getKeyIdent key))
--         then True
--         else isKeyCreated key rest
-- isKeyCreated key ((Create ident):rest) =
--     if (elem ident (getKeyIdent key))
--         then True
--         else isKeyCreated key rest
-- isKeyCreated key (_:rest) = isKeyCreated key rest
-- isKeyCreated key [] = False
--
-- isIdentCreated :: Ident -> [Action] -> Bool
-- isIdentCreated ident ((Select sident _):rest) =
--     if (ident == sident)
--         then True
--         else isIdentCreated ident rest
-- isIdentCreated ident ((Create sident):rest) =
--     if (ident == sident)
--         then True
--         else isIdentCreated ident rest
-- isIdentCreated ident (_:rest) = isIdentCreated ident rest
-- isIdentCreated ident [] = False

errorCheckMsg :: Msg -> TypeDecls -> Left -> Center -> Bool
errorCheckMsg (Atom ident) typedecls l c = True
errorCheckMsg (Cat msg1 msg2) typedecls l c = (errorCheckMsg msg1 typedecls l c) && (errorCheckMsg msg2 typedecls l c)
errorCheckMsg (Key key) typedecls l c = True
errorCheckMsg (Crypt msg key) typedecls l c = True
errorCheckMsg (Scrypt msg key) typedecls l c = True
errorCheckMsg (Hash ident msg) typedecls l c = (checkHashConstant ident typedecls)

--Protocol functions

compileProtocolName :: String -> String
compileProtocolName name = name ++ ";"

--Types functions

printType :: TypeDecl -> String
printType (ident,(Set slist)) = ident ++ "\t: {" ++ (intercalate "," slist) ++ "};\n"
printType (ident,(Value)) = ident ++ "\t: value;\n"
printType (ident,(Untyped)) = ident ++ "\t: untyped;\n"

compileTypes :: TypeDecls -> String
compileTypes [] = ""
compileTypes (typedecl:rest) = (printType typedecl) ++ compileTypes rest

containsVariable :: String -> TypeDecls -> Bool
containsVariable _ [] = False
containsVariable name ((ident,_):rest) =
    if (name == ident)
        then True
        else containsVariable name rest

errorCheckTypes :: TypeDecls -> TypeDecls
errorCheckTypes typedecls =
    if (not (containsVariable "Agents" typedecls))
        then error("The Agents variable has not been defined")
        else if (not (containsVariable "Dishonest" typedecls))
            then error ("The Dishonest variable has not been defined")
            else if ((containsVariable "intruderRuleM1" typedecls) || (containsVariable "intruderRuleM2" typedecls))
                then error ("The variable names 'intruderRuleM1' and 'intruderRuleM2' are reserved for the compiler")
                else typedecls

addIntruderTypes :: TypeDecls -> TypeDecls
addIntruderTypes typedecls = typedecls ++ [("intruderRuleM1",(Untyped)),("intruderRuleM2",(Untyped))]

getTypeListFromTypeDecls :: TypeDecls -> [String]
getTypeListFromTypeDecls [] = []
getTypeListFromTypeDecls ((ident,_):rest) = [ident] ++ (getTypeListFromTypeDecls rest)

checkHashConstant :: Ident -> TypeDecls -> Bool
checkHashConstant constant [] = error ("Hash constant " ++ constant ++ " not defined in HashConstants.")
checkHashConstant constant ((sident,(Set identlist)):rest) =
    if ((elem constant identlist) && (sident == "HashConstants"))
        then True
        else checkHashConstant constant rest
checkHashConstant constant (_:rest) = checkHashConstant constant rest

--Set functions

printSet :: SetDecl -> String
printSet (ident,identlist) = ident ++ "(" ++ (intercalate "," identlist) ++ ")"

compileSets :: SetDecls -> String
compileSets [] = ";"
compileSets (setdecl:rest)
    | null rest = (printSet setdecl) ++ compileSets rest
    | otherwise = (printSet setdecl) ++ ", " ++ compileSets rest

isidentlistToidentlist :: [InSetIdent] -> [Ident]
isidentlistToidentlist [] = []
isidentlistToidentlist (isident:rest) = [show isident] ++ (isidentlistToidentlist rest)

insetexpToSetexp :: InSetExp -> SetDecls -> SetExp
insetexpToSetexp (isident,isidentlist) [] = error ("Set " ++ isident ++ " not defined.") -- If the user inputs the right set we should never get here
insetexpToSetexp isexp@(isident,isidentlist) ((sident,sidentlist):srest) =
    if (insetexpContainsUnderscore isexp)
        then if (isident == sident)
            then (sident,sidentlist)
            else (insetexpToSetexp isexp srest)
        else (isident,(isidentlistToidentlist isidentlist))

getSetExpArity :: SetExp -> Int
getSetExpArity (_,identlist) = length identlist

getSetDeclArity :: Ident -> SetDecls -> Int
getSetDeclArity setname [] = error ("Set " ++ setname ++ " not found in set declarations")
getSetDeclArity setname ((ident,identlist):rest) =
    if (setname == ident)
        then (length identlist)
        else getSetDeclArity setname rest

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

getFactExpArity :: Msg -> Int
getFactExpArity (Atom _) = 1
getFactExpArity (Cat msg1 msg2) = (getFactExpArity msg1) + (getFactExpArity msg2)
getFactExpArity (Key _) = 1
getFactExpArity (Crypt _ _) = 1
getFactExpArity (Scrypt _ _) = 1
getFactExpArity (Hash _ _) = 1

getFactDeclArity :: Ident -> FactDecls -> Int
getFactDeclArity ident [] = error ("Fact " ++ ident ++ " not found in fact declarations")
getFactDeclArity ident ((fident,number):rest) =
    if (ident == fident)
        then number
        else (getFactDeclArity ident rest)

--Subprotocol functions

getIntruderRules :: TypeDecls -> String
getIntruderRules typedecls =
    if (containsVariable "HashConstants" typedecls)
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
            \\\HashConstants. iknows(intruderRuleM1) => iknows(h(HashConstants,intruderRuleM1));\n\
            \\n\
            \%Intruder can make/take apart pairs\n\
            \iknows(pair(intruderRuleM1,intruderRuleM2)) => iknows(intruderRuleM1).iknows(intruderRuleM2);\n\
            \iknows(intruderRuleM1).iknows(intruderRuleM2) => iknows(pair(intruderRuleM1,intruderRuleM2));\n\
            \\n\
            \%Intruder can symmetrically encrypt/decrypt messages\n\
            \iknows(scrypt(intruderRuleM2,intruderRuleM1)).iknows(intruderRuleM2) => iknows(intruderRuleM1);\n\
            \iknows(intruderRuleM1).iknows(intruderRuleM2) => iknows(scrypt(intruderRuleM2,intruderRuleM1));\n\
            \\n\
            \%Intruder can asymmetrically encrypt/decrypt messages\n\
            \iknows(crypt(intruderRuleM2,intruderRuleM1)).iknows(inv(intruderRuleM2)) => iknows(intruderRuleM1);\n\
            \iknows(intruderRuleM1).iknows(intruderRuleM2) => iknows(crypt(intruderRuleM2,intruderRuleM1));\n\
            \\n\
            \%Intruder can sign and decipher signed messages\n\
            \iknows(sign(intruderRuleM1,intruderRuleM2)) => iknows(intruderRuleM2);\n\
            \iknows(intruderRuleM1).iknows(intruderRuleM2) => iknows(sign(intruderRuleM1,intruderRuleM2));\n\
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
            \iknows(pair(intruderRuleM1,intruderRuleM2)) => iknows(intruderRuleM1).iknows(intruderRuleM2);\n\
            \iknows(intruderRuleM1).iknows(intruderRuleM2) => iknows(pair(intruderRuleM1,intruderRuleM2));\n\
            \\n\
            \%Intruder can symmetrically encrypt/decrypt messages\n\
            \iknows(scrypt(intruderRuleM2,intruderRuleM1)).iknows(intruderRuleM2) => iknows(intruderRuleM1);\n\
            \iknows(intruderRuleM1).iknows(intruderRuleM2) => iknows(scrypt(intruderRuleM2,intruderRuleM1));\n\
            \\n\
            \%Intruder can asymmetrically encrypt/decrypt messages\n\
            \iknows(crypt(intruderRuleM2,intruderRuleM1)).iknows(inv(intruderRuleM2)) => iknows(intruderRuleM1);\n\
            \iknows(intruderRuleM1).iknows(intruderRuleM2) => iknows(crypt(intruderRuleM2,intruderRuleM1));\n\
            \\n\
            \%Intruder can sign and decipher signed messages\n\
            \iknows(sign(intruderRuleM1,intruderRuleM2)) => iknows(intruderRuleM2);\n\
            \iknows(intruderRuleM1).iknows(intruderRuleM2) => iknows(sign(intruderRuleM1,intruderRuleM2));\n\
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
getEnumerablesFromTypeDecls ((ident,(Set _)):rest) = [ident] ++ (getEnumerablesFromTypeDecls rest)
getEnumerablesFromTypeDecls (typedecl:rest) = getEnumerablesFromTypeDecls rest

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
getUnderscoredVariables0 [] [] = []
getUnderscoredVariables0 [] (i:is) = error ("In-set expression error. Too few underscores?")
getUnderscoredVariables0 (is:iss) [] = error ("In-set expression error. Too many underscores?")
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

compileSubprotocol0 :: Subprotocol -> Left -> Center -> Right -> Agent -> TypeDecls -> SetDecls -> FactDecls -> String
compileSubprotocol0 (a@(Insert ident setexp@(setname,identlist)):rest) l c r agent typedecls setdecls factdecls =
    if ((getSetExpArity setexp) == (getSetDeclArity setname setdecls))
        then compileSubprotocol0 rest l c (r ++ [a]) agent typedecls setdecls factdecls
        else error ("Arity of set expression " ++ (printSet setexp) ++ " wrong. Expected " ++ (show (getSetDeclArity setname setdecls)) ++ ", got: " ++ (show (getSetExpArity setexp)))
compileSubprotocol0 (a@(Delete ident setexp@(setname,identlist)):rest) l c r agent typedecls setdecls factdecls =
    if ((getSetExpArity setexp) == (getSetDeclArity setname setdecls))
        then if ((length r) == (length (delete (Select ident setexp) r)))
            then error ("Delete statement " ++ (anbapiPrint a) ++ " is not preceded by a select statement where " ++ ident ++ " is selected")
            else compileSubprotocol0 rest l c (delete (Select ident setexp) r) agent typedecls setdecls factdecls
        else error ("Arity of set expression " ++ (printSet setexp) ++ " wrong. Expected " ++ (show (getSetDeclArity setname setdecls)) ++ ", got: " ++ (show (getSetExpArity setexp)))
compileSubprotocol0 (a@(Select ident setexp@(setname,identlist)):rest) l c r agent typedecls setdecls factdecls =
    if ((getSetExpArity setexp) == (getSetDeclArity setname setdecls))
        then compileSubprotocol0 rest (l ++ [a]) c (r ++ [a]) agent typedecls setdecls factdecls
        else error ("Arity of set expression " ++ (printSet setexp) ++ " wrong. Expected " ++ (show (getSetDeclArity setname setdecls)) ++ ", got: " ++ (show (getSetExpArity setexp)))
compileSubprotocol0 (a@(Create ident):rest) l c r agent typedecls setdecls factdecls =
    compileSubprotocol0 rest l (c ++ [a]) r agent typedecls setdecls factdecls
compileSubprotocol0 (a@(Ifnotin ident insetexp):rest) l c r agent typedecls setdecls factdecls =
    compileSubprotocol0 rest (l ++ [a]) c r agent typedecls setdecls factdecls
compileSubprotocol0 (a@(Ifin ident insetexp):rest) l c r agent typedecls setdecls factdecls =
    compileSubprotocol0 rest (l ++ [(Select ident (insetexpToSetexp insetexp setdecls))]) c (r ++ [(Select ident (insetexpToSetexp insetexp setdecls))]) agent typedecls setdecls factdecls
compileSubprotocol0 (a@(Fact (ident,msg)):rest) l c r agent typedecls setdecls factdecls =
    if ((getFactExpArity msg) == (getFactDeclArity ident factdecls))
        then compileSubprotocol0 rest l c (r ++ [a]) agent typedecls setdecls factdecls
        else error ("Arity of fact " ++ ident ++ " wrong. Expected arity: " ++ (show (getFactDeclArity ident factdecls)) ++ ", got: " ++ (show (getFactExpArity msg)))
compileSubprotocol0 (a@(Iffact (ident,msg)):rest) l c r agent typedecls setdecls factdecls =
    if ((getFactExpArity msg) == (getFactDeclArity ident factdecls))
        then compileSubprotocol0 rest (l ++ [a]) c r agent typedecls setdecls factdecls
        else error ("Arity of fact " ++ ident ++ " wrong. Expected arity: " ++ (show (getFactDeclArity ident factdecls)) ++ ", got: " ++ (show (getFactExpArity msg)))
compileSubprotocol0 (a@(Sync (sender,receiver)):rest) l c r agent typedecls setdecls factdecls =
    compileSubprotocol0 rest l c r receiver typedecls setdecls factdecls
compileSubprotocol0 (a@(Transmission ("_",receiver) msg):rest) l c r agent typedecls setdecls factdecls =
    compileSubprotocol0 rest (l ++ [a]) c r receiver typedecls setdecls factdecls
compileSubprotocol0 (a@(Transmission (sender,receiver) msg):rest) l c r agent typedecls setdecls factdecls =
    if (errorCheckMsg msg typedecls l c)
        then
            if (null rest) --This corresponds to the sendlast translation rule
                then if ((null l) && (null c) && (null r))
                        then
                            ""
                        else
                            (getEnumerablesDescription typedecls setdecls l r)
                            ++ (intercalate "." (showleft l setdecls))
                            ++ "\n"
                            ++ (printCenter c)
                            ++ "\n"
                            ++ (intercalate "." (map show (r ++ [a])))
                            ++ ";\n\n"
                else --This corresponds to the send translation rule
                    (getEnumerablesDescription typedecls setdecls l r)
                    ++ (intercalate "." (showleft l setdecls))
                    ++ "\n"
                    ++ (printCenter c)
                    ++ "\n"
                    ++ (intercalate "." (map show (r ++ [a])))
                    ++ ";\n\n"
                    ++ compileSubprotocol0 ((Transmission ("_",receiver) msg) : rest) [] [] [] receiver typedecls setdecls factdecls
        else "Error in message " ++ (anbapiPrint a)
compileSubprotocol0 [] l c r agent typedecls setdecls factdecls =
    (getEnumerablesDescription typedecls setdecls l r) --This happens when a subprotocol doesn't end with a send action
    ++ (intercalate "." (showleft l setdecls))
    ++ "\n"
    ++ (printCenter c)
    ++ "\n"
    ++ (intercalate "." (map show r))
    ++ ";\n\n"

compileRules :: Subprotocol -> TypeDecls -> SetDecls -> FactDecls -> String
compileRules actions typedecls setdecls factdecls = compileSubprotocol0 actions [] [] [] "_" typedecls setdecls factdecls

compileSubprotocols :: Subprotocols -> TypeDecls -> SetDecls -> FactDecls -> String
compileSubprotocols [] _ _ _ = ""
compileSubprotocols (subprotocol:rest) typedecls setdecls factdecls =
    (compileRules subprotocol typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)

-- Attacks functions

isexpidentlistToSexpidentlist :: InSetExp -> [Ident]
isexpidentlistToSexpidentlist (ident,[]) = []
isexpidentlistToSexpidentlist (ident,(isident:rest)) = (show isident) : isexpidentlistToSexpidentlist (ident,rest)

compileAttack :: Attack -> Left -> TypeDecls -> SetDecls -> FactDecls -> String
compileAttack (a@(RefIfin ident insetexp@(isident,isidentlist)):rest) l typedecls setdecls factdecls = compileAttack rest (l ++ [(Select ident ((isident,isexpidentlistToSexpidentlist insetexp)))]) typedecls setdecls factdecls
compileAttack (action:rest) l typedecls setdecls factdecls = compileAttack rest (l ++ [action]) typedecls setdecls factdecls
compileAttack [] l typedecls setdecls factdecls=
    (getEnumerablesDescription typedecls setdecls l [])
    ++ (intercalate "." (showleft l setdecls))
    ++ "\n"
    ++ "=>attack;"
    ++ "\n"

compileAttacks :: AttackDecls -> TypeDecls -> SetDecls -> FactDecls -> String
compileAttacks [] typedecls setdecls factdecls = ""
compileAttacks (attack:rest) typedecls setdecls factdecls = (compileAttack attack [] typedecls setdecls factdecls) ++ (compileAttacks rest typedecls setdecls factdecls)

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
    ++ compileProtocolName prot
    ++ "\n\n"

    --Compile Types
    ++ "Types:\n"
    ++ (compileTypes $ addIntruderTypes $ errorCheckTypes types)
    ++ "\n"

    -- Compile Sets
    ++ "Sets:\n"
    ++ compileSets sets
    ++ "\n\n"

    -- Compile Functions
    ++ "Functions:\n"
    ++ compileFunctions
    ++ "\n\n"

    --Compile Facts
    ++ "Facts:\n"
    ++ compileFacts facts
    ++ "\n\n"

    --Compile Subprotocols
    ++ "Rules:\n"
    ++ getIntruderRules types
    ++ (compileSubprotocols subs types sets facts)
    ++ "\n"

    --Compile Attacks
    ++ (compileAttacks attacks types sets facts)

main = do
    args <- getArgs
    when (null args) $ error ("No input file specified.")

    let filename = head args
    anbcode <- readFile filename
    let tokens = alexScanTokens anbcode
    let protocol = anbparser tokens

    --Write the resulting AIF code to file
    writeFile ((intercalate "." (init (splitOn "." filename))) ++ ".aif") $ compile protocol
