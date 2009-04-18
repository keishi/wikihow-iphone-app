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

#import "KCNetworkActivityIndicator.h"

static KCNetworkActivityIndicator *sharedIndicator = nil;

@implementation KCNetworkActivityIndicator

@synthesize count;

+ (KCNetworkActivityIndicator *)sharedIndicator {
	if (sharedIndicator == nil) {
		sharedIndicator = [[KCNetworkActivityIndicator alloc] init];
	}
	return sharedIndicator;
}

- (id)init {
	if (self = [super init]) {
		count = 0;
	}
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax; 
}

- (void)release {
}

- (id)autorelease {
	return self;
}

- (void)start {
	if (count == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	count++;
}

- (void)stop {
#ifdef DEBUG
	NSAssert(count != 0, @"KCNetworkActivityIndicator: Incorrect indicator count.");
#endif
	count--;
	if (count == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

@end
