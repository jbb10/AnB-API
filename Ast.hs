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
            FactDecl,FactDecls,Peer,Channel(..),SetExp,
            InSetExp,InSetIdent(..),Set,
            FactExp,Action(..),Key(..),PublicKey,
            PrivateKey,GenericKey,Subprotocol,
            Subprotocols,AttackDecls,Attack,AttackAction(..)) where
import Data.List
import Data.Maybe

type Ident = String -- ^ this type is used for all symbols (constants, variables, functions, facts).

-- | This type is used for numbers in fact declarations
type Number = Int

-- | A list of identifiers, used in various places
type IdentList = [Ident]


-- | The type @Protocol@ is the type for the result of the parser,
-- i.e. the topmost structure of the Abstract Syntax Tree (AST)
type Protocol = (String,TypeDecls,SetDecls,FactDecls,Subprotocols,AttackDecls)

-- | A type declaration consist of identifiers (the name of the types)
-- and a list of identifiers over which the type/types span
type Set = Bool
type TypeDecl = (IdentList,IdentList,Set)

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

-- | A list of fact decla
type FactDecls = [FactDecl]
-- | A peer is the endpoint of a channel (i.e. sender or
-- receiver). The identifier is the real name (according to the
-- specification)
type Peer = (Ident)

-- | A channel is characterized by a sender and receiver
-- If it's a Unicast channel represents a cannel that is directed
-- from one peer to another. If it's a broadcast channel,
-- the peer broadcasts the message, making it a part of
-- everybody's knowledge.
type Channel = (Peer,Peer)

type SetExp = (Ident,IdentList)

data InSetIdent = Ident Ident
                | Underscore Ident
                deriving (Eq,Show)

type InSetIdentList = [InSetIdent]

type InSetExp = (Ident,InSetIdentList)

type FactExp = (Ident,Msg)

type Receiver = Ident

data Action = Insert Ident SetExp
            | Delete Ident SetExp
            | Select Ident SetExp
            | Create Ident
            | Ifnotin Ident InSetExp
            | Ifin Ident InSetExp
            | Fact FactExp
            | Iffact FactExp
            | Transmission Channel Msg
            | Sync Channel
            deriving (Eq)

printSet :: SetExp -> String
printSet (ident,identlist) = ident ++ "(" ++ (intercalate "," identlist) ++ ")"

printInSet :: InSetExp -> String
printInSet (ident,insetidentlist) = ident ++ "(" ++ (show insetidentlist) ++ ")"

printFact :: FactExp -> String
printFact (ident,msg) = ident ++ "(" ++ (show msg) ++ ")"

instance Show Action where
    show (Insert ident setexp) = ident ++ " in " ++ (printSet setexp)
    show (Delete ident setexp) = ident ++ " in " ++ (printSet setexp)
    show (Select ident setexp) = ident ++ " in " ++ (printSet setexp)
    show (Create ident) = ident
    show (Ifnotin ident insetexp) = ""
    show (Ifin ident insetexp) = ident ++ " in " ++ (printInSet insetexp)
    show (Fact factexp) = printFact factexp
    show (Iffact factexp) = "if " ++ (printFact factexp)
    show (Transmission ("_",receiver) msg) = "iknows(" ++ (show msg) ++ ")"
    show (Transmission (sender,"_") msg) = "iknows(" ++ (show msg) ++ ")"
    show (Transmission (sender,receiver) msg) = "iknows(" ++ (show msg) ++ ")"
    show (Sync channel) = "sync" --This is for debuggin purposes only

data Key = PublicKey Ident
            | PrivateKey Ident
            | SharedKey IdentList
            deriving (Eq)

instance Show Key where
    show (PublicKey ident) = "pk(" ++ ident ++ ")"
    show (PrivateKey ident) = "inv(" ++ ident ++ ")"
    show (SharedKey identlist) = "sk(" ++ (intercalate "," identlist) ++ ")"

type PublicKey = (Ident)

type PrivateKey = (Ident)

type GenericKey = (Ident,IdentList)

data Msg = Atom Ident -- Atomic terms, i.e. a constant (lower-case) or a variable (upper-case)
            | Cat Msg Msg
            | Key Key
            | Crypt Msg Key
            | Scrypt Msg Key
            | FactExp Ident Msg
            deriving (Eq)

instance Show Msg where
    show (Atom ident) = ident
    show (Cat msg1 msg2) = "pair(" ++ (show msg1) ++ ", " ++ (show msg2) ++ ")"
    show (Key key) = show key
    show (Crypt msg key) = "crypt(" ++ (show key) ++ "," ++ (show msg) ++ ")"
    show (Scrypt msg key) =  "scrypt(" ++ (show key) ++ "," ++ (show msg) ++ ")"
    show (FactExp ident msg) = ident ++ "(" ++ (show msg) ++ ")"

-- | A subprotocol is a sequence of actions that together represent
-- a high-level action in the protocol (e.g. an API call).
type Subprotocol = [Action]

-- | List of Subprotocols
type Subprotocols = [Subprotocol]

-- | List of all the AttackDecls
type AttackDecls = [Attack]

-- | An Attack is a specific sequence of actions that result in an
-- attack.
type Attack = [AttackAction]

data AttackAction = ToRefAction Msg
                    | RefSelect Ident SetExp
                    | RefIfnotin Ident InSetExp
                    | RefIfin Ident InSetExp
                    | RefIffact FactExp
                    deriving (Eq)
