//
//  WHNetworkAlertView.m
//  wikiHow
//
//  Created by Keishi Hattori on 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WHNetworkAlertView.h"


@implementation WHNetworkAlertView


- (id)initWithError:(NSError *)error {
	[UIAppDelegate lockShake];
    if ([error code] == -1009) {
		[self initWithTitle:@"You are not connected to the Internet." message:@"To read or search for articles that are not stored on your device, you must connect to the Internet. While offline, you can still read articles in the Survival Kit or your bookmarks." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", @"Survival Kit", @"Bookmarks", nil];
		noConnectionAlert = YES;
	} else {
		[self initWithTitle:@"Network Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		noConnectionAlert = NO;
	}
    return self;
}

- (void)_selectTabForButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		UIAppDelegate.tabBarController.selectedIndex = 0;
	} else if (buttonIndex == 2) {
		UIAppDelegate.tabBarController.selectedIndex = 2;
	}
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[UIAppDelegate unlockShake];
	if (noConnectionAlert) {
		[self _selectTabForButtonIndex:buttonIndex];
	}
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}


@end
