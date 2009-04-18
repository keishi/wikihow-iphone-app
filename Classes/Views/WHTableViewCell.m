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

#import "WHTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

static float kCellMarginTop = 10.0;
static float kCellMarginLeft = 10.0;
static float kCellMarginBottom = 10.0;
static float kCellMarginRight = 5.0;
static float kCellMarginRightDisclosureIndicator = 24.0;
static float kCellMarginRightIndex = 24.0;

@implementation WHTableViewCell

@synthesize isUsingIndex;

- (id)init {
	if (self = [super init]) {
		isUsingIndex = NO;
		leftIndentation = 0;
	}
	return self;
}

- (void)dealloc {
	[icon release];
	[title release];
	[super dealloc];
}

- (UIImage *)icon {
	return icon;
}

- (void)setIcon:(UIImage *)img {
	if (icon != img) {
		[icon release];
		icon = [img retain];
		[self setNeedsDisplay];
	}
}

- (NSString *)title {
	return title;
}

- (void)setTitle:(NSString *)str {
	if (![title isEqualToString:str]) {
		[title release];
		title = [str copy];
		[self setNeedsDisplay];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	if (editing == self.editing) {
		[super setEditing:editing animated:animated];
	} else {
		[super setEditing:editing animated:animated];
		leftIndentation = editing ? 30.0 : 0.0;
		if (animated) {
			[contentView setNeedsDisplay];
			CATransition *animation = [CATransition animation];
			[animation setType:kCATransitionFade];
			[animation setDuration:0.3];
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			[[contentView layer] addAnimation:animation forKey:@"selectAnimation"];
		}
	}
}

- (void)drawContentView:(CGRect)r {
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *backgroundColor = [UIColor whiteColor];
	UIColor *textColor = [UIColor blackColor];
	if (self.selected) {
		backgroundColor = [UIColor clearColor];
		textColor = [UIColor whiteColor];
	}
	[backgroundColor set];
	CGRect backgroundRect = CGRectMake(0, 0, r.size.width, r.size.height);
	CGContextFillRect(context, backgroundRect);
	
	[textColor set];
	CGRect titleRect = CGRectMake(kCellMarginLeft + leftIndentation, 0, r.size.width - kCellMarginLeft - kCellMarginRight - leftIndentation, r.size.height - kCellMarginTop - kCellMarginBottom);
	if (icon) {
		titleRect.origin.x += r.size.height;
		titleRect.size.width -= r.size.height;
		[icon drawAtPoint:CGPointMake(0, 0)];
	}
	if (!self.editing) {
		if (self.accessoryType != UITableViewCellAccessoryNone) {
			titleRect.size.width -= kCellMarginRightDisclosureIndicator - kCellMarginRight;
		} else if (isUsingIndex) {
			titleRect.size.width -= kCellMarginRightIndex - kCellMarginRight;
		}
	}
	UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
	CGSize titleSize = [title sizeWithFont:titleFont constrainedToSize:titleRect.size lineBreakMode:UILineBreakModeTailTruncation];
	titleRect.origin.y = (r.size.height - titleSize.height) / 2;
	[title drawInRect:titleRect withFont:[UIFont boldSystemFontOfSize:20] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}


@end
