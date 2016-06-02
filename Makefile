SRCFILES = Parser.y Lexer.x Ast.hs

GENERATED = Lexer.hs Parser.hs

OUTPUT = Main

########################

all:
	make anbpp
	./Main keyserver_basis.AnB++

########################

anbpp:	$(SRCFILES) $(GENERATED)
	ghc -o Main Main.hs

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
