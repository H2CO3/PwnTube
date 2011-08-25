//
// PTTagViewController.h
// PwnTube
//
// Created by Árpád Goretity, 2011.
// Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <YouTube/YouTube.h>

@interface PTTagViewController: UITableViewController <UITextFieldDelegate> {
	NSMutableArray *textFields;
	NSArray *labels;
	NSString *file;
	YTVideo *video;
	UIViewController *parent;
}

- (id) initWithPath: (NSString *) path video: (YTVideo *) aVideo;
- (void) presentFromViewController: (UIViewController *) vc;
- (void) close;

@end
