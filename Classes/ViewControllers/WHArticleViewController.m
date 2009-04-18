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

#import <QuartzCore/QuartzCore.h>
#import "WHArticleViewController.h"
#import "WHArticleCache.h"
#import "WHArticlePreloadedCache.h"
#import "WHNavigationController.h"
#import "NSString+wikiHow.h"
#import "GTMNSString+HTML.h"
#import "NSURL+wikiHow.h"
#import "WHBookmarksDataSource.h"
#import "NSString+HTTPClient.h"
#import "WHNetworkAlertView.h"

#define WHWebViewTimeoutInterval 5

static NSString *_template = nil;

@implementation WHArticleViewController

@synthesize article;

+ (NSString *)template {
	if (!_template) {
		NSString* path = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
		if (path) {
			NSError *error;
			_template = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
		}
	}
	
	return _template;
}

+ (void)releaseTemplate {
	if (_template) {
		[_template release];
		_template = nil;
	}
}

- (id)initWithIdentifier:(NSString *)identifier {
	[super initWithNibName:nil bundle:nil];
	if ([[identifier identifierNamespace] isEqualToString:@"Article"]) {
		webView = [[UIWebView alloc] init];
		webView.scalesPageToFit = YES;
		webView.delegate = self;
		webView.hidden = YES;
		
		UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wikiHowTitle.png"]];
		self.navigationItem.titleView = titleView;
		[titleView release];
		
		UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showActionSheet:)];
		self.navigationItem.rightBarButtonItem = addBarButtonItem;
		[addBarButtonItem release];
		
		article = [[[WHArticleCache sharedCache] cachedArticleWithIdentifier:identifier] retain];
		if (!article) {
			article = [[[WHArticlePreloadedCache sharedPreloadedCache] cachedArticleWithIdentifier:identifier] retain];
		}
		if (article) {
			[self showArticle];
		} else {
			NSString *identifierTitle = [identifier substringFromIndex:8];
			NSString *URLString = [[NSString alloc] initWithFormat:@"http://www.wikihow.com/api.php?action=parse&format=xml&page=%@", identifierTitle];
			NSURL *URL = [[NSURL alloc] initWithString:URLString];
			article = [[WHArticle alloc] init];
			article.identifier = identifier;
			article.title = [identifierTitle stringUnescapedWikiHowStyle];
			HTTPClient = [[KCHTTPClient alloc] init];
			HTTPClient.delegate = self;
			[HTTPClient get:URL parameters:nil];
			[URLString release];
			[URL release];
		}
	} else {
		NSAssert1(0, @"Identifier namespace is wrong. %@", identifier);
	}
	return self;
}

- (void)dealloc {
	if (HTTPClient) {
		[HTTPClient cancel];
		[HTTPClient release];
		HTTPClient = nil;
	}
	[article release];
	[webView release];
    [super dealloc];
}

- (void)showArticle {
	if (self.navigationController.visibleViewController == self) {
		HTMLNotSetFlag = NO;
		[self setHTML];
	} else {
		HTMLNotSetFlag = YES;
	}
}

- (void)setHTML {
	NSString *HTML = [[NSString alloc] initWithFormat:[WHArticleViewController template], [[NSUserDefaults standardUserDefaults] objectForKey:@"FontSize"], [article.title gtm_stringByEscapingForHTML], article.HTML];
	[webView loadHTMLString:HTML baseURL:[NSURL URLWithString:@"about:wikiHowArticle"]];
	[HTML release];
	[NSTimer scheduledTimerWithTimeInterval:WHWebViewTimeoutInterval target:self selector:@selector(webViewTimeout) userInfo:nil repeats:NO];
}

- (void)changeHash:(NSString *)fragment {
	if (fragment) {
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.hash=\"%@\";", fragment]];
	}
}

- (void)webViewTimeout {
	if (webView.hidden) {
		webView.hidden = NO;
	}
}

- (NSString *)identifier {
	return article.identifier;
}

