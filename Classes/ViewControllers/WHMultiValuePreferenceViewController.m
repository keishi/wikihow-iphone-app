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

#import "WHMultiValuePreferenceViewController.h"


@implementation WHMultiValuePreferenceViewController

@synthesize cell;
@synthesize titles;
@synthesize values;
@synthesize key;
@synthesize selectedIndex;

- (id)initWithSpecifier:(NSDictionary *)specifier {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = [specifier objectForKey:@"Title"];
		titles = [[specifier objectForKey:@"Titles"] retain];
		values = [[specifier objectForKey:@"Values"] retain];
		key = [[specifier objectForKey:@"Key"] copy];
		id saved = [[NSUserDefaults standardUserDefaults] objectForKey:key];
		selectedIndex = saved ? [values indexOfObject:saved] : [values indexOfObject:[specifier objectForKey:@"DefaultValue"]];
		if (selectedIndex == NSNotFound) {
			selectedIndex = 0;
		}
		cell = [[WHMultiValuePreferenceCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MultiValuePreferenceCell"];
		cell.text = self.title;
		cell.valueLabel.text = [titles objectAtIndex:selectedIndex];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [titles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MultiValueOptionCell";
    
    UITableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (aCell == nil) {
        aCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (indexPath.row == selectedIndex) {
		aCell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	aCell.text = [titles objectAtIndex:indexPath.row];
	
    return aCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != selectedIndex) {
		NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
		[self.tableView cellForRowAtIndexPath:prevIndexPath].accessoryType = UITableViewCellAccessoryNone;
		selectedIndex = indexPath.row;
		[self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		[[NSUserDefaults standardUserDefaults] setObject:[values objectAtIndex:selectedIndex] forKey:key];
		cell.valueLabel.text = [titles objectAtIndex:selectedIndex];
	}
}

- (void)dealloc {
	[cell release];
	[titles release];
	[values release];
	[key release];
    [super dealloc];
}


@end

