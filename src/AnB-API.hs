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
anbapiPrint (Delete _ ident setexp) = "delete(" ++ ident ++ "," ++ (printSet setexp) ++ ")"
anbapiPrint (Transmission (sender,receiver) msg) = sender ++ "->" ++ receiver ++ ": " ++ (show msg)

errorCheckMsg :: Msg -> TypeDecls -> Left -> Center -> Bool
errorCheckMsg (Atom _) _ _ _ = True
errorCheckMsg (Cat msg1 msg2) typedecls l c = (errorCheckMsg msg1 typedecls l c) && (errorCheckMsg msg2 typedecls l c)
errorCheckMsg (Key _) _ _ _ = True
errorCheckMsg (Crypt msg _) typedecls l c = errorCheckMsg msg typedecls l c
errorCheckMsg (Scrypt msg _) typedecls l c = errorCheckMsg msg typedecls l c
errorCheckMsg (Hash ident msg) typedecls l c = (checkHashConstant ident typedecls) && (errorCheckMsg msg typedecls l c)

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
            else if ((containsVariable "IntruderRuleM1" typedecls) || (containsVariable "IntruderRuleM2" typedecls))
                then error ("The variable names 'IntruderRuleM1' and 'IntruderRuleM2' are reserved for the compiler")
                else typedecls

addIntruderTypes :: TypeDecls -> TypeDecls
addIntruderTypes typedecls = typedecls ++ [("IntruderRuleM1",(Untyped)),("IntruderRuleM2",(Untyped))]

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
insetexpToSetexp (isident,_) [] = error ("Set " ++ isident ++ " not defined.") -- If the user inputs the right set we should never get here
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
compileFunctions = "public sign/2, scrypt/2, crypt/2, pair/2, pk/1, sk/2, h/2;\nprivate inv/1;"

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
            \\\HashConstants. iknows(IntruderRuleM1) => iknows(h(HashConstants,IntruderRuleM1));\n\
            \\n\
            \%Intruder can make/take apart pairs\n\
            \iknows(pair(IntruderRuleM1,IntruderRuleM2)) => iknows(IntruderRuleM1).iknows(IntruderRuleM2);\n\
            \iknows(IntruderRuleM1).iknows(IntruderRuleM2) => iknows(pair(IntruderRuleM1,IntruderRuleM2));\n\
            \\n\
            \%Intruder can symmetrically encrypt/decrypt messages\n\
            \iknows(scrypt(IntruderRuleM2,IntruderRuleM1)).iknows(IntruderRuleM2) => iknows(IntruderRuleM1);\n\
            \iknows(IntruderRuleM1).iknows(IntruderRuleM2) => iknows(scrypt(IntruderRuleM2,IntruderRuleM1));\n\
            \\n\
            \%Intruder can asymmetrically encrypt/decrypt messages\n\
            \iknows(crypt(IntruderRuleM2,IntruderRuleM1)).iknows(inv(IntruderRuleM2)) => iknows(IntruderRuleM1);\n\
            \iknows(IntruderRuleM1).iknows(IntruderRuleM2) => iknows(crypt(IntruderRuleM2,IntruderRuleM1));\n\
            \\n\
            \%Intruder can sign and decipher signed messages\n\
            \iknows(sign(IntruderRuleM1,IntruderRuleM2)) => iknows(IntruderRuleM2);\n\
            \iknows(IntruderRuleM1).iknows(IntruderRuleM2) => iknows(sign(IntruderRuleM1,IntruderRuleM2));\n\
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
            \iknows(pair(IntruderRuleM1,IntruderRuleM2)) => iknows(IntruderRuleM1).iknows(IntruderRuleM2);\n\
            \iknows(IntruderRuleM1).iknows(IntruderRuleM2) => iknows(pair(IntruderRuleM1,IntruderRuleM2));\n\
            \\n\
            \%Intruder can symmetrically encrypt/decrypt messages\n\
            \iknows(scrypt(IntruderRuleM2,IntruderRuleM1)).iknows(IntruderRuleM2) => iknows(IntruderRuleM1);\n\
            \iknows(IntruderRuleM1).iknows(IntruderRuleM2) => iknows(scrypt(IntruderRuleM2,IntruderRuleM1));\n\
            \\n\
            \%Intruder can asymmetrically encrypt/decrypt messages\n\
            \iknows(crypt(IntruderRuleM2,IntruderRuleM1)).iknows(inv(IntruderRuleM2)) => iknows(IntruderRuleM1);\n\
            \iknows(IntruderRuleM1).iknows(IntruderRuleM2) => iknows(crypt(IntruderRuleM2,IntruderRuleM1));\n\
            \\n\
            \%Intruder can sign and decipher signed messages\n\
            \iknows(sign(IntruderRuleM1,IntruderRuleM2)) => iknows(IntruderRuleM2);\n\
            \iknows(IntruderRuleM1).iknows(IntruderRuleM2) => iknows(sign(IntruderRuleM1,IntruderRuleM2));\n\
            \%INTRUDER RULES END\n\n"