- (void)showActionSheet:(id)sender {
	UIActionSheet *actionSheet;
	if ([[WHBookmarksDataSource sharedDataSource] isBookmarked:article.identifier]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@"Mail Link to this Page", @"Open in Safari", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@"Add Bookmark", @"Mail Link to this Page", @"Open in Safari", nil];
	}
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:UIAppDelegate.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *URLString = [[NSString alloc] initWithFormat:@"http://www.wikihow.com/%@", [article.identifier substringFromIndex:8]];
	NSURL *URL = [[NSURL alloc] initWithString:URLString];
	NSString *mailtoURLString;
	NSURL *mailtoURL;
	NSString *emailBody;
	if ([actionSheet numberOfButtons] == 3) {
		buttonIndex++;
	}
	switch (buttonIndex) {
		case 0:
			[[WHBookmarksDataSource sharedDataSource] bookmarkArticle:article];
			break;
		case 1:
			emailBody = [[NSString alloc] initWithFormat:NSLocalizedString(@"Check out this how to on wikiHow:\n\n%@", nil), URLString];
			mailtoURLString = [[NSString alloc] initWithFormat:@"mailto:%@?&subject=%@&body=%@", @"", [[NSString stringWithFormat:@"How to %@", article.title] stringEscapedAsURIComponent], [emailBody stringEscapedAsURIComponent]];
			mailtoURL = [[NSURL alloc] initWithString:mailtoURLString];
			[[UIApplication sharedApplication] openURL:mailtoURL];
			[mailtoURL release];
			[mailtoURLString release];
			[emailBody release];
			break;
		case 2:
			[[UIApplication sharedApplication] openURL:URL];
			break;
		default:
			break;
	}
	[URLString release];
	[URL release];
}

#pragma mark Handling Rotation

- (void)setOrientation:(UIInterfaceOrientation)interfaceOrientation animated:(BOOL)animated {
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		[UIAppDelegate.landscapeView addSubview:webView];
		webView.transform = CGAffineTransformMakeRotation(- 90 / 57.29578);
		webView.frame = CGRectMake(00.0, 0.0, 320.0, 480.0);
		[UIAppDelegate showLandscapeView];
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:animated];
	} else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[UIAppDelegate.landscapeView addSubview:webView];
		webView.transform = CGAffineTransformMakeRotation(90 / 57.29578);
		webView.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
		[UIAppDelegate showLandscapeView];
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:animated];
	} else if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.view addSubview:webView];
		webView.transform = CGAffineTransformMakeRotation(0.0);
		webView.frame = self.view.bounds;
		[UIAppDelegate hideLandscapeView];
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:animated];
	}
	
	if (animated) {
		CATransition *animation = [CATransition animation];
		[animation setType:kCATransitionFade];
		[animation setDuration:0.6];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		animation.delegate = self;
		
		[[UIAppDelegate.window layer] addAnimation:animation forKey:@"rotateAnimation"];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[self setOrientation:interfaceOrientation animated:YES];
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Observing Views

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor = [UIColor colorWithRed:0.59f green:0.59f blue:0.61f alpha:1.0f];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view = contentView;
	[contentView release];
	
	loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	loadingIndicatorView.center = CGPointMake(120, 180);
	[contentView addSubview:loadingIndicatorView];
	[loadingIndicatorView startAnimating];
	
	UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 172, 80, 20)];
	loadingLabel.text = NSLocalizedString(@"Loading...", nil);
	loadingLabel.textColor = [UIColor colorWithRed:0.18 green:0.20 blue:0.23 alpha:1.0];
	loadingLabel.backgroundColor = [UIColor colorWithRed:0.59f green:0.59f blue:0.61f alpha:1.0f];
	[contentView addSubview:loadingLabel];
	
	webView.frame = self.view.bounds;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[contentView addSubview:webView];
}

