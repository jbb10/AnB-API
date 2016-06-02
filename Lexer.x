{
{-

Open Source Fixedpoint Model-Checker version 2014

(C) Copyright Sebastian Moedersheim 2003,2014
(C) Copyright Paolo Modesti 2012
(C) Copyright Nicklas Bo Jensen 2012
(C) Copyright IBM Corp. 2009
(C) Copyright ETH Zurich (Swiss Federal Institute of Technology) 2003,2007

All Rights Reserved.

-}

module Lexer (Token(..),
              Ident,
    	      AlexPosn(..),
              alexScanTokens,
              token_posn) where
import Ast

}

%wrapper "posn"

$digit      = 0-9
$alpha      = [a-zA-Z]
$alphaL     = [a-z]
$alphaU     = [A-Z]
$identChar  = [a-zA-Z0-9_]

tokens :-

    $white+	              ;
    "#".*		          ;
    "("		                { (\ p s -> TOPENP p)  }
    ")"		                { (\ p s -> TCLOSEP p) }
    "{|"                    { (\ p s -> TOPENSCRYPT p)}
    "|}"                    { (\ p s -> TCLOSESCRYPT p)}
    "{"                     { (\ p s -> TOPENB p)  }
    "}"                     { (\ p s -> TCLOSEB p) }
    ":"                     { (\ p s -> TCOLON p)  }
    ";"                     { (\ p s -> TSEMICOLON p) }
    "/"                     { (\ p s -> TSLASH p) }
    "->"                    { (\ p s -> TCHANNEL p)}
    ","                     { (\ p s -> TCOMMA p) }
    "---"                   { (\ p s -> TSEPARATOR p) }
    "_"                     { (\ p s -> TUNDERSCORE p) }
    "insert"                { (\ p s -> TINSERT p) }
    "delete"                { (\ p s -> TDELETE p) }
    "select"                { (\ p s -> TSELECT p) }
    "from"                  { (\ p s -> TFROM p) }
    "create"                { (\ p s -> TCREATE p) }
    "if"                    { (\ p s -> TIF p) }
    "notin"                 { (\ p s -> TNOTIN p) }
    "in"                    { (\ p s -> TIN p) }
    "sync"                  { (\ p s -> TSYNC p) }
    "pk"                    { (\ p s -> TPUBKEY p) }
    "inv"                   { (\ p s -> TINV p) }
    "sk"                    { (\ p s -> TSK p) }
    "referee"               { (\ p s -> TREFEREE p) }
    "->referee"             { (\ p s -> TTOREFEREE p) }
    "Protocol"              { (\ p s -> TPROTOCOL p) }
    "Types"                 { (\ p s -> TTYPES p)}
    "Sets"                  { (\ p s -> TSETS p)}
    "Facts"                 { (\ p s -> TFACTS p)}
    "Subprotocols"          { (\ p s -> TSUBPROTOCOLS p)}
    "Attacks"               { (\ p s -> TATTACKS p)}
    $digit+                 { (\ p s -> TNUMBER p s) }
    $alpha $identChar*      { (\ p s -> TATOM p s) }

{

--- type Ident=String

data Token=
   TATOM AlexPosn Ident
   | TNUMBER AlexPosn Ident
   | TOPENP AlexPosn
   | TCLOSEP AlexPosn
   | TOPENSCRYPT AlexPosn
   | TCLOSESCRYPT AlexPosn
   | TOPENB AlexPosn
   | TCLOSEB AlexPosn
   | TCOLON AlexPosn
   | TSEMICOLON AlexPosn
   | TSLASH AlexPosn
   | TCHANNEL AlexPosn
   | TCOMMA AlexPosn
   | TSEPARATOR AlexPosn
   | TUNDERSCORE AlexPosn
   | TINSERT AlexPosn
   | TDELETE AlexPosn
   | TSELECT AlexPosn
   | TFROM AlexPosn
   | TCREATE AlexPosn
   | TIF AlexPosn
   | TNOTIN AlexPosn
   | TIN AlexPosn
   | TSYNC AlexPosn
   | TPUBKEY AlexPosn
   | TINV AlexPosn
   | TSK AlexPosn
   | TREFEREE AlexPosn
   | TTOREFEREE AlexPosn
   | TPROTOCOL AlexPosn
   | TTYPES AlexPosn
   | TSETS AlexPosn
   | TFACTS AlexPosn
   | TSUBPROTOCOLS AlexPosn
   | TATTACKS AlexPosn
   deriving (Eq,Show)

token_posn (TATOM p _)=p
token_posn (TNUMBER p _)=p
token_posn (TOPENP p)=p
token_posn (TCLOSEP p)=p
token_posn (TOPENSCRYPT p)=p
token_posn (TCLOSESCRYPT p)=p
token_posn (TOPENB p)=p
token_posn (TCLOSEB p)=p
token_posn (TCOLON p)=p
token_posn (TSEMICOLON p)=p
token_posn (TSLASH p)=p
token_posn (TCHANNEL p)=p
token_posn (TCOMMA p)=p
token_posn (TSEPARATOR p)=p
token_posn (TUNDERSCORE p)=p
token_posn (TINSERT p)=p
token_posn (TDELETE p)=p
token_posn (TSELECT p)=p
token_posn (TFROM p)=p
token_posn (TCREATE p)=p
token_posn (TIF p)=p
token_posn (TNOTIN p)=p
token_posn (TIN p)=p
token_posn (TSYNC p)=p
token_posn (TPUBKEY p)=p
token_posn (TINV p)=p
token_posn (TSK p)=p
token_posn (TREFEREE p)=p
token_posn (TTOREFEREE p)=p
token_posn (TPROTOCOL p)=p
token_posn (TTYPES p)=p
token_posn (TSETS p)=p
token_posn (TFACTS p)=p
token_posn (TSUBPROTOCOLS p)=p
token_posn (TATTACKS p)=p
}
