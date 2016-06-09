SRCFILES = Parser.y Lexer.x Ast.hs AnB-API.hs

GENERATED = Lexer.hs Parser.hs

OUTPUT = anbapi

########################

all:
	make anbapi

########################

test: anbapi
	anbapi keyserver_new.anbapi
	fpaslan-mac keyserver_new.aif > keyserver_new.spass
	spass keyserver_new.spass

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
