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

#import "WHArticleCache.h"
#import "WHArticlePreloadedCache.h"

#define WHArticleCacheDatabaseName @"cache.db"

static WHArticleCache *sharedCache = nil;

@implementation WHArticleCache

+ (WHArticleCache *)sharedCache {
	if (sharedCache == nil) {
		sharedCache = [[WHArticleCache alloc] init];
	}
	return sharedCache;
}

- (void)finalizeStatements {
    if (load_statement) sqlite3_finalize(load_statement);
	if (insert_statement) sqlite3_finalize(insert_statement);
	if (search_statement) sqlite3_finalize(search_statement);
	if (hydrate_statement) sqlite3_finalize(hydrate_statement);
}

- (id)init {
	if (self = [super init]) {
		load_statement = nil;
		insert_statement = nil;
		search_statement = nil;
		hydrate_statement = nil;
		
		[self createEditableCopyOfDatabaseIfNeeded];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:WHArticleCacheDatabaseName];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:WHArticleCacheDatabaseName];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) {
		return;
	}
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:WHArticleCacheDatabaseName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (BOOL)cacheArticle:(WHArticle *)article {
	if (insert_statement == nil) {
		const char *sql = "INSERT INTO articles (timestamp, identifier, title, html, category, ispermanent) VALUES(?, ?, ?, ?, ?, ?)";
		if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
	}
	sqlite3_bind_int(insert_statement, 1, [[NSDate date] timeIntervalSince1970]);
	sqlite3_bind_text(insert_statement, 2, [article.identifier UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 3, [article.title UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 4, [article.HTML UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 5, [article.category UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insert_statement, 6, 0);
	int success = sqlite3_step(insert_statement);
	sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		return NO;
    }
	article.isCached = YES;
	return YES;
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
	[results addObjectsFromArray:[[WHArticlePreloadedCache sharedPreloadedCache] findArticlesWithQuery:query]];
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

- (void)deleteOldCache {
	sqlite3_stmt *delete_statement = nil;
	const char *sql = "DELETE FROM articles WHERE timestamp < ?";
	if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger cacheLife = [standardUserDefaults integerForKey:@"CacheLife"];
	if (cacheLife == 0) {
		return;
	}
	NSDate *thresholdDate = [[NSDate alloc] initWithTimeIntervalSinceNow:(-cacheLife*24*60*60)];
	sqlite3_bind_int(delete_statement, 1, [thresholdDate timeIntervalSince1970]);
	[thresholdDate release];
	int success = sqlite3_step(delete_statement);
	if (success == SQLITE_ERROR) {
        KCLog(@"Error: failed to delete cache with message '%s'.", sqlite3_errmsg(database));
    }
	sqlite3_reset(delete_statement);
	sqlite3_finalize(delete_statement);
	sqlite3_exec(database, "VACUUM", NULL, NULL, NULL);
}

@end
