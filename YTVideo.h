/*
 * This file is originally taken from
 * https://github.com/masbog/PrivateFrameworkHeader-iOS-iPhone-5.-/blob/master/YouTube.framework/YTVideo.h
 *
 * Created by Arpad Goretity on 22/12/2012.
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface YTVideo: NSObject {
	NSString *_id;
	NSString *_title;
	NSString *_author;
	id _dateUpdated;
	id _dateAdded;
	NSArray *_videoReferences;
	NSString *_notificationName;
	NSString *_videoDescription;
	NSString *_category;
	NSArray *_tags;
	unsigned int _numberOfViews;
	unsigned int _numLikes;
	unsigned int _numDislikes;
	int _batchStatus;
	NSURL *_infoURL;
	NSURL *_thumbnailURL;
	NSURL *_commentsURL;
	NSURL *_editURL;
	NSURL *_ratingsURL;
	NSURL *_captionsURL;
	NSString *_shortID;
	NSString *_unplayable;
	BOOL _isProcessing;
	NSMutableArray *_captions;
	int _privacy;
	id _thumbnailProxyBlock;
}

+ (void)reset3GPlaybackStallCount;
+ (void)playbackDidStall;
+ (NSError *)videoNotFoundError;
+ (NSError *)unsupportedVideoError;
+ (NSError *)videoIsProcessingError;
+ (void)disableNotifications;
+ (void)enableNotifications;

- (NSDate *)dateAdded;
- (NSDate *)dateUpdated;
- (NSString *)dateAddedString;
- (NSURL *)commentsURL;
- (NSURL *)ratingsURL;
- (NSURL *)captionsURL;
- (NSString *)videoDescription;
- (NSArray *)tags;
- (NSString *)tagsString;
- (NSUInteger)numLikes;
- (NSUInteger)numDislikes;
- (BOOL)positiveRating;
- (NSString *)ratingPercentageString;
- (NSUInteger)numberOfViews;
- (NSInteger)batchStatus;
- (CGImageRef)roundedThumbnailLoadIfAbsent:(BOOL)arg1;
- (CGImageRef)largeThumbnailLoadIfAbsent:(BOOL)arg1;
- (CGImageRef)pluginThumbnailLoadIfAbsent:(BOOL)arg1;
- (void)loadThumbnailWithCallback:(id)arg1;
- (id)anyVideoReference;
- (NSString *)privacyString;
- (BOOL)ownVideo;
- (id)initFromArchiveDictionary:(id)arg1;
- (id)initWithID:(id)arg1 title:(id)arg2 dateUpdated:(id)arg3 dateAdded:(id)arg4 videoReferences:(id)arg5 infoURL:(id)arg6 videoDescription:(id)arg7 category:(id)arg8 tags:(id)arg9 author:(id)arg10 thumbnailURL:(id)arg11 numLikes:(unsigned int)arg12 numDislikes:(unsigned int)arg13 numberOfViews:(unsigned int)arg14 batchStatus:(int)arg15 commentsURL:(id)arg16 editURL:(id)arg17 ratingsURL:(id)arg18 captionsURL:(id)arg19 shortID:(id)arg20 unplayable:(id)arg21 isProcessing:(BOOL)arg22 privacy:(int)arg23;
- (NSDictionary *)archiveDictionary;
- (CGImageRef)thumbnailLoadIfAbsent:(BOOL)arg1;
- (void)_postVideoDidChange;
- (void)carrierBundleDidChangeNotification:(id)arg1;
- (void)_thumbnailDidLoad;
- (id)videoReferenceForProfile:(int)arg1;
- (BOOL)allowsHighQuality3GPlayback;
- (NSArray *)captions;
- (id)bestVideoReference;
- (NSString *)shortID;
- (BOOL)isBookmarked;
- (id)unplayable;
- (BOOL)isProcessing;
- (NSURL *)editURL;
- (NSString *)author;
- (double)age;
- (NSString *)title;
- (NSString *)ID;
- (BOOL)isPlayable;
- (NSString *)category;
- (NSURL *)thumbnailURL;
- (BOOL)isEqual:(id)arg1;
- (unsigned int)hash;
- (NSString *)description;
- (void)dealloc;
- (NSURL *)infoURL;

@end
