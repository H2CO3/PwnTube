//
// PTDelegate.m
// PwnTube
//
// Created by Árpád Goretity, 2011.
// Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License
//

#import "PTDelegate.h"

static id _sharedInstance = nil;

@implementation PTDelegate

// class methods

+ (id) sharedInstance {
	if (_sharedInstance == nil) {
		_sharedInstance = [[self alloc] init];
	}
	return _sharedInstance;
}

// self

- (id) init {
	self = [super init];
	donateURL = [[NSURL alloc] initWithString: @"http://h2co3.zxq.net/"];
	cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: @"PTDownloadCell"];
	// the single(ton) UIViewController object in the YouTube application
	ytController = [objc_getClass("YTController") sharedController];
	fileName = nil;
	fileData = nil;
	downloadedVideo = nil;
	// let's assume there'll be kind and generous people who will donate
	alertView = [[UIAlertView alloc] init];
	alertView.title = @"Please donate";
	alertView.message = @"Lots of hard work went into PwnTube. If you liked this tweak, I kindy ask you to donate. I need this to be able to continue development with more recent iDevices. Thank you!";
	alertView.delegate = self;
	[alertView addButtonWithTitle: @"Donate"];
	[alertView addButtonWithTitle: @"Later"];
	// Let the user chose from iPod import and video playback
	sheet = [[UIActionSheet alloc] init];
	sheet.title = @"Video operations";
	sheet.cancelButtonIndex = 2;
	sheet.destructiveButtonIndex = 0;
	sheet.delegate = self;
	[sheet addButtonWithTitle: @"Add to iPod"];
	[sheet addButtonWithTitle: @"Play"];
	[sheet addButtonWithTitle: @"Cancel"];
	progressBar = [[UIProgressView alloc] initWithFrame: CGRectMake(0, 30, 130, 15)];
	cell.accessoryView = progressBar;
	return self;
}

