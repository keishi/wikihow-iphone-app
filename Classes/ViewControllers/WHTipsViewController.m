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

#import "WHTipsViewController.h"


@implementation WHTipsViewController

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor = [UIColor clearColor];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view = contentView;
	[contentView release];
	
	UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320.0, 44.0)];
	self.navigationItem.title = @"wikiHow Tips";
	UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:UIAppDelegate action:@selector(hideTips)];
	self.navigationItem.rightBarButtonItem = doneButtonItem;
	[doneButtonItem release];
	navigationBar.barStyle = UIBarStyleBlackOpaque;
	[navigationBar pushNavigationItem:self.navigationItem animated:NO];
	[contentView addSubview:navigationBar];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Tips.png"]];
	CGRect imageViewFrame = imageView.frame;
	imageViewFrame.origin.y = 44.0;
	imageView.frame = imageViewFrame;
	[contentView addSubview:imageView];
	[imageView release];
	
	UIButton *tosButton = [[UIButton alloc] initWithFrame:CGRectMake(144, 79, 126, 26)];
	[tosButton addTarget:self action:@selector(showTOS) forControlEvents:UIControlEventTouchUpInside];
	[tosButton setImage:[UIImage imageNamed:@"TOS.png"] forState:UIControlStateNormal];
	[tosButton setImage:[UIImage imageNamed:@"TOSSelected.png"] forState:UIControlStateHighlighted];
	[contentView addSubview:tosButton];
	[tosButton release];
	
	UIButton *startButton = [[UIButton alloc] initWithFrame:CGRectMake(74, 280, 172, 57)];
	startButton.backgroundColor = [UIColor clearColor];
	[startButton addTarget:UIAppDelegate action:@selector(hideTips) forControlEvents:UIControlEventTouchUpInside];
	[startButton setImage:[UIImage imageNamed:@"StartButton.png"] forState:UIControlStateNormal];
	[contentView addSubview:startButton];
	[startButton release];
}

- (void)showTOS {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wikihow.com/Terms-of-Use"]];
}

@end
