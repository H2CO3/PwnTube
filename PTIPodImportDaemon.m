//
// PTIPodImportDaemon.m
// PwnTube
//
// Created by Árpád Goretity, 2011.
// Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License
//

#import <sys/types.h>
#import <sys/stat.h>
#import <stdio.h>
#import <stdlib.h>
#import <fcntl.h>
#import <errno.h>
#import <unistd.h>
#import <syslog.h>
#import <string.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import "PTDaemonDelegate.h"

int main() {

	// get root to access every file on the filesystem
	setuid(0);

	// copy myself
	pid_t pid = fork();
	if (pid < 0) {
		// fork() failed
		exit(EXIT_FAILURE);
	}
	if (pid > 0) {
		// fork() succeeded; write out the child's PID to let APT scripts know how to kill() it
		FILE *f = fopen("/var/mobile/Library/PwnTube/pt_ipodimport_daemon.pid", "w");
		if (f == NULL) {
			exit(EXIT_FAILURE);
		}
		fprintf(f, "%i", pid);
		fclose(f);
		exit(EXIT_SUCCESS);
	}

	umask(0);
	
	// not to become zombie
	pid_t sid = setsid();
	if (sid < 0) {
		exit(EXIT_FAILURE);
	}
	
	if ((chdir ("/")) < 0) {
		exit(EXIT_FAILURE);
	}
	
	// daemons don't need a terminal
	close (STDIN_FILENO);
	close (STDOUT_FILENO);
	close (STDERR_FILENO);
	
	// seteuid(mobile) in order not to corrupt the iPod library
	seteuid(501);
	
	// and the magic while(1)
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDate *now = [[NSDate alloc] init];
	// initialize the server
	PTDaemonDelegate *daemonDelegate = [PTDaemonDelegate sharedInstance];
	// this is needed for the NSRunloop to keep alive (it would exit w/o this)
	NSTimer *timer = [[NSTimer alloc] initWithFireDate: now interval: 30.0 target: nil selector: NULL userInfo: nil repeats: YES];
	[now release];
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer: timer forMode: NSDefaultRunLoopMode];
	[runLoop run];
	// hopefully never reached
	[timer release];
	[pool release];

	return 0;

}

