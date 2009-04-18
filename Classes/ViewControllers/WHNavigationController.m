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

#import "WHNavigationController.h"
#import "NSString+wikiHow.h"
#import "WHArticleViewController.h"
#import "WHImageViewController.h"
#import "WHSearchViewController.h"
#import "WHSurvivalKitViewController.h"
#import "WHFeaturedViewController.h"
#import "WHPreferenceViewController.h"


@implementation WHNavigationController

- (void)pushViewControllerWithIdentifier:(NSString *)identifier animated:(BOOL)animated {
	NSString *identifierNamespace = [identifier identifierNamespace];
	UIViewController *viewController;
	if ([identifierNamespace isEqualToString:@"Article"]) {
		viewController = [[WHArticleViewController alloc] initWithIdentifier:identifier];
	} else if ([identifierNamespace isEqualToString:@"SurvivalKit"]) {
		viewController = [[WHSurvivalKitViewController alloc] init];
	} else if ([identifierNamespace isEqualToString:@"Search"]) {
		viewController = [[WHSearchViewController alloc] initWithIdentifier:identifier];
	} else if ([identifierNamespace isEqualToString:@"Featured"]) {
		viewController = [[WHFeaturedViewController alloc] initWithIdentifier:identifier];
	} else if ([identifierNamespace isEqualToString:@"Image"]) {
		viewController = [[WHImageViewController alloc] initWithIdentifier:identifier];
	} else if ([identifierNamespace isEqualToString:@"Settings"]) {
		viewController = [[WHPreferenceViewController alloc] init];
	}
	[self pushViewController:viewController animated:animated];
	[viewController release];
}

- (NSMutableArray *)navigationLocation {
	NSMutableArray *location = [[[NSMutableArray alloc] init] autorelease];
	UIViewController *viewController;
	for (viewController in self.viewControllers) {
		if ([viewController respondsToSelector:@selector(identifier)]) {
			[location addObject:[viewController performSelector:@selector(identifier)]];
		} else {
			break;
		}
	}
	return location;
}

#pragma mark Handling Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [[self visibleViewController] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
