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

#import "WHFeaturedViewController.h"
#import "TouchXML.h"
#import "WHNavigationController.h"
#import "WHTableViewCell.h"
#import "NSString+wikiHow.h"
#import "WHNetworkAlertView.h"


@implementation WHFeaturedViewController

- (id)initWithIdentifier:(NSString *)identifier {
	[super initWithNibName:nil bundle:nil];
	if ([[identifier identifierNamespace] isEqualToString:@"Featured"]) {
		self.title = NSLocalizedString(@"How to of the Day", @"Title for FeaturedView");
	} else {
		NSAssert1(0, @"Identifier namespace is wrong. %@", identifier);
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = 80;
	UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadFeatured)];
	self.navigationItem.rightBarButtonItem = refreshButtonItem;
	[refreshButtonItem release];
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *storedFeaturedArticles = [standardUserDefaults objectForKey:@"featured"];
	if (storedFeaturedArticles) {
		featuredArticles = storedFeaturedArticles;
		[self.tableView reloadData];
	}
	[self loadFeatured];
}

- (void)loadFeatured {
	NSURL *feedURL = [[NSURL alloc] initWithString:@"http://www.wikihow.com/feed.rss"];
	HTTPClient = [[KCHTTPClient alloc] init];
	HTTPClient.delegate = self;
	[HTTPClient get:feedURL parameters:nil];
	[feedURL release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
 
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [featuredArticles count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"wikiHowCell";
    
    WHTableViewCell *cell = (WHTableViewCell *)[tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WHTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.title = [[featuredArticles objectAtIndex:indexPath.row] objectForKey:@"title"];
	
    return cell;
}

#pragma mark UITableView Delegate Methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	WHNavigationController *navCtrl = (WHNavigationController *)self.navigationController;
	[navCtrl pushViewControllerWithIdentifier:[[featuredArticles objectAtIndex:indexPath.row] objectForKey:@"identifier"] animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


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


- (void)dealloc {
	[featuredArticles release];
	if (HTTPClient) {
		[HTTPClient cancel];
		[HTTPClient release];
		HTTPClient = nil;
	}
    [super dealloc];
}

#pragma mark KCHTTPClient Delegate Methods

- (void)HTTPClientDidSucceed:(KCHTTPClient *)sender response:(NSHTTPURLResponse *)response data:(NSData *)data {
	CXMLDocument *rssDoc = [[CXMLDocument alloc] initWithData:data options:0 error:nil];
	NSArray *itemNodes = [rssDoc nodesForXPath:@"rss/channel/item" error:nil];
	CXMLNode *itemNode;
	featuredArticles = [[NSMutableArray alloc] init];
	for (itemNode in itemNodes) {
		NSString *identifier;
		CXMLNode *linkNode = [[itemNode nodesForXPath:@"link" error:nil] objectAtIndex:0];
		NSURL *URL = [NSURL URLWithString:[linkNode stringValue]];
		NSString *str = [[URL path] substringFromIndex:1];
		if (![str hasPrefix:@"Category:"]) {
			identifier = [NSString stringWithFormat:@"Article:%@", str];
		} else {
			identifier = str;
		}
		
		CXMLNode *titleNode = [[itemNode nodesForXPath:@"title" error:nil] objectAtIndex:0];
		
		NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
													[titleNode stringValue], @"title", 
													identifier, @"identifier", 
													nil];
		[featuredArticles addObject:dict];
		[dict release];
	}
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:featuredArticles forKey:@"featured"];
	[rssDoc release];
	[self.tableView reloadData];

#ifdef DEBUG
	NSAssert(HTTPClient == sender, @"HTTPClient != sender in FeaturedViewController");
#endif
	[HTTPClient release];
	HTTPClient = nil;
}

- (void)HTTPClientDidFail:(KCHTTPClient *)sender error:(NSError *)error {
	WHNetworkAlertView *alertView = [[WHNetworkAlertView alloc] initWithError:error];
	[alertView show];
	[alertView release];

#ifdef DEBUG
	NSAssert(HTTPClient == sender, @"HTTPClient != sender in FeaturedViewController");
#endif
	[HTTPClient release];
	HTTPClient = nil;
}

- (NSString *)identifier {
	return @"Featured:";
}

@end

