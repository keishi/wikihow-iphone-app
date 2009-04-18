//
//  WHSearchNetworkAlertView.m
//  wikiHow
//
//  Created by Keishi Hattori on 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WHSearchNetworkAlertView.h"


@implementation WHSearchNetworkAlertView


- (id)initWithError:(NSError *)error {
	[UIAppDelegate lockShake];
    if ([error code] == -1009) {
		[self initWithTitle:@"You are not connected to the Internet." message:@"You are not connected to the internet and offline search is disabled. Offline search enables you to search articles stored in the Survival Kit and your bookmarks. To search, either connect to the internet or turn offline search on in settings." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", @"Settings", nil];
		noConnectionAlert = YES;
	} else {
		[self initWithTitle:@"Network Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		noConnectionAlert = NO;
	}
    return self;
}

- (void)_selectTabForButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		UIAppDelegate.tabBarController.selectedIndex = 4;
	}
}


@end
