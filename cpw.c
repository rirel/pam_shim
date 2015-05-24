/*
 * - cpw.c
 * Interface to crypt()
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <pwd.h>

#include "config.h"

int main(void) {
	char *pwd = crypt(PASS, SALT);
	FILE *f = fopen("hash.h", "w");
	fprintf(f, "#define HASH \"%s\"\n", pwd);
	fclose(f);
	return 0;
}
