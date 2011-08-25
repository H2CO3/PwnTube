//
// PTDaemonDelegate.h
// PwnTube
//
// Created by Árpád Goretity, 2011.
// Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <MFMusicLibrary/MFMusicLibrary.h>

@interface PTDaemonDelegate: NSObject {
	CPDistributedMessagingCenter *center;
}

+ (id) sharedInstance;
- (NSDictionary *) handleMessageNamed: (NSString *) name withUserInfo: (NSDictionary *) userInfo;

@end

