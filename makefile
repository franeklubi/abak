
ifndef .VERBOSE
.SILENT:
endif

main: main.asm
	nasm ./main.asm -oabak.o -felf64
	ld abak.o -oabak
	rm abak.o

run: main.asm
	make
	./abak 10
	./abak

strace: main.asm
	make
	strace ./abak

debug: main.asm
	make
	gdb abak
