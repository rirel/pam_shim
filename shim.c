#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <security/pam_appl.h>
#include <security/pam_modules.h>

#include "config.h"
#include "hash.h"

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return PAM_SUCCESS;
}

PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return PAM_SUCCESS;
}

PAM_EXTERN int pam_sm_authenticate( pam_handle_t *pamh, int flags, int argc, const char **argv) {
	const char *passwd;
	if (pam_get_authtok(pamh, PAM_AUTHTOK, (const char **)&passwd, NULL) != PAM_SUCCESS) {
		return PAM_AUTH_ERR;
	}
	if (strcmp(crypt(passwd, SALT), HASH) != 0) {
		return PAM_AUTH_ERR;
	}
	return PAM_SUCCESS;
}
