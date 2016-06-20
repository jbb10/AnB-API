SRCFILES = Parser.y Lexer.x Ast.hs AnB-API.hs

GENERATED = Lexer.hs Parser.hs

TESTKEYSERVER = ../examples/keyserver

TESTKEYSERVER_NEW = ../examples/keyserver_new

OUTPUT = anbapi

########################

all:
	make anbapi

########################

anbapi:	$(SRCFILES) $(GENERATED)
	ghc -o $(OUTPUT) AnB-API.hs

########################

Lexer.hs:	Lexer.x
	alex Lexer.x

########################

Parser.hs:	Parser.y
	happy -ioutput Parser.y

########################

clean:
	rm -f *\.hi *\.o output
	rm $(GENERATED)
	rm $(OUTPUT)
