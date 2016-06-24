{-

Open Source Fixedpoint Model-Checker version 2014

(C) Copyright Sebastian Moedersheim 2003,2014
(C) Copyright Paolo Modesti 2012
(C) Copyright Nicklas Bo Jensen 2012
(C) Copyright IBM Corp. 2009
(C) Copyright ETH Zurich (Swiss Federal Institute of Technology) 2003,2007

All Rights Reserved.

-}

module Ast(Ident,IdentList,Msg(..),Protocol,
            TypeDecls,TypeDecl,SetDecl,SetDecls,
            FactDecl,FactDecls,Channel(..),SetExp,
            InSetExp,InSetIdent(..),Type(..), Agent,
            FactExp,Action(..),Key(..),PublicKey,
            PrivateKey,GenericKey,Subprotocol,
            Subprotocols,AttackDecls,Attack,
            generateTypeDeclFromList) where
import Data.List
import Data.Maybe

-- | The type Protocol is the type for the result of the parser,
-- i.e. the topmost structure of the Abstract Syntax Tree (AST)
type Protocol = (Ident,TypeDecls,SetDecls,FactDecls,Subprotocols,AttackDecls)

-- | This type is used for all symbols (constants, variables, functions, facts).
type Ident = String

-- | Simply a list of identifiers
type IdentList = [Ident]

-- | A type declaration consist of identifiers (the name of the types)
-- and a list of identifiers over which the type/types span
data Type = Set IdentList
          | Value
          | Untyped
          deriving(Show)

type TypeDecl = (Ident,Type)

-- | List of type declarations
type TypeDecls = [TypeDecl]

-- | A set is a basic database construct. The first identifier
-- represents the variable name of the set and the list of
-- identifiers represent the variables the set spans.
type SetDecl = (Ident, IdentList)

-- | List of set declarations
type SetDecls = [SetDecl]

-- | A fact declaration consists of an identifier representing
-- the variable name of the set and and integer representing the
-- number of arguments it takes.
type FactDecl = (Ident,Int)

-- | A list of fact declarations
type FactDecls = [FactDecl]

-- | A channel is characterized by a sender and receiver.
type Channel = (Ident,Ident)

type SetExp = (Ident,IdentList)

data InSetIdent = Ident Ident
                | Underscore
                deriving (Eq)

instance Show InSetIdent where
    show (Ident ident) = ident
    show (Underscore) = "_"

type InSetIdentList = [InSetIdent]

type InSetExp = (Ident,InSetIdentList)

type FactExp = (Ident,Msg)

type Agent = String

data Action = Insert Agent Ident SetExp
            | Delete Agent Ident SetExp
            | Select Agent Ident SetExp
            | Create Agent Ident
            | Ifnotin Agent Ident InSetExp
            | Ifin Agent Ident InSetExp
            | Fact Agent FactExp
            | Iffact Agent FactExp
            | Transmission Channel Msg
            | Sync Channel
            | ToRefAction Msg
            | RefSelect Ident SetExp
            | RefIfnotin Ident InSetExp
            | RefIfin Ident InSetExp
            | RefIffact FactExp
            deriving (Eq)

printSet :: SetExp -> String
printSet (ident,identlist) = ident ++ "(" ++ (intercalate "," identlist) ++ ")"

printInSet :: InSetExp -> String
printInSet (ident,insetidentlist) = ident ++ "(" ++ (show insetidentlist) ++ ")"

printFact :: FactExp -> String
printFact (ident,msg) = ident ++ "(" ++ (show msg) ++ ")"

instance Show Action where
    show (Insert _ ident setexp) = ident ++ " in " ++ (printSet setexp)
    show (Delete _ ident setexp) = ident ++ " in " ++ (printSet setexp)
    show (Select _ ident setexp) = ident ++ " in " ++ (printSet setexp)
    show (Create _ ident) = ident
    show (Ifnotin _ ident insetexp) = "" -- This is taken care of in showleft0
    show (Ifin _ ident insetexp) = "" -- This is taken care of in compileSubprotocol0
    show (Fact _ factexp) = printFact factexp
    show (Iffact _ factexp) = printFact factexp
    show (Transmission ("_",receiver) msg) = "iknows(" ++ (show msg) ++ ")"
    show (Transmission (sender,"_") msg) = "iknows(" ++ (show msg) ++ ")"
    show (Transmission (sender,receiver) msg) = "iknows(" ++ (show msg) ++ ")"
    show (Sync channel) = "sync" --This is for debuggin purposes only
    show (ToRefAction msg) = "iknows(" ++ (show msg) ++ ")"
    show (RefSelect ident setexp) = ident ++ " in " ++ (printSet setexp)
    show (RefIfnotin ident insetexp) = "" -- This is taken care of in showleft0
    show (RefIfin ident insetexp) =ident ++ " in " ++ (printInSet insetexp)
    show (RefIffact factexp) = printFact factexp

data Key = GenericKey Ident
            | PublicKey Ident
            | PrivateKey Ident
            | SharedKey IdentList
            deriving (Eq)

instance Show Key where
    show (GenericKey ident) = ident
    show (PublicKey ident) = "pk(" ++ ident ++ ")"
    show (PrivateKey ident) = "inv(" ++ ident ++ ")"
    show (SharedKey identlist) = "sk(" ++ (intercalate "," identlist) ++ ")"

type PublicKey = (Ident)

type PrivateKey = (Ident)

type GenericKey = (Ident,IdentList)

data Msg = Atom Ident -- Atomic terms, i.e. a constant (lower-case) or a variable (upper-case)
            | Cat Msg Msg -- Concatenation of two messages
            | Key Key -- A Key
            | Crypt Msg Key -- Asymmetrically encrypted message
            | Scrypt Msg Key -- Symmetrically encrypted message
            | Hash Ident Msg -- Hashed message (Ident corresponds to a hash constant)
            deriving (Eq)

instance Show Msg where
    show (Atom ident) = ident
    show (Cat msg1 msg2) = "pair(" ++ (show msg1) ++ ", " ++ (show msg2) ++ ")"
    show (Key key) = show key
    show (Crypt msg key) = "crypt(" ++ (show key) ++ "," ++ (show msg) ++ ")"
    show (Scrypt msg key) = "scrypt(" ++ (show key) ++ "," ++ (show msg) ++ ")"
    show (Hash ident msg) = "h(" ++ ident ++ "," ++ (show msg) ++ ")"

-- | A subprotocol is a sequence of actions that together represent
-- a high-level action in the protocol (e.g. an API call).
type Subprotocol = [Action]

-- | List of Subprotocols
type Subprotocols = [Subprotocol]

-- | List of all the AttackDecls
type AttackDecls = [Attack]

-- | An Attack is a specific sequence of actions that result in an
-- attack.
type Attack = [Action]

-- | These funcitons are used in the Parser
generateTypeDeclFromList :: IdentList -> Type -> [(Ident,Type)]
generateTypeDeclFromList [] _ = []
generateTypeDeclFromList (ident:rest) ttype = (ident,ttype) : (generateTypeDeclFromList rest ttype)
