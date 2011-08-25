//
// PTTagViewController.m
// PwnTube
//
// Created by Árpád Goretity, 2011.
// Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License
//

#import "PTTagViewController.h"

#define CELL_ID @"PTMetaCell"

@implementation PTTagViewController

// the designated initializer
- (id) initWithPath: (NSString *) path video: (YTVideo *) aVideo {
	self = [super init];
	video = [aVideo retain];
	self.navigationItem.title = @"Add to iPod";
	self.tableView.allowsSelection = NO;
	file = [path copy];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(done)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(close)];
	self.navigationItem.leftBarButtonItem = closeButton;
	[closeButton release];
	// set up the UI
	labels = [[NSArray alloc] initWithObjects: @"Title", @"Album", @"Artist", @"Genre", @"Year", @"Composer", @"Comment", @"Rating", @"Category", nil];
	textFields = [[NSMutableArray alloc] init];
	for (int i = 0; i < 9; i++) {
		UITextField *tf = [[UITextField alloc] initWithFrame: CGRectMake (0, 9, 160, 30)];
		tf.delegate = self;
		[textFields addObject: tf];
		[tf release];
	}
	// no nil values are permitted!
	[[textFields objectAtIndex: 0] setText: video.title ? video.title : @"Untitled"];
	[[textFields objectAtIndex: 1] setText: @"PwnTube"];
	[[textFields objectAtIndex: 2] setText: [[UIDevice currentDevice] name]];
	[[textFields objectAtIndex: 3] setText: @"Video"];
	[[textFields objectAtIndex: 4] setText: @"Specify year"];
	[[textFields objectAtIndex: 5] setText: @"Specify composer"];
	[[textFields objectAtIndex: 6] setText: @"Added using PwnTube by H2CO3"];
	[[textFields objectAtIndex: 7] setText: @"Specfy rating"];
	[[textFields objectAtIndex: 8] setText: video.category ? video.category : @"Unknown category"];
	return self;
}

// super
- (void) dealloc {
	[labels release];
	[textFields release];
	[file release];
	[super dealloc];
}

// UITableViewDelegate
- (int) tableView: (UITableView *) tv numberOfRowsInSection: (int) section {
	return 9;
}

- (UITableViewCell *) tableView: (UITableView *) tv cellForRowAtIndexPath: (NSIndexPath *) ip {
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier: CELL_ID];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CELL_ID] autorelease];
	}
	cell.textLabel.text = [labels objectAtIndex: ip.row];
	cell.accessoryView = [textFields objectAtIndex: ip.row];
	return cell;
}

// UITextFieldDelegate
- (BOOL) textFieldShouldReturn: (UITextField *) textField {
	[textField resignFirstResponder];
	return YES;
}

// self
- (void) presentFromViewController: (UIViewController *) vctrl {
	parent = [vctrl retain];
	UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController: self];
	[parent presentModalViewController: navCtrl animated: YES];
	[navCtrl release];
}

- (void) done {
	// set up dictionary to send through CPDistributedMessagingCenter
	NSMutableDictionary *trackInfo = [[NSMutableDictionary alloc] init]; // all values are to be treated as strings except when specified
	[trackInfo setObject: file forKey: @"PTTrackFileName"];
	[trackInfo setObject: [[textFields objectAtIndex: 0] text] forKey: @"PTTrackTitle"];
	[trackInfo setObject: [[textFields objectAtIndex: 1] text] forKey: @"PTTrackAlbum"];
	[trackInfo setObject: [[textFields objectAtIndex: 2] text] forKey: @"PTTrackArtist"];
	[trackInfo setObject: [[textFields objectAtIndex: 3] text] forKey: @"PTTrackGenre"];
	[trackInfo setObject: [[textFields objectAtIndex: 4] text] forKey: @"PTTrackYear"];
	[trackInfo setObject: [[textFields objectAtIndex: 5] text] forKey: @"PTTrackComposer"];
	[trackInfo setObject: [[textFields objectAtIndex: 6] text] forKey: @"PTTrackComment"];
	[trackInfo setObject: [[textFields objectAtIndex: 7] text] forKey: @"PTTrackRating"]; // int between 0...100; 20 = *, 100 = *****
	[trackInfo setObject: [[textFields objectAtIndex: 8] text] forKey: @"PTTrackCategory"];
	[trackInfo setObject: @"32" forKey: @"PTTrackMediatype"]; // int bitmask, 32 = music video
	/*
	// this has to be implemented through a daemon/service/whatever,
	// as sandboxd denies any read/write access to ~/Media within YouTube.app
	[[MFMusicLibrary sharedLibrary] addFile: file asTrack: track];
	BOOL success = [[MFMusicLibrary sharedLibrary] write];
	*/
	// send message and receive response (succeeded or not)
	CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed: @"org.h2co3.pwntube"];
	NSDictionary *response = [center sendMessageAndReceiveReplyName: @"org.h2co3.pwntube.ipodimport" userInfo: trackInfo];
	BOOL success = [(NSNumber *)[response objectForKey: @"PTIPodAddSuccess"] boolValue];
	if (success) {
		[[[[UIAlertView alloc] initWithTitle: @"Media added" message: [NSString stringWithFormat: @"The item '%@' was added to the iPod.", [trackInfo objectForKey: @"PTTrackTitle"]] delegate: nil cancelButtonTitle: @"Dismiss" otherButtonTitles: nil] autorelease] show];
	} else {
		[[[[UIAlertView alloc] initWithTitle: @"Error" message: [NSString stringWithFormat: @"The item '%@' could not be added to the iPod.", [trackInfo objectForKey: @"PTTrackTitle"]] delegate: nil cancelButtonTitle: @"Dismiss" otherButtonTitles: nil] autorelease] show];
	}
	[trackInfo release];
	[self close];
	
}

- (void) close {
	[parent dismissModalViewControllerAnimated: YES];
	[parent release];
}

@end

