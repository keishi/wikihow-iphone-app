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

#import "KCHTTPClient.h"
#import "KCNetworkActivityIndicator.h"
#import "NSString+HTTPClient.h"


@implementation KCHTTPClient

@synthesize delegate;
@synthesize userAgent;
@synthesize referer;
@synthesize maximumRedirects;

+ (NSString *)buildQueryString:(NSDictionary *)params {
	NSMutableArray *components = [[NSMutableArray alloc] init];
	NSString *key;
	for (key in params) {
		NSString *value = [[params objectForKey:key] stringEscapedAsURIComponent];
		NSString *component = [[NSString alloc] initWithFormat:@"%@=%@", key, value];
		[components addObject:component];
		[component release];
	}
	NSString *query = [components componentsJoinedByString:@"&"];
	[components release];
	return query;
}

- (id)init {
	if (self = [super init]) {
		userAgent = @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_5; en-us) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.20.1";
		referer = @"http://google.com";
		maximumRedirects = 5;
		delegate = nil;
	}
	return self;
}

- (void)dealloc {
	[self cancel];
	[userAgent release];
	[referer release];
	[super dealloc];
}

- (void)cancel {
	if (connection) {
		[connection cancel];
		[connection release];
		[[KCNetworkActivityIndicator sharedIndicator] stop];
	}
	[response release];
	[buffer release];
	
	connection = nil;
	response = nil;
	buffer = nil;
}

- (void)get:(NSURL *)URL parameters:(NSDictionary *)params {
	[self cancel];
	NSString *URLString;
	if (params) {
		NSString *queryString = [KCHTTPClient buildQueryString:params];
		if ([URL query]) {
			URLString = [[URL absoluteString] stringByAppendingFormat:@"&%@", queryString];
		} else {
			URLString = [[URL absoluteString] stringByAppendingFormat:@"?%@", queryString];
		}
	} else {
		URLString = [URL absoluteString];
	}
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	[request setHTTPShouldHandleCookies:YES];
	[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	[request setValue:referer forHTTPHeaderField:@"Referer"];
	redirectCount = maximumRedirects;
	[[KCNetworkActivityIndicator sharedIndicator] start];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	buffer = [NSMutableData new];
}

- (void)post:(NSURL *)URL parameters:(NSDictionary *)params {
	[self cancel];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
	[request setHTTPMethod:@"POST"];
	[request setHTTPShouldHandleCookies:YES];
	[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	[request setValue:referer forHTTPHeaderField:@"Referer"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	NSData* body;
	if (params) {
		body = [[KCHTTPClient buildQueryString:params] dataUsingEncoding:NSUTF8StringEncoding];
	} else {
		body = [@"" dataUsingEncoding:NSUTF8StringEncoding];
	}
    [request setValue:[NSString stringWithFormat:@"%d", body.length] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:body];
	redirectCount = maximumRedirects;
	[[KCNetworkActivityIndicator sharedIndicator] start];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	buffer = [NSMutableData new];
}

- (BOOL)isLoading {
	return !!connection;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)sender didReceiveResponse:(NSURLResponse *)aResponse {
	[response release];
	response = (NSHTTPURLResponse *)[aResponse retain];
}

- (void)connection:(NSURLConnection *)sender didReceiveData:(NSData *)data {
	[buffer appendData:data];
	if (response) {
		if ([delegate respondsToSelector:@selector(HTTPClientDownloading:progress:)]) {
			float progress = [response expectedContentLength] > 0 ? (float)[buffer length] / [response expectedContentLength] : 0.0;
			if (progress > 1.0) {
				progress = 1.0;
			}
			[delegate HTTPClientDownloading:self progress:progress];
		}
	}
}

- (void)connection:(NSURLConnection *)sender didFailWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(HTTPClientDidFail:error:)]) {
		[delegate HTTPClientDidFail:self error:error];
	}
	[self cancel];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)sender {
	if ([delegate respondsToSelector:@selector(HTTPClientDidSucceed:response:data:)]) {
		[delegate HTTPClientDidSucceed:self response:response data:[NSData dataWithData:buffer]];
	}
	[self cancel];
}

- (NSURLRequest *)connection:(NSURLConnection *)sender willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)aResponse {
	if (redirectCount == 0) {
		return nil;
	}
	redirectCount--;
	return request;
}

@end
