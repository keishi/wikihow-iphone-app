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

#import "WHSearchViewController.h"
#import "NSString+wikiHow.h"
#import "NSString+HTTPClient.h"
#import "JSON.h"
#import "WHArticleCache.h"
#import "WHNavigationController.h"
#import "WHTableViewCell.h"
#import "WHSearchXMLReader.h"
#import "WHSearchNetworkAlertView.h"


@implementation WHSearchViewController

@synthesize tableView;

- (void)_setupSearchField {
	CGRect searchFieldFrame = CGRectMake(-23, 0, 307, 32);
	searchField = [[WHSearchField alloc] initWithFrame:searchFieldFrame];
	searchField.delegate = self;
	searchField.placeholder = NSLocalizedString(@"Search", @"Placeholder for search field.");
	searchField.borderStyle = UITextBorderStyleNone;
	searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	searchField.clearButtonMode = UITextFieldViewModeAlways;
}

- (id)initWithIdentifier:(NSString *)identifier {
	[self init];
	NSString *q = [identifier identifierTitle];
	[self _setupSearchField];
	searchField.text = q ? q : @"";
	[self updateResults];
	return self;
}

- (void)dealloc {
	if (HTTPClient) {
		[HTTPClient cancel];
		[HTTPClient release];
		HTTPClient = nil;
	}
	[results release];
	[searchField release];
	[shadeButton release];
	[suggestionViewController release];
    [super dealloc];
}

- (void)loadView {
	[super loadView];
	
	results = [[NSMutableArray alloc] init];
	
	tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.rowHeight = 80;
	[self.view addSubview:tableView];
	[tableView reloadData];
	
	if (!searchField) {
		[self _setupSearchField];
	}
	
	// Hack to get around UINavigationBar issue
	UIView *searchFieldContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 32)];
	searchFieldContainer.backgroundColor = [UIColor clearColor];
	[searchFieldContainer addSubview:searchField];
	self.navigationItem.titleView = searchFieldContainer;
	[searchFieldContainer release];
	
	shadeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 400.0)];
	shadeButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
	[shadeButton addTarget:self action:@selector(dismissSearchField) forControlEvents:UIControlEventTouchUpInside];
	shadeButton.hidden = YES;
	[self.view addSubview:shadeButton];
	
	suggestionViewController = [[WHSuggestionViewController alloc] initWithStyle:UITableViewStylePlain];
	suggestionViewController.delegate = self;
	suggestionViewController.tableView.frame = CGRectMake(0.0, 0.0, 320.0, 294.0);
	
	shakeIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShakeIndicator.png"]];
	[self.view addSubview:shakeIndicatorView];
	
	noMatchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 32)];
	noMatchesLabel.text = NSLocalizedString(@"No Matches", nil);
	noMatchesLabel.backgroundColor = [UIColor whiteColor];
	noMatchesLabel.textColor = [UIColor grayColor];
	noMatchesLabel.textAlignment = UITextAlignmentCenter;
	noMatchesLabel.font = [UIFont boldSystemFontOfSize:24];
	noMatchesLabel.center = CGPointMake(160, 120);
	noMatchesLabel.hidden = YES;
	[tableView addSubview:noMatchesLabel];
	[noMatchesLabel release];
}

- (void)dismissSearchField {
	[self textFieldShouldReturn:searchField];
}

- (NSString *)identifier {
	return [NSString stringWithFormat:@"Search:%@", searchField.text];
}

- (void)updateResults {
	if ([searchField.text length] == 0) {
		[results release];
		results = [[NSMutableArray alloc] init];
		[tableView reloadData];
		return;
	}
	[suggestionViewController add:searchField.text];
	NSString *parseURLString = [[NSString alloc] initWithFormat:@"http://www.wikihow.com/Special:LSearch?fulltext=Search&search=%@&rss=1", [searchField.text stringEscapedAsURIComponent]];
	NSURL *parseURL = [[NSURL alloc] initWithString:parseURLString];
	if (HTTPClient) {
		[HTTPClient cancel];
		[HTTPClient release];
		HTTPClient = nil;
	}
	HTTPClient = [[KCHTTPClient alloc] init];
	HTTPClient.delegate = self;
	[HTTPClient get:parseURL parameters:nil];
	[parseURL release];
	[parseURLString release];
}

- (void)setSearchFieldText:(NSString *)q {
	[self _setupSearchField];
	searchField.text = q ? q : @"";
	[self updateResults];
}

#pragma mark KCHTTPClient Delegate Methods