// if it's the first time this version runs on the device, ask for support
- (void) showDonateAlertIfNeeded {
	if ([[NSUserDefaults standardUserDefaults] boolForKey: @"PTDonateShown02"] != YES) {
		[alertView show];
		[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"PTDonateShown02"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey: @"PTDownloadedVideos"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey: @"PTVideoFiles"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

// every video to be downloaded should be started once
// to have its URL cached. This cached value will be used by PwnTube
// to download the video to the filesystem (rather than streaming it).
- (void) showDidNotWatchErrorAlert {
	UIAlertView *av = [[UIAlertView alloc] init];
	av.title = @"Error";
	av.message = @"You have to start playing the video once before it can be downloaded.";
	[av addButtonWithTitle: @"Dismiss"];
	[av show];
	[av release];
}

// maybe should say showAddToIPod instead?
- (void) showTagViewController {
	PTTagViewController *tvc = [[PTTagViewController alloc] initWithPath: [@"/var/mobile/Media/PwnTube" stringByAppendingPathComponent: fileName] video: downloadedVideo];
	[tvc presentFromViewController: [self youTubeController]];
	[tvc release];
}

- (void) showVideoActions {
	[sheet showInView: [[self youTubeController] view]];
}

// download a selected YouTube video
- (void) downloadVideo: (YTVideo *) video {
	downloadedVideo = [video retain];
	// get video metadata about various formats
	NSString *getInfoUrlString = [[NSString alloc] initWithFormat: @"http://youtube.com/get_video_info?video_id=%@", downloadedVideo.shortID];
	NSURL *getInfoUrl = [[NSURL alloc] initWithString: getInfoUrlString];
	[getInfoUrlString release];
	NSMutableString *videoInfo = [[[NSString stringWithContentsOfURL: getInfoUrl] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	[getInfoUrl release];
	[videoInfo replaceOccurrencesOfString: @"%26" withString: @"&" options: NSCaseInsensitiveSearch range: NSMakeRange(0, [videoInfo length])];
	[videoInfo replaceOccurrencesOfString: @"%3D" withString: @"=" options: NSCaseInsensitiveSearch range: NSMakeRange(0, [videoInfo length])];
	[videoInfo replaceOccurrencesOfString: @"%25" withString: @"%" options: NSCaseInsensitiveSearch range: NSMakeRange(0, [videoInfo length])];
	// find the identifier of the cached video depending on its player ID
	NSString *cacheID = [videoInfo stringBetweenString: @"&id=" andString: @"&"];
	[videoInfo release];
	NSDictionary *cacheDictionary = [[NSDictionary alloc] initWithContentsOfFile: @"/tmp/MediaCache/diskcacherepository.plist"];
	NSArray *ytUrlStrings = [(NSDictionary *)[cacheDictionary objectForKey: @"checkedinlist"] allKeys];
	NSString *urlString = nil;
	// go through all cached videos' URL, search for this particular one
	for (int i = 0; i < [ytUrlStrings count]; i++) {
		NSRange range = [[ytUrlStrings objectAtIndex: i] rangeOfString: cacheID];
		if (range.location != NSNotFound) {
			urlString = [[ytUrlStrings objectAtIndex: i] copy];
			break;
		}
	}
	[cacheDictionary release];
	if (urlString == nil) {
		// if not found, the user has not yet started playing this video. Ask him/her to do so.
		[self showDidNotWatchErrorAlert];
		return;
	}
	// video found, let's download it
	NSURL *url = [[NSURL alloc] initWithString: urlString];
	[urlString release];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	[url release];
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: NO] autorelease];
	[request release];
	[connection start];
}

- (void) registerVideoAsDownloaded: (YTVideo *) video {
	// if a video has been downloaded, store it in user defaults so that the tweak
	// will be able to 'intelligently' present an option to the user to add to iPod
	NSMutableDictionary *downloadedVideos = [[[NSUserDefaults standardUserDefaults] objectForKey: @"PTDownloadedVideos"] mutableCopy];
	if (downloadedVideos == nil) {
		downloadedVideos = [[NSMutableDictionary alloc] init];
	}
	if ([downloadedVideos objectForKey: video.shortID] == nil) {
		[downloadedVideos setObject: fileName forKey: video.shortID];
	}
	[[NSUserDefaults standardUserDefaults] setObject: downloadedVideos forKey: @"PTDownloadedVideos"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[downloadedVideos release];
}

- (UITableViewCell *) customCellForVideo: (YTVideo *) aVideo {
	downloadedVideo = [aVideo retain];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey: @"PTDownloadedVideos"] objectForKey: downloadedVideo.shortID] != nil) {
		// already downloaded video
		cell.textLabel.text = @"Video downloaded";
		cell.detailTextLabel.text = @"Now tap the arrow for more actions";
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	} else {
		// not yet downloaded video
		cell.textLabel.text = @"Download";
		cell.detailTextLabel.text = @"First you have to start playing it once";
		cell.accessoryType = UITableViewCellAccessoryNone;
		progressBar.progress = 0.0;
		cell.accessoryView = progressBar;
	}
	return cell;
}

- (UIViewController *) youTubeController {
	return ytController;
}

// super

- (void) dealloc {
	[donateURL release];
	[alertView release];
	[sheet release];
	[cell release];
	[fileName release];
	[super dealloc];
}

// NSURLConnectionDelegate

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response {
	// find out some file metadata (length, filename etc.)
	fileData = [[NSMutableData alloc] init];
	cell.textLabel.text = @"Downloading";
	cell.detailTextLabel.text = @"0 % completed";
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryView = progressBar;
	dataLength = [response expectedContentLength];
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {
	// append downloaded chunk to the base data
	// and update user feedback progress indicators
	[fileData appendData: data];
	NSString *progress = [[NSString alloc] initWithFormat: @"%.0f %% completed", (float)[fileData length] / dataLength * 100.0];
	cell.detailTextLabel.text = progress;
	progressBar.progress = (float)[fileData length] / dataLength;
	[progress release];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection {
	// download finished
	// write out file and then
	// alert user
	cell.textLabel.text = @"Video downloaded";
	cell.detailTextLabel.text = @"Now tap the arrow for more actions";
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	NSCharacterSet *toBeEscapedSet = [NSCharacterSet characterSetWithCharactersInString: @" .,:;?!+-*/%'\"\\/§()[]{}<>~^$#&@"];
	NSString *normalizedTitle = [[downloadedVideo.title componentsSeparatedByCharactersInSet: toBeEscapedSet] componentsJoinedByString:@"_"];
	[fileName release];
	fileName = [[NSString alloc] initWithFormat: @"%@.mp4", normalizedTitle];
	[fileData writeToFile: [@"/tmp/" stringByAppendingPathComponent: fileName] atomically: YES];
	[fileData release];
	[SandCastle moveTemporaryFile: [@"/tmp" stringByAppendingPathComponent: fileName] toResolvedPath: [@"/var/mobile/Media/PwnTube" stringByAppendingPathComponent: fileName]];
	[self registerVideoAsDownloaded: downloadedVideo];
	UIAlertView *av = [[UIAlertView alloc] init];
	av.title = @"Success";
	av.message = [NSString stringWithFormat: @"Saved video to /var/mobile/Media/PwnTube/%@", fileName];
	[av addButtonWithTitle: @"Dismiss"];
	[av show];
	[av release];
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
	UIAlertView *av = [[UIAlertView alloc] init];
	av.title = @"Error";
	av.message = [error description];
	[av addButtonWithTitle: @"Dismiss"];
	[av show];
	[av release];
}

// UIAlertViewDelegate

- (void) alertView: (UIAlertView *) av didDismissWithButtonIndex: (int) index {
	if (index == 0) {
		// Donate
		[[UIApplication sharedApplication] openURL: donateURL];
	}
}

// UIActionSheetDelegate

- (void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex: (int) index {
	if (index == 0) {
		// add to iPod
		[self showTagViewController];
	} else if (index == 1) {
		// play video
		NSDictionary *videoIDs = [[NSUserDefaults standardUserDefaults] objectForKey: @"PTDownloadedVideos"];
		NSString *file = [videoIDs objectForKey: downloadedVideo.shortID];
		if (file == nil) {
			// error, no such video
			[[[[UIAlertView alloc] initWithTitle: @"Error" message: [NSString stringWithFormat: @"The video '%@' is not yet downloaded", downloadedVideo.title] delegate: nil cancelButtonTitle: @"Dismiss" otherButtonTitles: nil] autorelease] show];
		} else {
			// video found, let's play it
			NSString *path = [@"/var/mobile/Media/PwnTube" stringByAppendingPathComponent: file];
			NSURL *fileUrl = [NSURL fileURLWithPath: path];
			MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL: fileUrl];
			[[self youTubeController] presentMoviePlayerViewControllerAnimated: player];
		}
	} else {
		// cancel
		return;
	}
}

@end

