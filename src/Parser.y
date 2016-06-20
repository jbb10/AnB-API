{
{-

AnB-API Parser 2016

Made by Jóhann Björn Björnsson as a part of AnB-API.

-}

module Parser where
import Lexer
import Ast
}


%name anbparser
%tokentype {Token}

%token
    ident	      	{ TATOM _ $$}
    number 	      	{ TNUMBER _ $$}
    "("		        { TOPENP _  }
    ")"		        { TCLOSEP _ }
    "{|"            { TOPENSCRYPT _}
    "|}"            { TCLOSESCRYPT _}
    "{"             { TOPENB _  }
    "}"		        { TCLOSEB _ }
    ":"	        	{ TCOLON _  }
    ";"             { TSEMICOLON _ }
    "/"             { TSLASH _}
    "->"	       	{ TCHANNEL _}
    ","		        { TCOMMA _ }
    "---"		    { TSEPARATOR _ }
    "_" 		    { TUNDERSCORE _ }
    "insert"        { TINSERT _ }
    "delete"        { TDELETE _ }
    "select"        { TSELECT _ }
    "from"          { TFROM _ }
    "create"        { TCREATE _ }
    "if"            { TIF _ }
    "notin"         { TNOTIN _ }
    "in"            { TIN _ }
    "sync"          { TSYNC _ }
    "pk"            { TPUBKEY _ }
    "inv"           { TINV _ }
    "sk"            { TSK _ }
    "value"         { TVALUE _ }
    "untyped"       { TUNTYPED _ }
    "h"             { TH _ }
    "referee"       { TREFEREE _ }
    "->referee"     { TTOREFEREE _ }
    "Protocol"      { TPROTOCOL _ }
    "Types"	        { TTYPES _}
    "Sets"          { TSETS _}
    "Facts"         { TFACTS _}
    "Subprotocols"  { TSUBPROTOCOLS _}
    "Attacks"	    { TATTACKS _}

%%

protocol :: {Protocol}
    : "Protocol" ":" ident
    "Types" ":" typedecls
    "Sets" ":" setdecls
    "Facts" ":" factdecls
    "Subprotocols" ":" subprotocoldecls
    "Attacks" ":" attackdecls {($3,$6,$9,$12,$15,$18)}

identlist :: {[Ident]}
    : ident {[$1]}
    | ident "," identlist {$1:$3}

typedecls :: {TypeDecls}
    : typedecl {$1}
    | typedecl typedecls {$1 ++ $2}

typedecl :: {[TypeDecl]}
    : identlist ":" "{" identlist "}" {generateTypeDeclFromList $1 (Set $4)}
    | identlist ":" "value" {generateTypeDeclFromList $1 (Value)}
    | identlist ":" "untyped" {generateTypeDeclFromList $1 (Untyped)}

setdecls :: {SetDecls}
    : {- empty -} {[]}
    | setdecl "," setdecls {$1:$3}
    | setdecl {[$1]}

setdecl :: {SetDecl}
    : ident "(" identlist ")" {($1,$3)}

factdecl :: {FactDecl}
    : ident "/" number {($1,read $3)}

factdecls :: {FactDecls}
    : {- empty -} {[]}
    | factdecl "," factdecls {$1:$3}
    | factdecl {[$1]}

subprotocoldecls :: {Subprotocols}
    : subprotocol {[$1]}
    | subprotocol "---" subprotocoldecls {$1:$3}

subprotocol :: {Subprotocol}
    : actionlist {$1}

actionlist :: {[Action]}
    : action {[$1]}
    | action actionlist {$1:$2}

action :: {Action}
    : localaction "insert" "(" ident "," setexp ")" {Insert $4 $6}
    | localaction "delete" "(" ident "," setexp ")" {Delete $4 $6}
    | localaction "select" ident "from" setexp {Select $3 $5}
    | localaction "create" "(" ident ")" {Create $4}
    | localaction "if" ident "notin" insetexp {Ifnotin $3 $5}
    | localaction factexp {Fact $2}
    | localaction "if" factexp {Iffact $3}
    | localaction "if" ident "in" insetexp {Ifin $3 $5}
    | channel ":" msg {Transmission $1 $3}
    | channel ":" "sync" {Sync $1}

localaction :: {Ident}
    : ident ":" {$1}

setexp :: {SetExp}
    : ident "(" identlist ")" {($1,$3)}

insetexp :: {InSetExp}
    : ident "(" insetidentlist ")" {($1,$3)}

insetidentlist :: {[InSetIdent]}
    : insetident {[$1]}
    | insetident "," insetidentlist {$1:$3}

insetident :: {InSetIdent}
    : ident {Ident $1}
    | "_" {Underscore "_"}

factexp :: {FactExp}
    : ident "(" msg ")" {($1,$3)}

channel :: {Channel}
    : ident "->" ident {($1,$3)}
    | ident "->" "_" {($1,"_")}
    | "_" "->" ident {("_",$3)}

msg :: {Msg}
    : ident               {Atom $1}
    | msg "," msg         {Cat $1 $3}
    | "{" msg "}" key     {Crypt $2 $4}
    | "{|" msg "|}" key   {Scrypt $2 $4}
    | key                 {Key $1}
    | "h" "(" ident "," msg ")" {Hash $3 $5}
    | "(" msg ")"         {$2}

key :: {Key}
    : generickey {GenericKey $1}
    | publickey {PublicKey $1}
    | privatekey {PrivateKey $1}
    | sharedkey {SharedKey $1}

generickey :: {Ident}
    : ident {$1}

publickey :: {Ident}
    : "pk" "(" ident ")" {$3}

privatekey :: {PublicKey}
    : "inv" "(" ident ")" {$3}
    | "inv" "(" publickey ")" {$3}

sharedkey :: {IdentList}
    : "sk" "(" identlist ")" {$3}

attackdecls :: {AttackDecls}
    : attack {[$1]}
    | attack "---" attackdecls {$1:$3}

attack :: {Attack}
    : attackaction {[$1]}
    | attackaction attack {$1:$2}

attackaction :: {Action}
    : "->referee" ":" msg {ToRefAction $3}
    | "referee" ":" "select" ident "from" setexp {RefSelect $4 $6}
    | "referee" ":" "if" ident "notin" insetexp {RefIfnotin $4 $6}
    | "referee" ":" "if" ident "in" insetexp {RefIfin $4 $6}
    | "referee" ":" "if" factexp {RefIffact $4}

---------------------------------

{
happyError :: [Token] -> a
happyError tks = error ("Parse error at " ++ lcn ++ "\n" )
	where
	lcn = case tks of
		[] -> "end of file"
		tk:_ -> "line " ++ show l ++ ", column " ++ show c ++ " - Token: " ++ show tk
			where
			AlexPn _ l c = token_posn tk
}
