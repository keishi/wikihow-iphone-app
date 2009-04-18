// Copyright (c) 2008 Keishi Hattori
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define KCLog(s,...) [KCLogger logFile:__FILE__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#else
#define KCLog(...) 
#endif

#define KCLogOrientation(o) KCLog( \
	o==UIDeviceOrientationUnknown ? @"UIDeviceOrientationUnknown" : \
	o==UIDeviceOrientationPortrait ? @"UIDeviceOrientationPortrait" : \
	o==UIDeviceOrientationPortraitUpsideDown ? @"UIDeviceOrientationPortraitUpsideDown" : \
	o==UIDeviceOrientationLandscapeLeft ? @"UIDeviceOrientationLandscapeLeft" : \
	o==UIDeviceOrientationLandscapeRight ? @"UIDeviceOrientationLandscapeRight" : \
	o==UIDeviceOrientationFaceUp ? @"UIDeviceOrientationFaceUp" : \
	o==UIDeviceOrientationFaceDown ? @"UIDeviceOrientationFaceDown" : @"Unknown")
#define KCLogRect(r) KCLog(@"{{%f,%f},{%f,%f}}", r.origin.x, r.origin.y, r.size.width, r.size.height)
#define KCLogSize(s) KCLog(@"{%f,%f}", s.width, s.height)
#define KCLogPoint(p) KCLog(@"{%f,%f}", p.x, p.y)
#define KCLogInt(i) KCLog(@"%d", i)
#define KCLogFloat(f) KCLog(@"%f", f)
#define KCLogObject(o) KCLog(@"%@", o)

@interface KCLogger : NSObject {

}

+ (void)logFile:(char*)sourceFile lineNumber:(int)lineNumber format:(NSString*)format, ...;

@end
