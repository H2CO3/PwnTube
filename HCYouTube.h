/*
 * HCYouTube.h
 * PwnTube
 *
 * Created by Arpad Goretity on 22/11/2012
 * Original work by Filippo Bigarella
 * https://github.com/FilippoBiga/ytextract
 */

#ifndef HCYOUTUBE_H
#define HCYOUTUBE_H

#include <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

CFURLRef HCYouTubeCreateURLWithVideoID(CFStringRef vid);

#ifdef __cplusplus
}
#endif

#endif
