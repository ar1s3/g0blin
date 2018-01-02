# g0blin

(WIP) jailbreak for iOS 10.3.x on A7-A9 devices

v0rtex + yalu102 + jailbreakd

IPA: https://github.com/thisiswisy/g0blin/releases/download/idk/g0blin_v1.ipa
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

## Supported devices
- iPhone 5S (10.3 - 10.3.3)
- iPhone 6/6 Plus (10.3 - 10.3.3)
- iPhone 6S/6S Plus (10.3 - 10.3.3)
- iPhone SE (10.3 - 10.3.3)
- iPad Mini 3 (10.3 - 10.3.3)
- iPad Mini 4 (10.3 - 10.3.3)
- iPad Air 2 (10.3 - 10.3.3)
- iPad Pro 12.9" 1st gen (10.3.3)

## Planned support
- iPad Pro 12.9" 1st gen (10.3-10.3.2)
- iPad Mini 2 (10.3 - 10.3.3)
- iPad Pro 9.7" (10.3 - 10.3.3)

## Not supported
- iPhone 7/7 Plus
- iPad Pro 12.9" 2nd gen
- iPad Pro 10.5"
- iPad 5 (aka iPad 2017)

thanks to everyone helping out, finding offsets, testing, etc!

creds: Luca Todesco, Siguza, Xerub, Saurik, @theninjaprawn
