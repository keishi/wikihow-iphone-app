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

#import "WHSearchField.h"


@implementation WHSearchField


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

		UIImage *backgroundImage = [[UIImage imageNamed:@"SearchField.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16];
        self.background = backgroundImage;
		UIImageView *magnifyingGlassView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MagnifyingGlass.png"]];
		self.leftView = magnifyingGlassView;
		self.leftViewMode = UITextFieldViewModeAlways;
		[magnifyingGlassView release];
    }
    return self;
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
	if ([notification object] == self) {
		if ([self.delegate respondsToSelector:@selector(searchField:textDidChange:)]) {
			[self.delegate performSelector:@selector(searchField:textDidChange:) withObject:self withObject:self.text];
		}
	}
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	CGRect original = [super textRectForBounds:bounds];
	return CGRectMake(original.origin.x, original.origin.y+2, original.size.width, original.size.height-4);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	CGRect original = [super editingRectForBounds:bounds];
	return CGRectMake(original.origin.x, original.origin.y+2, original.size.width, original.size.height-4);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
	CGRect original = [super clearButtonRectForBounds:bounds];
	return CGRectMake(original.origin.x, original.origin.y, original.size.width, original.size.height);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
	return CGRectMake(10.0, 8.0, 16.0, 16.0);
}

@end
