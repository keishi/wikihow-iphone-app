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

#import "WHSuggestionViewController.h"

#define WHSuggestionHistoryLimit 100

@implementation WHSuggestionViewController

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		self.tableView.rowHeight = 36.0;
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		history = [standardUserDefaults objectForKey:@"history"];
		if (!history) {
			history = [[NSMutableArray alloc] init];
		}
		result = [[NSMutableArray alloc] init];
		self.tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveHistory) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
	[history release];
	[result release];
    [super dealloc];
}

- (void)saveHistory {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:history forKey:@"history"];
}

- (void)add:(NSString *)s {
	if ([history indexOfObject:s] == NSNotFound) {
		[history addObject:[s copy]];
		if ([history count] > WHSuggestionHistoryLimit) {
			[history removeLastObject];
		}
	}
}

- (void)suggestWithQuery:(NSString *)q {
	NSString *h;
	[result release];
	result = [[NSMutableArray alloc] init];
	if ([q length] != 0) {
		NSString *uppercaseQ = [q uppercaseString];
		for (h in history) {
			NSString *uppercaseH = [h uppercaseString];
			if ([uppercaseH hasPrefix:uppercaseQ] && ![uppercaseH isEqualToString:uppercaseQ]) {
				[result addObject:h];
			}
		}
	}
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	self.tableView.hidden = ([result count] == 0);
	return [result count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SuggestionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.text = [result objectAtIndex:([result count] - 1 - indexPath.row)];
	cell.font = [UIFont boldSystemFontOfSize:16.0];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *suggestion = [result objectAtIndex:([result count] - 1 - indexPath.row)];
	[history removeObject:suggestion];
	[history addObject:suggestion];
	if ([delegate respondsToSelector:@selector(didSelectSuggestion:)]) {
		[delegate performSelector:@selector(didSelectSuggestion:) withObject:suggestion];
	}
}


@end