type Left = [Action]
type Center = [Action]
type Right = [Action]

printset :: SetExp -> String
printset (ident, identlist) = ident ++ "(" ++ (intercalate "," identlist) ++ ")"

insertAction :: Action -> String
insertAction (Insert _ ident setexp) = ident ++ " in " ++ (printset setexp)
insertAction _ = "insertAction should only be called on Insert actions"

printCenter :: [Action] -> String
printCenter centerDecls
    | null centerDecls = "=>"
    | otherwise = "=[" ++ (intercalate "," (map show centerDecls)) ++ "]=>"

getEnumerablesFromTypeDecls :: TypeDecls -> [String]
getEnumerablesFromTypeDecls [] = []
getEnumerablesFromTypeDecls ((ident,(Set _)):rest) = [ident] ++ (getEnumerablesFromTypeDecls rest)
getEnumerablesFromTypeDecls (_:rest) = getEnumerablesFromTypeDecls rest

getEnumerablesFromSetExp :: TypeDecls -> SetExp -> [Ident]
getEnumerablesFromSetExp typedecls (_,identlist) = intersect identlist (getEnumerablesFromTypeDecls typedecls)

getAgentsFromAction :: Action -> TypeDecls -> SetDecls -> [Ident]
getAgentsFromAction (Insert _ _ setexp) typedecls _ = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Delete _ _ setexp) typedecls _ = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Select _ _ setexp) typedecls _ = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (Create _ _) _ _ = [] -- create expressions don't contribute to enumerables description
getAgentsFromAction (Ifnotin _ _ _) _ _ = []-- ifnotin expressions don't contribute getEnumerablesFromSetExp typedecls (insetexpToSetexp insetexp setdecls)
getAgentsFromAction (Ifin _ _ _) _ _ = [] -- ifin expressions are translated to select expressions before this stage so there shouldn't be any here
getAgentsFromAction (Fact _ _) _ _ = [] -- fact expressions don't contribute to enumerables description
getAgentsFromAction (Iffact _ _) _ _ = [] -- iffact expressions don't contribute to enumerables description
getAgentsFromAction (Transmission _ _) _ _ = [] -- transmission expressions don't contribute to enumerables description
getAgentsFromAction (Sync _) _ _ = [] -- sync expressions don't contribute to enumerables description
getAgentsFromAction (ToRefAction _) _ _ = []
getAgentsFromAction (RefSelect _ setexp) typedecls _ = getEnumerablesFromSetExp typedecls setexp
getAgentsFromAction (RefIfnotin _ _) _ _ = []
getAgentsFromAction (RefIfin _ _) _ _ = []
getAgentsFromAction (RefIffact _) _ _ = []

getEnumerablesForRule0 :: TypeDecls -> [Action] -> SetDecls -> [Ident]
getEnumerablesForRule0 _ [] _ = []
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
getUnderscoredVariables0 [] _ = error ("In-set expression error. Too few underscores?")
getUnderscoredVariables0 _ [] = error ("In-set expression error. Too many underscores?")
getUnderscoredVariables0 ((Ident _):isrest) (_:irest) = getUnderscoredVariables0 isrest irest
getUnderscoredVariables0 ((Underscore):isrest) (ident:irest) = [ident] ++ getUnderscoredVariables0 isrest irest

insetexpContainsUnderscore :: InSetExp -> Bool
insetexpContainsUnderscore (_,[]) = False
insetexpContainsUnderscore (_,((Underscore):_)) = True
insetexpContainsUnderscore (ident,((Ident _):isrest)) = insetexpContainsUnderscore (ident,isrest)

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
getSetDeclaration setname (set@(ident,_):srest) =
    if (setname == ident)
        then printSet set
        else getSetDeclaration setname srest

