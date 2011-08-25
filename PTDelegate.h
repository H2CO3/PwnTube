//
// PTDelegate.h
// PwnTube
//
// Created by Árpád Goretity, 2011.
// Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <YouTube/YouTube.h>
#import <SandCastle.h>
#import "NSString+Searcher.h"
#import "PTTagViewController.h"

#define UILog(x) [[[[UIAlertView alloc] initWithTitle: @"Log" message: x delegate: nil cancelButtonTitle: @"Dismiss" otherButtonTitles: nil] autorelease] show]

@class MPMoviePlayerViewController;

@interface PTDelegate: NSObject <UIAlertViewDelegate, UIActionSheetDelegate> {
	unsigned dataLength;
	NSURL *donateURL;
	NSString *fileName;
	NSMutableData *fileData;
	YTVideo *downloadedVideo;
	UITableViewCell *cell;
	UIAlertView *alertView;
	UIViewController *ytController;
	UIActionSheet *sheet;
	UIProgressView *progressBar;
}

+ (id) sharedInstance;
- (void) showDonateAlertIfNeeded;
- (void) showDidNotWatchErrorAlert;
- (void) showTagViewController;
- (void) showVideoActions;
- (void) downloadVideo: (YTVideo *) video;
- (void) registerVideoAsDownloaded: (YTVideo *) video;
- (UIViewController *) youTubeController;
- (UITableViewCell *) customCellForVideo: (YTVideo *) aVideo;;

@end
