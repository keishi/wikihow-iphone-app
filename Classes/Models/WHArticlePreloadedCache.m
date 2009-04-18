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

#import "WHArticlePreloadedCache.h"

#define WHArticlePreloadedCacheDatabaseName @"preloaded.db"

static WHArticlePreloadedCache *sharedPreloadedCache = nil;

@implementation WHArticlePreloadedCache

+ (WHArticlePreloadedCache *)sharedPreloadedCache {
	if (sharedPreloadedCache == nil) {
		sharedPreloadedCache = [[WHArticlePreloadedCache alloc] init];
	}
	return sharedPreloadedCache;
}

- (void)finalizeStatements {
    if (load_statement) sqlite3_finalize(load_statement);
	if (search_statement) sqlite3_finalize(search_statement);
	if (category_search_statement) sqlite3_finalize(category_search_statement);
	if (hydrate_statement) sqlite3_finalize(hydrate_statement);
	if (listup_statement) sqlite3_finalize(listup_statement);
}

- (id)init {
	if (self = [super init]) {
		load_statement = nil;
		search_statement = nil;
		category_search_statement = nil;
		hydrate_statement = nil;
		
		[self initializeDatabase];
	}
	return self;
}

- (void)cleanup {
	// Finalizing somehow causes error on the next launch
	//[self finalizeStatements];
	//if (sqlite3_close(database) != SQLITE_OK) {
    //    NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    //}
}

- (void)initializeDatabase {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:WHArticlePreloadedCacheDatabaseName];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (WHArticle *)cachedArticleWithIdentifier:(NSString *)identifier {
	if (load_statement == nil) {
		const char *sql = "SELECT title, html, category FROM articles WHERE identifier=? LIMIT 1";
		if (sqlite3_prepare_v2(database, sql, -1, &load_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_text(load_statement, 1, [identifier UTF8String], -1, SQLITE_TRANSIENT);
	WHArticle *article;
	int success = sqlite3_step(load_statement);
	if (success == SQLITE_ROW) {
		article = [[[WHArticle alloc] init] autorelease];
		article.identifier = identifier;
		char *titleCString = (char *)sqlite3_column_text(load_statement, 0);
		article.title = titleCString ? [NSString stringWithUTF8String:titleCString] : nil;
		char *HTMLCString = (char *)sqlite3_column_text(load_statement, 1);
		article.HTML = HTMLCString ? [NSString stringWithUTF8String:HTMLCString] : nil;
		char *categoryCString = (char *)sqlite3_column_text(load_statement, 2);
		article.category = categoryCString ? [NSString stringWithUTF8String:categoryCString] : nil;
		article.isCached = YES;
	} else {
		article = nil;
	}
	sqlite3_reset(load_statement);
	return article;
}

- (void)hydrateArticle:(WHArticle *)article {
	if (hydrate_statement == nil) {
		const char *sql = "SELECT html FROM articles WHERE identifier=? LIMIT 1";
		if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_text(hydrate_statement, 1, [article.identifier UTF8String], -1, SQLITE_TRANSIENT);
	int success = sqlite3_step(hydrate_statement);
	if (success == SQLITE_ROW) {
		char *HTMLCString = (char *)sqlite3_column_text(hydrate_statement, 0);
		NSString *HTMLString = [[NSString alloc] initWithUTF8String:HTMLCString];
		article.HTML = HTMLCString ? HTMLString : nil;
		[HTMLString release];
	}
	sqlite3_reset(hydrate_statement);
}

- (NSArray *)preloadedArticles {
	if (hydrate_statement == nil) {
		const char *sql = "SELECT identifier, title FROM articles";
		if (sqlite3_prepare_v2(database, sql, -1, &listup_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
	while (sqlite3_step(listup_statement) == SQLITE_ROW) {
		char *identifierCString = (char *)sqlite3_column_text(listup_statement, 0);
		NSString *identifier = identifierCString ? [NSString stringWithUTF8String:identifierCString] : nil;
		char *titleCString = (char *)sqlite3_column_text(listup_statement, 1);
		NSString *title = titleCString ? [NSString stringWithUTF8String:titleCString] : nil;
		NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:identifier, @"identifier", title, @"title", nil];
		[results addObject:dict];
		[dict release];
	}
	sqlite3_reset(listup_statement);
	return results;
}

- (NSArray *)findArticlesWithQuery:(NSString *)query {
	if (search_statement == nil) {
		const char *sql = "SELECT identifier, title FROM articles WHERE title LIKE ? LIMIT 20";
		if (sqlite3_prepare_v2(database, sql, -1, &search_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	NSString *preparedQuery = [[NSString alloc] initWithFormat:@"%%%@%%", query];
	sqlite3_bind_text(search_statement, 1, [preparedQuery UTF8String], -1, SQLITE_TRANSIENT);
	[preparedQuery release];
	NSMutableArray *results = [[NSMutableArray alloc] init];
	while (sqlite3_step(search_statement) == SQLITE_ROW) {
		char *identifierCString = (char *)sqlite3_column_text(search_statement, 0);
		NSString *identifier = identifierCString ? [NSString stringWithUTF8String:identifierCString] : nil;
		char *titleCString = (char *)sqlite3_column_text(search_statement, 1);
		NSString *title = titleCString ? [NSString stringWithUTF8String:titleCString] : nil;
		NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:identifier, @"identifier", [NSString stringWithFormat:@"How to %@", title], @"title", nil];
		[results addObject:dict];
		[dict release];
	}
	sqlite3_reset(search_statement);
	return [results autorelease];
}

@end
