.PHONY: clean

all: pam_shim.so

pam_test:
	cc -fPIC -c pam_test.c -o pam_test.o
	ld -arch x86_64 -macosx_version_min 10.5 -dylib -lpam -lc -o pam_test.so pam_test.o
cpw:
	cc cpw.c -o cpw -lc
	chmod 0700 cpw
genhash: cpw
	./cpw
pam_shim.so: genhash
	cc -fPIC -c shim.c -o shim.o
	ld -arch x86_64 -macosx_version_min 10.7 -dylib -lpam -lc -o pam_shim.so shim.o
clean:
	rm *.{o,so} hash.h cpw
install: all
	cp pam_shim.so /usr/lib/pam/
	chown root:wheel /usr/lib/pam/pam_shim.so
	chmod 0444 /usr/lib/pam/pam_shim.so
