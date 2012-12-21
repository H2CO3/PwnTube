/*
 * HCYouTube.m
 * PwnTube
 *
 * Created by Arpad Goretity on 22/11/2012
 * Original work by Filippo Bigarella
 * https://github.com/FilippoBiga/ytextract
 */

#include <assert.h>
#include <Foundation/Foundation.h>
#include <curl/curl.h>
#include "HCYouTube.h"

#define HCYouTubeUserAgent "Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
#define HCYouTubeJSONStartMark @"\")]}'"
#define HCYouTubeJSONEndMark @"\");"

static NSString *HCYouTubeUnescapeUnicodeString(NSString *str);

typedef struct HCYouTubeCurlContext {
	size_t pos;
	char *data;
} HCYouTubeCurlContext;

static size_t HCYouTubeCurlCallback(void *buf, size_t n, size_t blksz, void *data)
{
	size_t sz = n * blksz;
	
	HCYouTubeCurlContext *ctx = data;
	ctx->data = realloc(ctx->data, ctx->pos + sz);
	assert(ctx->data != NULL);
	memcpy(ctx->data + ctx->pos, buf, sz);
	ctx->pos += sz;
	
	return sz;
}

CFURLRef HCYouTubeCreateURLWithVideoID(CFStringRef vid)
{
	NSString *html;
	
	NSUInteger startLoc;
	NSUInteger endLoc;
	NSRange jsonRange;

	NSString *jsonString;
	NSDictionary *parsedJSON;
	NSArray *streamMap;
	
	CFStringRef videoURLString;
	
	/*
	 * This is a hack.
	 * Damn sandboxing.
	 */
	HCYouTubeCurlContext ctx;
	ctx.pos = 0;
	ctx.data = NULL;
	
	CURL *hndl = curl_easy_init();
	const char *url = [[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@", vid] UTF8String];
	curl_easy_setopt(hndl, CURLOPT_URL, url);
	curl_easy_setopt(hndl, CURLOPT_USERAGENT, HCYouTubeUserAgent);
	curl_easy_setopt(hndl, CURLOPT_WRITEFUNCTION, HCYouTubeCurlCallback);
	curl_easy_setopt(hndl, CURLOPT_WRITEDATA, &ctx);
	
	curl_easy_perform(hndl);
	curl_easy_cleanup(hndl);

	html = [[NSString alloc] initWithBytes:ctx.data length:ctx.pos encoding:NSUTF8StringEncoding];
	free(ctx.data);
	
	startLoc = [html rangeOfString:HCYouTubeJSONStartMark].location;
	endLoc = [html rangeOfString:HCYouTubeJSONEndMark].location;
	if (startLoc == NSNotFound || endLoc == NSNotFound) {
		return nil;
	}
	
	startLoc += [HCYouTubeJSONStartMark length];
	jsonRange = NSMakeRange(startLoc, endLoc - startLoc);
	jsonString = HCYouTubeUnescapeUnicodeString([html substringWithRange:jsonRange]);
	
	[html release];
	if (jsonString == nil) {
		return nil;
	}
	
	Class _NSJSONSerialization = objc_getClass("NSJSONSerialization");
	parsedJSON = [_NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
	if (parsedJSON == nil) {
		return nil;
	}

	streamMap = [[[parsedJSON objectForKey:@"content"] objectForKey:@"video"] objectForKey:@"fmt_stream_map"];
	videoURLString = (CFStringRef)[[streamMap objectAtIndex:0] objectForKey:@"url"];
	
	return CFURLCreateWithString(NULL, videoURLString, NULL);
}

static NSString *HCYouTubeUnescapeUnicodeString(NSString *str)
{
	NSMutableString *escaped = [str mutableCopy];
	[escaped replaceOccurrencesOfString:@"\\u" withString:@"\\U" options:0 range:NSMakeRange(0, escaped.length)];
	[escaped replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, escaped.length)];
	[escaped replaceOccurrencesOfString:@"\\\\\"" withString:@"\\\"" options:0 range:NSMakeRange(0, escaped.length)];
	[escaped insertString:@"\"" atIndex:0];
	[escaped appendString:@"\""];
	NSMutableString *unescaped = [NSPropertyListSerialization propertyListWithData:[escaped dataUsingEncoding:NSUTF8StringEncoding]
		options:NSPropertyListMutableContainersAndLeaves
		format:NULL
		error:NULL
	];
	[escaped release];
	
	if ([unescaped isKindOfClass:[NSString class]] == NO) {
		return nil;
	}
		
	[unescaped replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, unescaped.length)];
	return unescaped;
}
