/*
 * PTDownloadButton.h
 * PwnTube
 *
 * Created by Arpad Goretity on 21/12/2012
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface PTDownloadButton: UIButton {
	float progress;
}

@property (assign) float progress;

@end
