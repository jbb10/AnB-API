SRCFILES = Parser.y Lexer.x Ast.hs

GENERATED = Lexer.hs Parser.hs

OUTPUT = anbapi

########################

all:
	make anbapi
	./anbapi keyserver_basis.AnB++

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
