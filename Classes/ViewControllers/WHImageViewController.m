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

#import "WHImageViewController.h"
#import "KCHTTPClient.h"
#import "NSString+wikiHow.h"
#import "JSON.h"
#import "UIImage+Resize.h"


@implementation WHImageViewController

@synthesize identifier;

- (id)initWithIdentifier:(NSString *)anIdentifier {
	[self init];
	identifier = [anIdentifier copy];
	return self;
}

- (void)dealloc {
	[identifier release];
    [super dealloc];
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor blackColor];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view = contentView;
	[contentView release];
	
	progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	progressView.frame = CGRectMake(80.0, 300.0, 160.0, 9.0);
	progressView.progress = 0.0;
	[contentView addSubview:progressView];
	[progressView release];
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wikiHowTitle.png"]];
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	maxRetry = 50;
	NSString *URLString = [[NSString alloc] initWithFormat:@"http://www.wikihow.com/api.php?action=query&titles=%@&prop=imageinfo&iiprop=url&format=json", identifier];
	NSURL *URL = [[NSURL alloc] initWithString:URLString];
	KCHTTPClient *HTTPClient = [[KCHTTPClient alloc] init];
	HTTPClient.delegate = self;
	[HTTPClient get:URL parameters:nil];
	[URL release];
	[URLString release];
}

#pragma mark KCHTTPClient Delegate Methods

- (void)HTTPClientDownloading:(KCHTTPClient *)sender progress:(float)progress {
	if (progressView.progress >= 0.1) {
		progressView.progress = 0.1 + (1 - 0.1) * progress;
	}
}

- (void)HTTPClientDidSucceed:(KCHTTPClient *)sender response:(NSHTTPURLResponse *)response data:(NSData *)data {
	if ([[response MIMEType] isEqualToString:@"application/json"]) {
		NSString *JSONString = [[NSString stringWithUTF8String:[data bytes]] normalizedJSONString];
		if (!JSONString && maxRetry > 0) {
			// Workaround for strange random failure. 
			maxRetry--;
			NSString *URLString = [[NSString alloc] initWithFormat:@"http://www.wikihow.com/api.php?action=query&titles=%@&prop=imageinfo&iiprop=url&format=json", identifier];
			NSURL *URL = [[NSURL alloc] initWithString:URLString];
			KCHTTPClient *HTTPClient = [[KCHTTPClient alloc] init];
			HTTPClient.delegate = self;
			[HTTPClient get:URL parameters:nil];
			[URL release];
			[URLString release];
		} else {
			NSDictionary *JSONObject = [JSONString JSONValue];
			NSDictionary *pages = (NSDictionary *)[[JSONObject objectForKey:@"query"] objectForKey:@"pages"];
			NSDictionary *page;
			NSString *imageURLString = nil;
			for (page in pages) {
				NSString *path = [[[[pages objectForKey:page] objectForKey:@"imageinfo"] objectAtIndex:0] objectForKey:@"url"];
				imageURLString = [NSString stringWithFormat:@"http://www.wikihow.com%@", path];
				break;
			}
			if (imageURLString) {
				KCHTTPClient *HTTPClient = [[KCHTTPClient alloc] init];
				HTTPClient.delegate = self;
				[HTTPClient get:[NSURL URLWithString:imageURLString] parameters:nil];
				progressView.progress = 0.1;
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could not Find Image" message:@"failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
				[alertView show];
				[alertView release];
			}
		}
	} else if ([[response MIMEType] isEqualToString:@"image/jpeg"] || [[response MIMEType] isEqualToString:@"image/png"] || [[response MIMEType] isEqualToString:@"image/gif"]) {
		scrollView = [[WHImageScrollView alloc] initWithFrame:self.view.bounds];
		scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		scrollView.scrollEnabled = YES;
		scrollView.directionalLockEnabled = NO;
		scrollView.bounces = YES;
		scrollView.bouncesZoom = YES;
		scrollView.scrollsToTop = NO;
		scrollView.delegate = scrollView;
		[self.view addSubview:scrollView];
		[scrollView release];
		
		UIImage *image = [[UIImage alloc] initWithData:data];
		if (image.size.width > 1024 || image.size.height > 1024) {
			CGSize newImageSize;
			if (image.size.width > 1024) {
				newImageSize = CGSizeMake(1024, 1024 / image.size.width * image.size.height);
			} else if (image.size.height > 1024) {
				newImageSize = CGSizeMake(1024 / image.size.height * image.size.width, 1024);
			}
			UIImage *newImage = [image imageScaledToSize:newImageSize];
			[image release];
			image = newImage;
			[image retain]; // Important! Retain to match retain count to non resizing case
		}
		
		[progressView removeFromSuperview];
		[scrollView setImage:image];
		[image release];
		scrollView.maximumZoomScale = 4.0;
	}
	[sender release];
}

- (void)HTTPClientDidFail:(KCHTTPClient *)sender error:(NSError *)error {
	KCLog(@"Image load failed with error:%@", error);
	[sender release];
}

@end
