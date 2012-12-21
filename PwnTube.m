/*
 * PwnTube.m
 * PwnTube
 *
 * Created by Arpad Goretity on 12/12/2012
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "PTDelegate.h"

#define PTIVAR(o, n, t) (*(t *)getIvarPtr(o, n))

static void *getIvarPtr(id obj, const char *name)
{
	return (char *)obj + ivar_getOffset(class_getInstanceVariable([obj class], name));
}

static void PTDownloadButtonClick(id self, SEL _cmd, PTDownloadButton *sender)
{
	YTVideo *video = PTIVAR(self, "_video", YTVideo *);	
	[[PTDelegate sharedInstance] downloadVideo:video button:sender];
}

static IMP _orig_1, _orig_2;

id _mod_1(id self, SEL _cmd, CGRect frm)
{
	self = _orig_1(self, _cmd, frm);
	
	PTDownloadButton *b1 = [[PTDownloadButton alloc] initWithFrame:CGRectMake(20, 8, 100, 29)];
	b1.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	b1.progress = 0.0f;
	[b1 setTitle:@"Download" forState:UIControlStateNormal];
	[b1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[b1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
	[b1 addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:b1];
	[b1 release];
		
	return self;
}

void _mod_2(id self, SEL _cmd)
{
	_orig_2(self, _cmd);
		
	UIButton *addBtn = PTIVAR(self, "_addBookmarkButton", UIButton *);
	UIButton *shareBtn = PTIVAR(self, "_shareButton", UIButton *);
	UIButton *likeBtn = PTIVAR(self, "_likeButton", UIButton *);
	UIButton *dislkBtn = PTIVAR(self, "_dislikeButton", UIButton *);
	UIButton *flagBtn = PTIVAR(self, "_flagButton", UIButton *);
	
	CGRect f;
	
	f = addBtn.frame;
	f.origin.x += 80.0;
	addBtn.frame = f;
	
	f = shareBtn.frame;
	f.origin.x += 70.0;
	shareBtn.frame = f;

	f = likeBtn.frame;
	f.origin.x += 60.0;
	likeBtn.frame = f;

	f = dislkBtn.frame;
	f.origin.x += 50.0;
	dislkBtn.frame = f;

	f = flagBtn.frame;
	f.origin.x += 40.0;
	flagBtn.frame = f;
}

__attribute__((constructor))
void init()
{
	MSHookMessageEx(
		objc_getClass("YTMovieHUDView"),
		@selector(initWithFrame:),
		(IMP)_mod_1,
		&_orig_1
	);

	MSHookMessageEx(
		objc_getClass("YTMovieHUDView"),
		@selector(layoutSubviews),
		(IMP)_mod_2,
		&_orig_2
	);
	
	class_addMethod(
		objc_getClass("YTMovieHUDView"),
		@selector(downloadButtonClicked:),
		(IMP)PTDownloadButtonClick,
		"v@:@"
	);
}