- (void)HTTPClientDidSucceed:(KCHTTPClient *)sender response:(NSHTTPURLResponse *)response data:(NSData *)data {
	WHSearchXMLReader *reader = [[WHSearchXMLReader alloc] init];
	NSError *error;
	[results release];
	
	NSString *XML = [NSString stringWithCString:data.bytes encoding:NSISOLatin1StringEncoding];
	if ([XML rangeOfString:@"<ERROR>500</ERROR>"].location != NSNotFound) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"<ERROR>500</ERROR>" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alertView show];
		[alertView release];
	}
	if ([XML rangeOfString:@"Sorry! An error was experienced while processing your search."].location != NSNotFound) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry! An error was experienced while processing your search." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alertView show];
		[alertView release];
	}
	
	
	results = [[reader parseXMLData:data parseError:&error] retain];
	if (!results && error) {
        KCLog(@"Error parsing search feed:%@", error);
    }
	noMatchesLabel.hidden = !([results count] == 0);
	
	[self.tableView reloadData];
	[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
	[reader release];
#ifdef DEBUG
		NSAssert(HTTPClient == sender, @"HTTPClient != sender in SearchViewController");
#endif
		[HTTPClient release];
		HTTPClient = nil;
}

- (void)HTTPClientDidFail:(KCHTTPClient *)sender error:(NSError *)error {
	[results release];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OfflineSearch"]) {
		results = [[[WHArticleCache sharedCache] findArticlesWithQuery:searchField.text] copy];
	} else {
		results = [[NSArray alloc] init];
		
		WHSearchNetworkAlertView *alertView = [[WHSearchNetworkAlertView alloc] initWithError:error];
		[alertView show];
		[alertView release];
	}
	
	[self.tableView reloadData];
	noMatchesLabel.hidden = !([results count] == 0);
	
#ifdef DEBUG	
	NSAssert(HTTPClient == sender, @"HTTPClient != sender in SearchViewController");
#endif
	[HTTPClient release];
	HTTPClient = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	CGRect searchFieldContainerFrame = self.navigationItem.titleView.frame;
	searchFieldContainerFrame.size.width = 260.0;
	self.navigationItem.titleView.frame = searchFieldContainerFrame;
	searchField.frame = CGRectMake(-23, 0, 307, 32);
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	if ([results count] == 0 && searchField.text.length != 0) {
		[self updateResults];
	}
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if ([standardUserDefaults boolForKey:@"EnableShake"]) {
		shakeIndicatorView.hidden = NO;
		shakeIndicatorView.alpha = 1.0;
		shakeIndicatorView.center = CGPointMake(155, 340);
	} else {
		shakeIndicatorView.hidden = YES;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	CGRect searchFieldContainerFrame = self.navigationItem.titleView.frame;
	searchFieldContainerFrame.size.width = 307.0;
	self.navigationItem.titleView.frame = searchFieldContainerFrame;
	searchField.frame = CGRectMake(0, 0, 307, 32);
	
	if (!shakeIndicatorView.hidden) {
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissShakeIndicator) userInfo:nil repeats:NO];
	}
}

- (void)dismissShakeIndicator {
	[UIView beginAnimations:@"dismissShakeIndicator" context:nil];
	[UIView setAnimationDuration:0.6];
	shakeIndicatorView.alpha = 0.0;
	[UIView commitAnimations];
	[UIView beginAnimations:@"dismissShakeIndicator" context:nil];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationRepeatCount:6];
	[UIView setAnimationRepeatAutoreverses:YES];
	CGPoint shakeIndicatorCenter = shakeIndicatorView.center;
	shakeIndicatorCenter.x += 10.0;
	shakeIndicatorView.center = shakeIndicatorCenter;
	[UIView commitAnimations];
}

- (void)didSelectSuggestion:(NSString *)suggestion {
	searchField.text = suggestion;
	shadeButton.hidden = YES;
	[suggestionViewController.tableView removeFromSuperview];
	[searchField resignFirstResponder];
	[self updateResults];
}

#pragma mark UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	shadeButton.hidden = NO;
	[self.view addSubview:suggestionViewController.tableView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	shadeButton.hidden = YES;
	[suggestionViewController.tableView removeFromSuperview];
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self updateResults];
}

- (void)searchField:(WHSearchField *)searchField textDidChange:(NSString *)searchText {
	[suggestionViewController suggestWithQuery:searchText];
}

#pragma mark UITableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"wikiHowCell";
    
    WHTableViewCell *cell = (WHTableViewCell *)[tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WHTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.title = [(NSDictionary *)[results objectAtIndex:indexPath.row] objectForKey:@"title"];
	
    return cell;
}

#pragma mark UITableView Delegate Methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {KCLog([(NSDictionary *)[results objectAtIndex:indexPath.row] objectForKey:@"identifier"]);
	WHNavigationController *navCtrl = (WHNavigationController *)self.navigationController;
	[navCtrl pushViewControllerWithIdentifier:[(NSDictionary *)[results objectAtIndex:indexPath.row] objectForKey:@"identifier"] animated:YES];
}

@end
