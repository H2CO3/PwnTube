/*
 * PTDownloadButton.m
 * PwnTube
 *
 * Created by Arpad Goretity on 21/12/2012
 */

#import "PTDownloadButton.h"

@implementation PTDownloadButton

- (id)initWithFrame:(CGRect)frm
{
	if ((self = [super initWithFrame:frm])) {
		self.progress = 0.0f;
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor colorWithRed:0.1f green:0.4f blue:1.0f alpha:0.667f] set];
	CGRect r = self.bounds;
	r.size.width *= self.progress;
	CGContextFillRect(ctx, r);
}

- (float)progress
{
	return progress;
}

- (void)setProgress:(float)p
{
	progress = p > 1.0f ? 1.0f : p < 0.0f ? 0.0f : p;
	[self setNeedsDisplay];
}

@end
