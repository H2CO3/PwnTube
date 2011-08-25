//
// PTDaemonDelegate.m
// PwnTube
//
// Created by Árpád Goretity, 2011.
// Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License
//

#import "PTDaemonDelegate.h"

static id _sharedInstance = nil;

@implementation PTDaemonDelegate

+ (id) sharedInstance {
	if (_sharedInstance == nil) {
		_sharedInstance = [[self alloc] init];
	}
	return _sharedInstance;
}

- (id) init {
	self = [super init];
	// register to 'Add to iPod' message as server
	center = [CPDistributedMessagingCenter centerNamed: @"org.h2co3.pwntube"];
	[center registerForMessageName: @"org.h2co3.pwntube.ipodimport" target: self selector: @selector(handleMessageNamed:withUserInfo:)];
	[center runServerOnCurrentThread];
	return self;
}

- (NSDictionary *) handleMessageNamed: (NSString *) name withUserInfo: (NSDictionary *) userInfo {
	BOOL success = NO;
	if ([name isEqualToString: @"org.h2co3.pwntube.ipodimport"]) {
		// somebody wants a track to be imported to the iPod
		// find the filename
		NSString *fileName = [userInfo objectForKey: @"PTTrackFileName"];
		// song/video metadata
		MFMusicTrack *track = [[MFMusicTrack alloc] init];
		track.title = [userInfo objectForKey: @"PTTrackTitle"];
		track.album = [userInfo objectForKey: @"PTTrackAlbum"];
		track.artist = [userInfo objectForKey: @"PTTrackArtist"];
		track.genre = [userInfo objectForKey: @"PTTrackGenre"];
		track.year = [userInfo objectForKey: @"PTTrackYear"];
		track.composer = [userInfo objectForKey: @"PTTrackComposer"];
		track.comment = [userInfo objectForKey: @"PTTrackComment"];
		track.rating = [[userInfo objectForKey: @"PTTrackRating"] intValue];
		track.category = [userInfo objectForKey: @"PTTrackCategory"];
		track.mediatype = [[userInfo objectForKey: @"PTTrackMediatype"] intValue];
		// now actually add the track, write out the iPod library
		[[MFMusicLibrary sharedLibrary] addFile: fileName asTrack: track];
		success = [[MFMusicLibrary sharedLibrary] write];
		[track release];
	}
	// return whether or not the library update has succeeded
	NSNumber *successNumber = [[NSNumber alloc] initWithBool: success];
	NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys: successNumber, @"PTIPodAddSuccess", nil];
	[successNumber release];
	return result;
}

@end

