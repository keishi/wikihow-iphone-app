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

#import "WHArticle.h"
#import "WHArticleCache.h"
#import "NSString+wikiHow.h"
#import "WHArticlePreloadedCache.h"


@implementation WHArticle

@synthesize title;
@synthesize category;
@synthesize isCached;

+ (NSString *)titleWithIdentifier:(NSString *)anIdentifier {
	return [[anIdentifier identifierTitle] stringUnescapedWikiHowStyle];
}

- (id)init {
	if (self = [super init]) {
		identifier = nil;
		title = nil;
		HTML = nil;
		category = nil;
		isCached = NO;
	}
	return self;
}

- (void)dealloc {
	[identifier release];
	[title release];
	[HTML release];
	[category release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	[HTML release];
	HTML = nil;
}

#pragma mark Setter/Getter Methods

- (void)setIdentifier:(NSString *)newIdentifier {
	if (![[newIdentifier identifierNamespace] isEqualToString:@"Article"]) {
		NSException *exception = [NSException exceptionWithName:@"WHInvalidIdentifier" reason:@"Identifier doesn't have proper namespace:Article" userInfo:nil];
		@throw exception;
		return;
	}
	
    if (identifier != newIdentifier) {
        [identifier release];
        identifier = [newIdentifier copy];
    }
}

- (NSString *)identifier {
	return identifier;
}

- (void)setHTML:(NSString *)newHTML {
    if (HTML != newHTML) {
        [HTML release];
        HTML = [newHTML copy];
    }
}

- (NSString *)HTML {
	if (HTML == nil && isCached) {
		[[WHArticleCache sharedCache] hydrateArticle:self];
		if (HTML == nil) {
			[[WHArticlePreloadedCache sharedPreloadedCache] hydrateArticle:self];
		}
	}
	return HTML;
}

@end
