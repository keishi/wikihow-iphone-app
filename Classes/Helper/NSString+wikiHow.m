// Copyright (c) 2009 wikihow.com and Keishi Hattori
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

#import "NSString+wikiHow.h"
#import "NSString+HTTPClient.h"


@implementation NSString (wikiHow)

- (NSString *)stringEscapedWikiHowStyle {
	NSString *s = [self stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	return [s stringEscapedAsURIComponent];
}

- (NSString *)stringUnescapedWikiHowStyle {
	NSString *s = [self stringUnescapedAsURIComponent];
	return [s stringByReplacingOccurrencesOfString:@"-" withString:@" "];
}

- (NSString *)identifierTitle {
	NSRange r = [self rangeOfString:@":"];
	return [self substringFromIndex:(r.location+1)];
}

- (NSString *)identifierNamespace {
	NSRange r = [self rangeOfString:@":"];
	return [self substringToIndex:r.location];
}

- (NSString *)normalizedJSONString {
	NSRange startRange = [self rangeOfString:@"{"];
	NSRange endRange = [self rangeOfString:@"}" options:(NSLiteralSearch | NSBackwardsSearch)];
	NSRange JSONRange;
	JSONRange.location = startRange.location;
	JSONRange.length = endRange.location - startRange.location + 1;
	return [self substringWithRange:JSONRange];
}

@end