- (void)viewDidAppear:(BOOL)animated {
	if (HTMLNotSetFlag) {
		[self setHTML];
		HTMLNotSetFlag = NO;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	if (webView.superview == UIAppDelegate.landscapeView) {
		[self.view addSubview:webView];
		webView.transform = CGAffineTransformMakeRotation(0.0);
		webView.frame = self.view.bounds;
		[UIAppDelegate hideLandscapeView];
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[self setOrientation:[UIDevice currentDevice].orientation animated:NO];
}

#pragma mark Handling Memory Warnings

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[WHArticleViewController releaseTemplate];
}

#pragma mark KCHTTPClient Delegate Methods

- (void)HTTPClientDidSucceed:(KCHTTPClient *)sender response:(NSHTTPURLResponse *)response data:(NSData *)data {
	NSString *XML = [[NSString alloc] initWithCString:data.bytes encoding:NSUTF8StringEncoding];
	
	BOOL noSuchActionError = NO;
	
#ifdef CHECK_FOR_NOSUCHACTION
	noSuchActionError = [XML rangeOfString:@"No such action"].location != NSNotFound;
#endif
	if (noSuchActionError) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"wikiHow Server Failed" message:@"No such action" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alertView show];
		[alertView release];
	} else if ([XML rangeOfString:@"REDIRECT"].location != NSNotFound) {
		NSRange plBeginTagStartRange = [XML rangeOfString:@"<pl"];
		NSRange lastHalfRange;
		lastHalfRange.location = plBeginTagStartRange.location + plBeginTagStartRange.length;
		lastHalfRange.length = XML.length - lastHalfRange.location;
		NSRange plBeginTagEndRange = [XML rangeOfString:@">" options:NSLiteralSearch range:lastHalfRange];
		NSRange fromPlContentRange;
		fromPlContentRange.location = plBeginTagEndRange.location + 1;
		fromPlContentRange.length = XML.length - fromPlContentRange.location;
		NSRange plEndTagRange = [XML rangeOfString:@"</pl>" options:NSLiteralSearch range:fromPlContentRange];
		NSRange plTagContentRange;
		plTagContentRange.location = plBeginTagEndRange.location + 1;
		plTagContentRange.length = plEndTagRange.location - plBeginTagEndRange.location - 1;
		NSString *plContent = [XML substringWithRange:plTagContentRange];
		KCLog([plContent stringEscapedWikiHowStyle]);
		NSString *URLString = [[NSString alloc] initWithFormat:@"http://www.wikihow.com/api.php?action=parse&format=xml&page=%@", [plContent stringEscapedWikiHowStyle]];
		KCLog(URLString);
		NSURL *URL = [[NSURL alloc] initWithString:URLString];
		HTTPClient = [[KCHTTPClient alloc] init];
		HTTPClient.delegate = self;
		[HTTPClient get:URL parameters:nil];
		[URLString release];
		[URL release];
		[sender release];
		return;
	} else {
		NSRange beginTagRange = [XML rangeOfString:@"<text>"];
		if (beginTagRange.location == NSNotFound) {
			KCLog(@"SERVER FAILED");
			return;
		}
		NSRange endTagRange = [XML rangeOfString:@"</text>"];
		if (endTagRange.location == NSNotFound) {
			KCLog(@"SERVER FAILED");
			return;
		}
		NSRange contentRange;
		contentRange.location = beginTagRange.location + beginTagRange.length;
		contentRange.length = endTagRange.location - contentRange.location;
		NSString *content = [XML substringWithRange:contentRange];
		
		NSString *lastHalf = [XML substringFromIndex:(contentRange.location + contentRange.length)];
		[XML release];
		NSArray *categoryLinkComponents = [lastHalf componentsSeparatedByString:@"<cl"];
		NSInteger c = [categoryLinkComponents count];
		article.category = nil;
		if (c > 0) {
			NSInteger i;
			NSString *categoryLinkComponent;
			for (i = 1; i < c; i++) {
				categoryLinkComponent = [categoryLinkComponents objectAtIndex:i];
				NSRange startPositionRange = [categoryLinkComponent rangeOfString:@">"];
				NSString *tmp = [categoryLinkComponent substringFromIndex:(startPositionRange.location + 1)];
				NSRange endPositionRange = [tmp rangeOfString:@"</cl>"];
				NSString *cl = [tmp substringToIndex:endPositionRange.location];
				if (![cl isEqualToString:@"Featured-Articles"] || ![cl isEqualToString:@"Stub"]) {
					article.category = [NSString stringWithFormat:@"Category:%@", [cl stringEscapedWikiHowStyle]];
					break;
				}
			}
		}
		
		article.HTML = [content gtm_stringByUnescapingFromHTML];
		[[WHArticleCache sharedCache] cacheArticle:article];
		[self showArticle];
	}
#ifdef DEBUG
	NSAssert(HTTPClient == sender, @"HTTPClient != sender in SearchViewController");
#endif
	[HTTPClient release];
	HTTPClient = nil;
}

- (void)HTTPClientDidFail:(KCHTTPClient *)sender error:(NSError *)error {
	WHNetworkAlertView *alertView = [[WHNetworkAlertView alloc] initWithError:error];
	[alertView show];
	[alertView release];

#ifdef DEBUG
	NSAssert(HTTPClient == sender, @"HTTPClient != sender in SearchViewController");
#endif
	[HTTPClient release];
	HTTPClient = nil;
}

#pragma mark UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *URL = [request URL];
	if ([[URL scheme] isEqualToString:@"about"]) {
		return YES;
	}
	if ([URL isWikiHowArticleURL]) {
		NSString *newIdentifier;
		NSString *str = [[[URL path] substringFromIndex:1] stringEscapedAsURIComponent];
		if ([str hasPrefix:@"Category:"] || [str hasPrefix:@"Image:"]) {
			newIdentifier = str;
		} else {
			newIdentifier = [NSString stringWithFormat:@"Article:%@", str];
		}
		if ([newIdentifier isEqualToString:article.identifier] || [str isEqualToString:@""]) {
			[self changeHash:[URL fragment]];
		} else {
			[(WHNavigationController *)self.navigationController pushViewControllerWithIdentifier:newIdentifier animated:YES];
		}
	} else {
		[UIAppDelegate openURLWithAlert:URL];
	}
	return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[loadingIndicatorView stopAnimating];
	webView.hidden = NO;
}

@end
