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

#import "wikiHowAppDelegate.h"
#import "WHLoadingIndicator.h"
#import "WHNavigationController.h"
#import "WHArticleCache.h"
#import "WHArticlePreloadedCache.h"
#import "WHSearchViewController.h"
#import "KCNetworkActivityIndicator.h"
#import "FlurryAPI.h"
#import "NSString+wikiHow.h"
#import "WHNetworkAlertView.h"


@implementation wikiHowAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize landscapeView;
@synthesize version;
@synthesize tipsViewController;
@synthesize isShakeEnabled;

#define WHAccelerometerFrequency 20
#define WHAccelerationFilteringFactor 0.1
#define WHMinShakeToShuffleInterval 1.0
#define WHShakeAccelerationThreshold 3.2

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	shakeSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shake" ofType:@"aif"]];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / WHAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	shakeLockCount = 0;
	
	landscapeView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	landscapeView.backgroundColor = [UIColor grayColor];
	landscapeLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 32)];
	landscapeLoadingLabel.text = @"Loading...";
	landscapeLoadingLabel.backgroundColor = [UIColor grayColor];
	landscapeLoadingLabel.textColor = [UIColor whiteColor];
	landscapeLoadingLabel.font = [UIFont boldSystemFontOfSize:24];
	landscapeLoadingLabel.shadowColor = [UIColor darkGrayColor];
	landscapeLoadingLabel.shadowOffset = CGSizeMake(0, -1);
	landscapeLoadingLabel.textAlignment = UITextAlignmentCenter;
	landscapeLoadingLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	landscapeLoadingLabel.center = CGPointMake(160, 240);
	landscapeLoadingLabel.transform = CGAffineTransformMakeRotation(3.1415/2);
	[landscapeView addSubview:landscapeLoadingLabel];
	[landscapeLoadingLabel release];
	
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	
	tipsViewController = [[WHTipsViewController alloc] initWithNibName:nil bundle:nil];
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if ([standardUserDefaults objectForKey:@"EnableShake"]) {
		isShakeEnabled = [standardUserDefaults boolForKey:@"EnableShake"];
	} else {
		[standardUserDefaults setBool:YES forKey:@"EnableShake"];
		isShakeEnabled = YES;
	}
	
	if (![standardUserDefaults objectForKey:@"OfflineSearch"]) {
		[standardUserDefaults setBool:NO forKey:@"OfflineSearch"];
	}
	
	NSArray *navigationLocation = [standardUserDefaults objectForKey:@"navigationLocation"];
	if (navigationLocation) {
		NSInteger i;
		NSInteger c = [navigationLocation count];
		NSString *rootIdentifier = [navigationLocation objectAtIndex:0];
		NSString *rootIdentifierNamespace = [rootIdentifier identifierNamespace];
		BOOL flag = NO;
		if ([rootIdentifierNamespace isEqualToString:@"SurvivalKit"]) {
			tabBarController.selectedIndex = 0;
		} else if ([rootIdentifierNamespace isEqualToString:@"Featured"]) {
			tabBarController.selectedIndex = 1;
		} else if ([rootIdentifierNamespace isEqualToString:@"Bookmarks"]) {
			tabBarController.selectedIndex = 2;
		} else if ([rootIdentifierNamespace isEqualToString:@"Search"]) {
			tabBarController.selectedIndex = 3;
			flag = YES;
		} else if ([rootIdentifierNamespace isEqualToString:@"Settings"]) {
			tabBarController.selectedIndex = 4;
		}
		WHNavigationController *rootNavigationController = (WHNavigationController *)tabBarController.selectedViewController;
		if (flag) {
			[(WHSearchViewController *)[rootNavigationController.viewControllers objectAtIndex:0] setSearchFieldText:[rootIdentifier identifierTitle]];
		}
		
		for (i = 1; i < c; i++) {
			[rootNavigationController pushViewControllerWithIdentifier:[navigationLocation objectAtIndex:i] animated:NO];
		}
	}
	
    [window addSubview:tabBarController.view];
	
	NSString *prevVersion = [standardUserDefaults objectForKey:@"Version"];
	version = [[temp objectForKey:@"CFBundleVersion"] copy];
	if  (!prevVersion) {
		[standardUserDefaults setObject:version forKey:@"Version"];
		[self showTips];
	} else if (![prevVersion isEqualToString:version]) {
		// Put update stuff here
	}
	
	[FlurryAPI startSession:FLURRY_API_KEY];
}

