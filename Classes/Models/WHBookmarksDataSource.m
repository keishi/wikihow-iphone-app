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

#import "WHBookmarksDataSource.h"
#import "WHBookmark.h"

static WHBookmarksDataSource *sharedDataSource = nil;

@implementation WHBookmarksDataSource

@synthesize bookmarks;
@synthesize lastModified;

+ (WHBookmarksDataSource *)sharedDataSource {
	if (sharedDataSource == nil) {
		sharedDataSource = [[WHBookmarksDataSource alloc] init];
	}
	return sharedDataSource;
}

- (id)init {
	if (self = [super init]) {
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		NSData *bookmarksData = [standardUserDefaults objectForKey:@"bookmarks"];
		lastModified = [[NSDate alloc] init];
		lastSaved = [[NSDate alloc] init];
		if (bookmarksData) {
			bookmarks = [[NSKeyedUnarchiver unarchiveObjectWithData:bookmarksData] retain];
		} else {
			bookmarks = [[NSMutableArray alloc] init];
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveIfNeeded) name:UIApplicationWillTerminateNotification object:nil];
		[NSTimer scheduledTimerWithTimeInterval:(5 * 60) target:self selector:@selector(saveIfNeeded) userInfo:nil repeats:YES];
	}
	return self;
}

- (void)saveIfNeeded {
	if ([lastSaved compare:lastModified] == NSOrderedAscending) {
		[self save];
	}
}

- (void)save {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:bookmarks] forKey:@"bookmarks"];
	[lastSaved release];
	lastSaved = [[NSDate alloc] init];
}

- (void)bookmarkArticle:(WHArticle *)article {
	if ([self isBookmarked:article.identifier]) {
		return;
	}
	WHBookmark *bookmark = [[WHBookmark alloc] init];
	bookmark.title = article.title;
	bookmark.identifier = article.identifier;
	[bookmarks addObject:bookmark];
	[bookmark release];
	[self updateLastModified];
}

- (BOOL)isBookmarked:(NSString *)identifier {
	WHBookmark *bookmark;
	for (bookmark in bookmarks) {
		if ([bookmark.identifier isEqualToString:identifier]) {
			return YES;
		}
	}
	return NO;
}

- (void)updateLastModified {
	[lastModified release];
	lastModified = [[NSDate alloc] init];
}


@end
