/*
 * PTDelegate.m
 * PwnTube
 *
 * Created by Arpad Goretity on 12/12/2012
 */

#import "PTDelegate.h"

#define PTDownloadDirectory @"/var/mobile/Downloads"
#define PTTemporaryDirectory @"/tmp"
#define PTDownloadButtonKey @"PTDownloadButtonKey"

@implementation PTDelegate

+ (id)sharedInstance
{
	static id shared = nil;
	if (shared == nil) {
		shared = [[self alloc] init];
	}
	
	return shared;
}

- (id)init
{
	if ((self = [super init])) {
		dlVc = [[HCDownloadViewController alloc] init];
		dlVc.downloadDirectory = PTTemporaryDirectory;
		dlVc.delegate = self;
	}
	return self;
}

- (void)dealloc
{
	[dlVc release];
	[super dealloc];
}

// self

- (void)downloadVideo:(YTVideo *)video button:(PTDownloadButton *)btn
{
	CFURLRef url = HCYouTubeCreateURLWithVideoID(video.shortID);

	NSCharacterSet *disallowedSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	NSString *fname = [NSString stringWithFormat:@"%@.mp4", [video.title stringByTrimmingCharactersInSet:disallowedSet]];

	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		fname,		kHCDownloadKeyFileName,
		btn,		PTDownloadButtonKey,
		video,		PTVideoKey,
		nil
	];

	[dlVc downloadURL:(NSURL *)url userInfo:userInfo];
	if (url != NULL) {
		CFRelease(url);
	}
}

// HCDownloadViewControllerDelegate

- (void)downloadController:(HCDownloadViewController *)vc startedDownloadingURL:(NSURL *)url userInfo:(NSDictionary *)userInfo
{
	[[[[UIAlertView alloc]
		initWithTitle:NSLocalizedString(@"Download started", nil)
		message:[(YTVideo *)[userInfo objectForKey:PTVideoKey] title]
		delegate:nil
		cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
		otherButtonTitles:nil]
	autorelease] show];
}

- (void)downloadController:(HCDownloadViewController *)vc dowloadedFromURL:(NSURL *)url progress:(float)progress userInfo:(NSDictionary *)userInfo
{
	PTDownloadButton *btn = [userInfo objectForKey:PTDownloadButtonKey];
	btn.progress = progress;
}

- (void)downloadController:(HCDownloadViewController *)vc finishedDownloadingURL:(NSURL *)url toFile:(NSString *)fileName userInfo:(NSDictionary *)userInfo
{
	// Register video as downloaded
	PTDownloadButton *btn = [userInfo objectForKey:PTDownloadButtonKey];
	[btn setTitle:NSLocalizedString(@"Downloaded", nil) forState:UIControlStateNormal];

	/*	
	 * NSArray *downloadedVideos = [[NSUserDefaults standardUserDefaults] arrayForKey:PTVideoIDKey];
	 * NSString *vid = [userInfo objectForKey:PTVideoIDKey];
	 * downloadedVideos = downloadedVideos != nil ? [downloadedVideos arrayByAddingObject:vid] : [NSArray arrayWithObject:vid];
	 * [[NSUserDefaults standardUserDefaults] setObject:downloadedVideos forKey:PTVideoIDKey];
	 * [[NSUserDefaults standardUserDefaults] synchronize];
	 */

	// Add video to the iPod media library
	YTVideo *video = [userInfo objectForKey:PTVideoKey];
	NSString *path = [dlVc.downloadDirectory stringByAppendingPathComponent:fileName];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
		kIPIMediaMusicVideo,	kIPIKeyMediaType,
		video.title,		kIPIKeyTitle,
		video.author,		kIPIKeyArtist,
		@"PwnTube",		kIPIKeyAlbum,
		nil
	];
	[[IPIPodImporter sharedInstance] importFileAtPath:path withMetadata:info];
	// [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
	
	[[[[UIAlertView alloc]
		initWithTitle:NSLocalizedString(@"Video downloaded", nil)
		message:[(YTVideo *)[userInfo objectForKey:PTVideoKey] title]
		delegate:nil
		cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
		otherButtonTitles:nil]
	autorelease] show];
}
 
- (void)downloadController:(HCDownloadViewController *)vc failedDownloadingURL:(NSURL *)url withError:(NSError *)error userInfo:(NSDictionary *)userInfo
{
	PTDownloadButton *btn = [userInfo objectForKey:PTDownloadButtonKey];
	[btn setTitle:NSLocalizedString(@"Retry", nil) forState:UIControlStateNormal];
	btn.progress = 0.0f;

	[[[[UIAlertView alloc]
		initWithTitle:NSLocalizedString(@"Download failed", nil)
		message:[(YTVideo *)[userInfo objectForKey:PTVideoKey] title]
		delegate:nil
		cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
		otherButtonTitles:nil]
	autorelease] show];
}

@end
