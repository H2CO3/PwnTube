//
// NSString+Searcher.m
// PwnTube
//
// Created by Árpád Goretity, 2011.
//

#import "NSString+Searcher.h"

@implementation NSString (Searcher)
- (NSString *) stringBetweenString: (NSString *) start andString: (NSString *) end {
	NSRange startRange = [self rangeOfString: start];
	if (startRange.location != NSNotFound) {
		NSRange targetRange;
		targetRange.location = startRange.location + startRange.length;
		targetRange.length = [self length] - targetRange.location;   
		NSRange endRange = [self rangeOfString: end options: 0 range: targetRange];
		if (endRange.location != NSNotFound) {
			targetRange.length = endRange.location - targetRange.location;
			return [self substringWithRange: targetRange];
		}
	}
	return nil;
}
@end

