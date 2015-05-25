CC=clang
OSX_VERSION=10.10

.PHONY: clean install

all: pam_shim.so

pam_test:
	$(CC) -fPIC -c pam_test.c -o pam_test.o
	ld -arch x86_64 -macosx_version_min $(OSX_VERSION) -dylib -lpam -lc -o pam_test.so pam_test.o
cpw:
	$(CC) cpw.c -o cpw -lc
	chmod 0700 cpw
genhash: cpw
	./cpw
od.o:
	$(CC) -fPIC -c od.m -o od.o
pam_shim.so: genhash od.o
	$(CC) -fPIC -c shim.c -o shim.o
	ld -arch x86_64 -macosx_version_min $(OSX_VERSION) -framework CoreFoundation -framework OpenDirectory -dylib -lpam -lc -o pam_shim.so shim.o od.o
clean:
	rm *.{o,so} hash.h cpw
install:
	cp pam_shim.so /usr/lib/pam/
	chown root:wheel /usr/lib/pam/pam_shim.so
	chmod 0444 /usr/lib/pam/pam_shim.so
