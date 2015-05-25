/*
 * - od.c
 * Most of this code is shamelessly ripped from Apple's open source
 * chkpasswd implementation. As one might expect, it checks a password
 * via OpenDirectory.
 */

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <pwd.h>
#include <netinet/in.h>
#include <rpc/types.h>
#include <rpc/xdr.h>
#include <rpc/rpc.h>
#include <rpcsvc/yp_prot.h>
#include <rpcsvc/ypclnt.h>
#include <rpcsvc/yppasswd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/file.h>
#include <errno.h>

#include <OpenDirectory/OpenDirectory.h>


int od_check(const char *uname, const char *pass, const char *domain) {

	int	authenticated = 0;
	
	ODSessionRef	session = NULL;
	ODNodeRef		node = NULL;
	ODRecordRef		rec = NULL;
	CFStringRef		user = NULL;
	CFStringRef		location = NULL;
	CFStringRef		password = NULL;

	if (uname) user = CFStringCreateWithCString(NULL, uname, kCFStringEncodingUTF8);
	if (domain) location = CFStringCreateWithCString(NULL, domain, kCFStringEncodingUTF8);
	if (pass) password = CFStringCreateWithCString(NULL, pass, kCFStringEncodingUTF8);

	if (password) {
		session = ODSessionCreate(NULL, NULL, NULL);
		if (session) {
			if (location) {
				node = ODNodeCreateWithName(NULL, session, location, NULL);
			} else {
				node = ODNodeCreateWithNodeType(NULL, session, kODNodeTypeAuthentication, NULL);
			}
			if (node) {
				rec = ODNodeCopyRecord(node, kODRecordTypeUsers, user, NULL, NULL);
			}
			if (rec) {
				authenticated = ODRecordVerifyPassword(rec, password, NULL);
			}
		}
	}
	
	if (!authenticated) {
		exit(1);
	}
	return 0;
}
