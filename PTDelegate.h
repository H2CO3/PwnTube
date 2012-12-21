/*
 * PTDelegate.h
 * PwnTube
 *
 * Created by Arpad Goretity on 12/12/2012
 */

#import <Foundation/Foundation.h>
#import <ipodimport.h>
#import "YTVideo.h"
#import "HCYouTube.h"
#import "PTDownloadButton.h"
#import "HCDownloadViewController.h"

#define PTVideoKey @"PTVideoIDKey"

@interface PTDelegate: NSObject <HCDownloadViewControllerDelegate> {
	HCDownloadViewController *dlVc;
}

+ (id)sharedInstance;

- (void)downloadVideo:(YTVideo *)video button:(PTDownloadButton *)btn;

@end
