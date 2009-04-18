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

#import "WHImageScrollView.h"


@implementation WHImageScrollView

- (void)setImage:(UIImage *)image {
	CGSize imageSize = image.size;
	CGRect viewFrame = self.frame;
	float imageAspectRatio = imageSize.width / imageSize.height;
	float viewAspectRatio = viewFrame.size.width / viewFrame.size.height;
	imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = (imageAspectRatio > viewAspectRatio) ? 
		CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.width / imageSize.width * imageSize.height) : 
		CGRectMake(0, 0, viewFrame.size.height / imageSize.height * imageSize.width, viewFrame.size.height);
	[self addSubview:imageView];
	[imageView release];
	[self setContentOffset:CGPointMake(0.0, 0.0)];
}

- (void)setContentOffset:(CGPoint)p {
	CGSize viewSize = self.contentSize;
	if (self.delegate) {
		UIView *contentView = [self.delegate viewForZoomingInScrollView:self];
		if (contentView) {
			viewSize = contentView.frame.size;
			CGSize scrollSize = self.bounds.size;
			if(viewSize.width < scrollSize.width)
			{
				p.x = -(scrollSize.width - viewSize.width) / 2.0;
			}
			if(viewSize.height < scrollSize.height)
			{
				p.y = -(scrollSize.height - viewSize.height) / 2.0;
			}
		}
	}
	super.contentOffset = p;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}


@end