- (void)showTips {
	UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:UIAppDelegate action:@selector(hideTips)];
	tipsViewController.navigationItem.rightBarButtonItem = doneButtonItem;
	[doneButtonItem release];
	[window addSubview:tipsViewController.view];
	CGRect f = tipsViewController.view.frame;
	f.origin.y = f.size.height;
	tipsViewController.view.frame = f;
	[UIView beginAnimations:@"ShowingTips" context:nil];
	[UIView setAnimationDuration:0.3];
	f.origin.y = 20;
	tipsViewController.view.frame = f;
	[UIView commitAnimations];
}

- (void)hideTips {
	CGRect f = tipsViewController.view.frame;
	f.origin.y = 20;
	tipsViewController.view.frame = f;
	[UIView beginAnimations:@"HidingsTips" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideTipsDidStop:finished:context:)];
	f.origin.y = f.size.height;
	tipsViewController.view.frame = f;
	[UIView commitAnimations];
}

- (void)hideTipsDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	tipsViewController.navigationItem.rightBarButtonItem = nil;
	[tipsViewController.view removeFromSuperview];
}


- (void)showLandscapeView {
	[window addSubview:landscapeView];
	if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
		landscapeLoadingLabel.transform = CGAffineTransformMakeRotation(3.1415/2);
	} else {
		landscapeLoadingLabel.transform = CGAffineTransformMakeRotation(-3.1415/2);
	}
}

- (void)hideLandscapeView {
	[landscapeView removeFromSuperview];
}


- (void)dealloc {
    [openDialogURL release];
	[shakeSound release];
	[tabBarController release];
    [window release];
    [super dealloc];
}

- (void)openURLWithAlert:(NSURL *)URL {
	[openDialogURL release];
	openDialogURL = [URL copy];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Safari" message:@"Would you like to open the link in Safari?" delegate:self cancelButtonTitle:@"Don't Open" otherButtonTitles:@"Open", nil];
	[alertView show];
	[alertView release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL:openDialogURL];
	}
}

- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	if (!isShakeEnabled || shakeLockCount > 0) {
		return;
	}
	UIAccelerationValue length, x, y, z;
	
	//Use a basic high-pass filter to remove the influence of the gravity
	myAccelerometer[0] = acceleration.x * WHAccelerationFilteringFactor + myAccelerometer[0] * (1.0 - WHAccelerationFilteringFactor);
	myAccelerometer[1] = acceleration.y * WHAccelerationFilteringFactor + myAccelerometer[1] * (1.0 - WHAccelerationFilteringFactor);
	myAccelerometer[2] = acceleration.z * WHAccelerationFilteringFactor + myAccelerometer[2] * (1.0 - WHAccelerationFilteringFactor);
	// Compute values for the three axes of the acceleromater
	x = acceleration.x - myAccelerometer[0];
	y = acceleration.y - myAccelerometer[0];
	z = acceleration.z - myAccelerometer[0];
	
	//Compute the intensity of the current acceleration 
	length = sqrt(x * x + y * y + z * z);
	// If above a given threshold, play the erase sounds and erase the drawing view
	if((length >= WHShakeAccelerationThreshold) && (CFAbsoluteTimeGetCurrent() > lastTime + WHMinShakeToShuffleInterval)) {
		[shakeSound play];
		[[KCNetworkActivityIndicator sharedIndicator] start];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.wikihow.com/Special:Random"]];
		[request setHTTPMethod:@"HEAD"];
		[[NSURLConnection alloc] initWithRequest:request delegate:self];
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[WHArticleCache sharedCache] deleteOldCache];
	[[WHArticleCache sharedCache] cleanup];
	[[WHArticlePreloadedCache sharedPreloadedCache] cleanup];
	WHNavigationController *selectedViewController = (WHNavigationController *)[tabBarController selectedViewController];
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:[selectedViewController navigationLocation] forKey:@"navigationLocation"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSString *title = [[[response URL] path] substringFromIndex:1];
	[(WHNavigationController *)[tabBarController selectedViewController] pushViewControllerWithIdentifier:[NSString stringWithFormat:@"Article:%@", title] animated:YES];
	[[KCNetworkActivityIndicator sharedIndicator] stop];
	[connection cancel];
	[connection release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	WHNetworkAlertView *alertView = [[WHNetworkAlertView alloc] initWithError:error];
	[alertView show];
	[alertView release];
	
	[connection cancel];
	[connection release];
}

- (void)lockShake {
	shakeLockCount++;
}

- (void)unlockShake {
	shakeLockCount--;
}

#ifdef ENABLE_STATELESS_TABS
- (void)tabBarController:(UITabBarController *)aTabBarController didSelectViewController:(UIViewController *)viewController {
	[(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
}
#endif

@end

