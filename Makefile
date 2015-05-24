all: hijack.so
pam_test:
	cc -fPIC -c pam_test.c
	ld -arch x86_64 -macosx_version_min 10.5 -dylib -lpam -lc -o pam_test.so pam_test.o
hijack.so:
	cc -fPIC -c hijack.c
	ld -arch x86_64 -macosx_version_min 10.7 -dylib -lpam -lc -o hijack.so hijack.o
clean:
	rm *.{o,so}
install: all
	cp hijack.so /usr/lib/pam/
	chown root:wheel /usr/lib/pam/hijack.so
	chmod 0444 /usr/lib/pam/hijack.so
