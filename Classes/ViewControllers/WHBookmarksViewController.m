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

#import "WHBookmarksViewController.h"
#import "WHBookmarksDataSource.h"
#import "WHTableViewCell.h"
#import "WHBookmark.h"
#import "WHNavigationController.h"


@implementation WHBookmarksViewController


- (void)dealloc {
	[lastReload release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	lastReload = [[NSDate alloc] init];

	self.navigationItem.title = NSLocalizedString(@"Bookmarks", @"Title for Bookmarks View");
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.rowHeight = 80.0;
	
	noBookmarksLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 32)];
	noBookmarksLabel.text = NSLocalizedString(@"No Bookmarks", nil);
	noBookmarksLabel.backgroundColor = [UIColor whiteColor];
	noBookmarksLabel.textColor = [UIColor grayColor];
	noBookmarksLabel.textAlignment = UITextAlignmentCenter;
	noBookmarksLabel.font = [UIFont boldSystemFontOfSize:24];
	noBookmarksLabel.center = CGPointMake(160, 120);
	noBookmarksLabel.hidden = YES;
	[self.tableView addSubview:noBookmarksLabel];
	[noBookmarksLabel release];
}


- (void)viewWillAppear:(BOOL)animated {
	if ([lastReload compare:[[WHBookmarksDataSource sharedDataSource] lastModified]] == NSOrderedAscending) {
		[lastReload release];
		lastReload = [[NSDate alloc] init];
		[self.tableView reloadData];
	}
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [super viewWillAppear:animated];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger count = [[[WHBookmarksDataSource sharedDataSource] bookmarks] count];
	if (count == 0) {
		noBookmarksLabel.hidden = NO;
		self.navigationItem.rightBarButtonItem.enabled = NO;
	} else {
		noBookmarksLabel.hidden = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"wikiHowCell";
    
    WHTableViewCell *cell = (WHTableViewCell *)[tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WHTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	NSArray *bookmarks = [[WHBookmarksDataSource sharedDataSource] bookmarks];
	cell.title = [NSString stringWithFormat:@"How to %@", [(WHBookmark *)[bookmarks objectAtIndex:(bookmarks.count - 1 - indexPath.row)] title]];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *bookmarks = [[WHBookmarksDataSource sharedDataSource] bookmarks];
	WHNavigationController *navCtrl = (WHNavigationController *)self.navigationController;
	[navCtrl pushViewControllerWithIdentifier:[(WHBookmark *)[bookmarks objectAtIndex:(bookmarks.count - 1 - indexPath.row)] identifier] animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *bookmarks = [[WHBookmarksDataSource sharedDataSource] bookmarks];
		[bookmarks removeObjectAtIndex:(bookmarks.count - 1 - indexPath.row)];
		[[WHBookmarksDataSource sharedDataSource] updateLastModified];
		[lastReload release];
		lastReload = [[NSDate alloc] init];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSString *)identifier {
	return @"Bookmarks:";
}

@end

