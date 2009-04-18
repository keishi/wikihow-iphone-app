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


@interface KCHTTPClient : NSObject {
	id delegate;
	NSString *userAgent;
	NSString *referer;
	NSUInteger maximumRedirects;
	NSURLConnection *connection;
	NSHTTPURLResponse *response;
	NSMutableData *buffer;
	NSUInteger redirectCount;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *referer;
@property (nonatomic, assign) NSUInteger maximumRedirects;

+ (NSString *)buildQueryString:(NSDictionary *)params;
- (void)cancel;
- (void)get:(NSURL *)URL parameters:(NSDictionary *)params;
- (void)post:(NSURL *)URL parameters:(NSDictionary *)params;
- (BOOL)isLoading;

@end

@protocol KCHTTPClientDelegate

- (void)HTTPClientDidSucceed:(KCHTTPClient *)sender response:(NSHTTPURLResponse *)response data:(NSData *)data;
- (void)HTTPClientDidFail:(KCHTTPClient *)sender error:(NSError *)error;
- (void)HTTPClientDownloading:(KCHTTPClient *)sender progress:(float)progress;

@end

