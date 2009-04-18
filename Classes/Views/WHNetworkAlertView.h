//
//  WHNetworkAlertView.h
//  wikiHow
//
//  Created by Keishi Hattori on 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WHNetworkAlertView : UIAlertView {
	BOOL noConnectionAlert;
}

- (id)initWithError:(NSError *)error;

@end