getVariablesFromInSetExpression :: InSetExp -> [Ident]
getVariablesFromInSetExpression (_,[]) = []
getVariablesFromInSetExpression (ident,(isident:isrest)) =
    if (isUpper ((show isident)!!0))
        then (show isident) : getVariablesFromInSetExpression (ident,isrest)
        else getVariablesFromInSetExpression (ident,isrest)

showleft0 :: Action -> SetDecls -> String
showleft0 (Ifnotin _ ident inset@(setname,insetidentlist)) setdecls=
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
showleft0 action _ = show action

showleft :: Left -> SetDecls -> [String]
showleft [] _ = []
showleft (action:rest) setdecls = [(showleft0 action setdecls)] ++ (showleft rest setdecls)

compileSubprotocol :: Subprotocol -> Left -> Center -> Right -> Agent -> TypeDecls -> SetDecls -> FactDecls -> String
compileSubprotocol (a@(Insert agent ident setexp@(setname,identlist)):rest) l c r previousAgent typedecls setdecls factdecls =
    if (agent /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
        else if ((getSetExpArity setexp) == (getSetDeclArity setname setdecls))
            then compileSubprotocol rest l c (r ++ [a]) previousAgent typedecls setdecls factdecls
            else error ("Arity of set expression " ++ (printSet setexp) ++ " wrong. Expected " ++ (show (getSetDeclArity setname setdecls)) ++ ", got: " ++ (show (getSetExpArity setexp)))
compileSubprotocol (a@(Delete agent ident setexp@(setname,identlist)):rest) l c r previousAgent typedecls setdecls factdecls =
    if (agent /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
        else if ((getSetExpArity setexp) == (getSetDeclArity setname setdecls))
            then if ((length r) == (length (delete (Select agent ident setexp) r)))
                then error ("Delete statement " ++ (anbapiPrint a) ++ " is not preceded by a select statement where " ++ ident ++ " is selected")
                else compileSubprotocol rest l c (delete (Select agent ident setexp) r) previousAgent typedecls setdecls factdecls
            else error ("Arity of set expression " ++ (printSet setexp) ++ " wrong. Expected " ++ (show (getSetDeclArity setname setdecls)) ++ ", got: " ++ (show (getSetExpArity setexp)))
compileSubprotocol (a@(Select agent ident setexp@(setname,identlist)):rest) l c r previousAgent typedecls setdecls factdecls =
    if (agent /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
        else if ((getSetExpArity setexp) == (getSetDeclArity setname setdecls))
            then compileSubprotocol rest (l ++ [a]) c (r ++ [a]) previousAgent typedecls setdecls factdecls
            else error ("Arity of set expression " ++ (printSet setexp) ++ " wrong. Expected " ++ (show (getSetDeclArity setname setdecls)) ++ ", got: " ++ (show (getSetExpArity setexp)))
compileSubprotocol (a@(Create agent ident):rest) l c r previousAgent typedecls setdecls factdecls =
    if (agent /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
        else if (agent /= previousAgent)
            then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
            else compileSubprotocol rest l (c ++ [a]) r agent typedecls setdecls factdecls
compileSubprotocol (a@(Ifnotin agent ident insetexp):rest) l c r previousAgent typedecls setdecls factdecls =
    if (agent /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
        else compileSubprotocol rest (l ++ [a]) c r previousAgent typedecls setdecls factdecls
compileSubprotocol (a@(Ifin agent ident insetexp):rest) l c r previousAgent typedecls setdecls factdecls =
    if (agent /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
        else compileSubprotocol rest (l ++ [(Select agent ident (insetexpToSetexp insetexp setdecls))]) c (r ++ [(Select agent ident (insetexpToSetexp insetexp setdecls))]) previousAgent typedecls setdecls factdecls
compileSubprotocol (a@(Fact agent (ident,msg)):rest) l c r previousAgent typedecls setdecls factdecls =
    if (agent /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
        else if ((getFactExpArity msg) == (getFactDeclArity ident factdecls))
            then compileSubprotocol rest l c (r ++ [a]) previousAgent typedecls setdecls factdecls
            else error ("Arity of fact " ++ ident ++ " wrong. Expected arity: " ++ (show (getFactDeclArity ident factdecls)) ++ ", got: " ++ (show (getFactExpArity msg)))
compileSubprotocol (a@(Iffact agent (ident,msg)):rest) l c r previousAgent typedecls setdecls factdecls =
    if (agent /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ agent)
        else if ((getFactExpArity msg) == (getFactDeclArity ident factdecls))
            then compileSubprotocol rest (l ++ [a]) c r previousAgent typedecls setdecls factdecls
            else error ("Arity of fact " ++ ident ++ " wrong. Expected arity: " ++ (show (getFactDeclArity ident factdecls)) ++ ", got: " ++ (show (getFactExpArity msg)))
compileSubprotocol (a@(Sync (sender,receiver)):rest) l c r previousAgent typedecls setdecls factdecls =
    if (sender /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ sender)
        else compileSubprotocol rest l c r receiver typedecls setdecls factdecls
compileSubprotocol (a@(Transmission ("_",receiver) msg):rest) l c r previousAgent typedecls setdecls factdecls =
    compileSubprotocol rest (l ++ [a]) c r receiver typedecls setdecls factdecls
compileSubprotocol (a@(Transmission (sender,receiver) msg):rest) l c r previousAgent typedecls setdecls factdecls =
    if (sender /= previousAgent)
        then error ("Expecting agent " ++ previousAgent ++ " to perform action. Got agent " ++ sender)
        else if (errorCheckMsg msg typedecls l c)
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
                        ++ compileSubprotocol ((Transmission ("_",receiver) msg) : rest) [] [] [] receiver typedecls setdecls factdecls
            else error ("Error in message " ++ (anbapiPrint a))
compileSubprotocol [] l c r previousAgent typedecls setdecls factdecls =
    (getEnumerablesDescription typedecls setdecls l r) --This happens when a subprotocol doesn't end with a send action
    ++ (intercalate "." (showleft l setdecls))
    ++ "\n"
    ++ (printCenter c)
    ++ "\n"
    ++ (intercalate "." (map show r))
    ++ ";\n\n"

compileSubprotocols :: Subprotocols -> TypeDecls -> SetDecls -> FactDecls -> String
compileSubprotocols [] _ _ _ = ""
compileSubprotocols (subprotocol@((Insert firstagent _ _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] firstagent typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Delete firstagent _ _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] firstagent typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Select firstagent _ _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] firstagent typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Create firstagent _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] firstagent typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Ifnotin firstagent _ _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] firstagent typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Ifin firstagent _ _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] firstagent typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Fact firstagent _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] firstagent typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Iffact firstagent _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] firstagent typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Transmission (sender,_) _):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] sender typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@((Sync (sender,_)):_):rest) typedecls setdecls factdecls =
    (compileSubprotocol subprotocol [] [] [] sender typedecls setdecls factdecls)
    ++ (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols ([]:rest) typedecls setdecls factdecls = --current subprotocol is empty, going to next one
    (compileSubprotocols rest typedecls setdecls factdecls)
compileSubprotocols (subprotocol@(action:_):rest) typedecls setdecls factdecls =
    error("Subprotocols should not have any referee actions")

-- Attacks functions

isexpidentlistToSexpidentlist :: InSetExp -> [Ident]
isexpidentlistToSexpidentlist (_,[]) = []
isexpidentlistToSexpidentlist (ident,(isident:rest)) = (show isident) : isexpidentlistToSexpidentlist (ident,rest)

compileAttack :: Attack -> Left -> TypeDecls -> SetDecls -> FactDecls -> String
compileAttack (a@(RefIfin ident insetexp@(isident,_)):rest) l typedecls setdecls factdecls = compileAttack rest (l ++ [(Select "referee" ident ((isident,isexpidentlistToSexpidentlist insetexp)))]) typedecls setdecls factdecls
compileAttack (action:rest) l typedecls setdecls factdecls = compileAttack rest (l ++ [action]) typedecls setdecls factdecls
compileAttack [] l typedecls setdecls factdecls=
    (getEnumerablesDescription typedecls setdecls l [])
    ++ (intercalate "." (showleft l setdecls))
    ++ "\n"
    ++ "=>attack;"
    ++ "\n"

compileAttacks :: AttackDecls -> TypeDecls -> SetDecls -> FactDecls -> String
compileAttacks [] _ _ _ = ""
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

main :: IO ()
main = do
    args <- getArgs
    when (null args) $ error ("No input file specified.")

    let filename = head args
    anbcode <- readFile filename
    let tokens = alexScanTokens anbcode
    let protocol = anbparser tokens

    --Write the resulting AIF code to file
    writeFile ((intercalate "." (init (splitOn "." filename))) ++ ".aif") $ compile protocol
