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

#import "WHAboutViewController.h"


@implementation WHAboutViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"About";
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 3;
		case 1:
			return 2;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (indexPath.section == 1 && indexPath.row == 1) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		UILabel *creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 280, 110)];
		[cell addSubview:creditsLabel];
		creditsLabel.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"txt"]];
		creditsLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		creditsLabel.textColor = [UIColor grayColor];
		creditsLabel.lineBreakMode = UILineBreakModeWordWrap;
		[creditsLabel setNumberOfLines:0];
		return cell;
	}
	
	if (indexPath.section == 0 && indexPath.row == 2) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		UILabel *creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 260, 72)];
		[cell addSubview:creditsLabel];
		creditsLabel.text = @"This application is open source software. For more information or a copy of the code, please see http://www.wikihow.com/wikiHow:IPhone";
		creditsLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		creditsLabel.lineBreakMode = UILineBreakModeWordWrap;
		creditsLabel.backgroundColor = [UIColor clearColor];
		[creditsLabel setNumberOfLines:0];
		return cell;
	}
	
    static NSString *CellIdentifier = @"AboutCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.image = [UIImage imageNamed:@"About.png"];
					break;
				case 1:
					cell.text = [NSString stringWithFormat:@"Version %@", UIAppDelegate.version];
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.text = @"About the coder";
					break;
			}
			break;
	}
	

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					return 80;
				case 2:
					return 82;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 1:
					return 124;
			}
			break;
	}
	
	return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 2) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wikihow.com/wikiHow:IPhone"]];
	}
	if (indexPath.section == 1 && indexPath.row == 0) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://keishi.net"]];
	}
}

@end

