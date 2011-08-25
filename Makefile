# Makefile for PwnTube
# Created by Árpád Goretity (H2CO3) on 24/08/2011
# Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License

PROJECT = PwnTube

CC = gcc
LD = $(CC)
CFLAGS = -isysroot /User/sysroot \
	 -I/usr/include/gpod-1.0 \
	 -I/usr/include/glib-2.0 \
	 -std=gnu99 \
	 -Wall \
	 -c
LDFLAGS = -isysroot /User/sysroot \
	  -w \
	  -F/System/Library/PrivateFrameworks \
	  -lobjc \
	  -lsubstrate \
	  -lSandCastle \
	  -framework Foundation \
	  -framework UIKit \
	  -framework MediaPlayer \
	  -framework YouTube \
	  -framework AppSupport \
	  -framework MFMusicLibrary
LDFLAGS_DYLIB = $(LDFLAGS) -dynamiclib

MAIN_OBJECTS = PwnTube.o PTDelegate.o PTTagViewController.o NSString+Searcher.o
DAEMON_OBJECTS = PTIPodImportDaemon.o PTDaemonDelegate.o

all: $(PROJECT).dylib pt_ipodimport_daemon

$(PROJECT).dylib: $(MAIN_OBJECTS)
	$(LD) $(LDFLAGS_DYLIB) -o $(PROJECT).dylib $(MAIN_OBJECTS)
	sudo cp $(PROJECT).dylib /Library/MobileSubstrate/DynamicLibraries

pt_ipodimport_daemon: $(DAEMON_OBJECTS)
	$(LD) $(LDFLAGS) -o pt_ipodimport_daemon $(DAEMON_OBJECTS)
	sudo cp pt_ipodimport_daemon /usr/libexec
	sudo kill $(shell cat /var/mobile/Library/PwnTube/pt_ipodimport_daemon.pid)
	/usr/libexec/pt_ipodimport_daemon

%.o: %.m
	$(CC) $(CFLAGS) -o $@ $^

