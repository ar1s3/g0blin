# g0blin

(WIP) jailbreak for iOS 10.3.x on A7-A9 devices

v0rtex + yalu102 + jailbreakd

## what I added
- fixed reboot bug on some devices (updated exploit)
- way more offsets
- a simple jailbreakd to make Cydia temporarily work with custom cydo by Abraham Masri

If you want to just enable tweaks disable jailbreakd in the Settings page, if you want to use Cydia leave it enabled. After respring and/or after you quit g0blin, Cydia will not run anymore, so use Cydia as soon as you jailbreak. This is till there's a proper patch for setuid(0)

## what works
- tfp0
- kernel r/w access
- remount / as r/w
- amfi patched
- starts an ssh server listening on port 2222
- command line tools to install packages (dpkg, apt-get if you install it)
- Substrate

## what doesn't work
- GUI apps that need root priveledges are experiencing a sandbox error
- Filza can be fixed by applying the same extra entitlement given to Cydia
- I am trying to figure out the problem


thanks to everyone helping out, finding offsets, testing, etc!

creds: Lucky Tobasco, Sizuga, Xenu, Saurik
