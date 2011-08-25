Opensource clone implementation of YourTube. To build: copy the 
appropriate headers to your toolchain
sysroot, also copy libSandCastle.dylib into <sysroot>/usr/lib and make. You'll also need to add -F/System/Library/PrivateFrameworks to your LDFLAGS 
and incorporate the MFMusicLibrary, AppSupport frameworks and libSandCastle. Copy the dylib to /Library/MobileSubstrate/DynamicLibraries and start the daemon. 
PTDaemonDelegate and PTIPodImportDaemon can be used separately as a 
drop-in replacement for apps requiring similar functionality to 
Gremlin.

Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported license
I'm not responsible for any damage related to the use of this software.
