/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/YouTube.framework/YouTube
 */

#import <Foundation/Foundation.h>
#import "YTVideoDataSource.h"

@interface YTHistoryVideoDataSource : YTVideoDataSource {
	NSMutableArray *_history;
}
- (id)_history;
- (void)_saveToDefaults;
- (void)addVideo:(id)video;
- (void)clearHistory;
- (void)loadFromDefaults;
- (unsigned)maxVideosToSave;
- (void)reloadData;
@end
