
ifndef .VERBOSE
.SILENT:
endif

ARG=10

main: main.asm
	nasm ./main.asm -oabak.o -felf64
	ld abak.o -oabak
	rm abak.o

permissions: main.asm
	make
	strip -s ./abak
	sudo chown root:root ./abak
	sudo chmod +s ./abak

install: main.asm
	make permissions
	sudo mv abak /bin/

run: main.asm
	make permissions
	./abak $(ARG)
	./abak

strace: main.asm
	make
	sudo strace ./abak
	sudo strace ./abak $(ARG)

debug: main.asm
	make
	sudo gdb abak
