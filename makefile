
ifndef .VERBOSE
.SILENT:
endif

main: main.asm
	nasm ./main.asm -oabak.o -felf64
	ld abak.o -oabak
	rm abak.o
	sudo chown root:root ./abak
	sudo chmod +s ./abak

run: main.asm
	make
	./abak 10
	./abak

strace: main.asm
	make
	sudo strace ./abak
	sudo strace ./abak 20

debug: main.asm
	make
	sudo gdb abak
