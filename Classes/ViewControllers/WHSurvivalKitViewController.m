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

#import "WHSurvivalKitViewController.h"
#import "WHArticlePreloadedCache.h"
#import "WHNavigationController.h"
#import "WHTableViewCell.h"
#import "NSString+wikiHow.h"

int compareByTitle(NSDictionary *obj1, NSDictionary *obj2, void *context);

@implementation WHSurvivalKitViewController

- (void)_add:(NSDictionary *)article {
	NSString *firstLetter = [[[article objectForKey:@"title"] substringToIndex:1] uppercaseString];
	NSInteger index = [indexNames indexOfObject:firstLetter];
	if (index == NSNotFound) {
		index = [indexes count] - 1;
	}
	NSMutableArray *indexArray = [indexes objectAtIndex:index];
	[indexArray addObject:article];
}

- (void)addArticlesFromArray:(NSArray *)articles {
	NSDictionary *dict;
	for (dict in articles) {
		[self _add:dict];
	}
	NSMutableArray *i;
	for (i in indexes) {
		[i sortUsingFunction:compareByTitle context:nil];
	}
	[self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Survival Kit";
	self.tableView.rowHeight = 80.0;
	indexNames = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
	NSMutableArray *mutableIndexes = [[NSMutableArray alloc] init];
	NSMutableArray *indexArray;
	NSString *indexName;
	for (indexName in indexNames) {
		indexArray = [[NSMutableArray alloc] init];
		[mutableIndexes addObject:indexArray];
		[indexArray release];
	}
	indexes = [[NSArray alloc] initWithArray:mutableIndexes];
	[mutableIndexes release];
	[self addArticlesFromArray:[[WHArticlePreloadedCache sharedPreloadedCache] preloadedArticles]];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [indexNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[indexes objectAtIndex:section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return indexNames;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([[indexes objectAtIndex:section] count] == 0) {
		return nil;
	}
	return [indexNames objectAtIndex:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"wikiHowCell";
    
    WHTableViewCell *cell = (WHTableViewCell *)[tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WHTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSDictionary *article = [[indexes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	cell.isUsingIndex = YES;
    cell.title = [NSString stringWithFormat:@"How to %@", [article objectForKey:@"title"]];
	NSString *identifierTitle = [[article objectForKey:@"identifier"] identifierTitle];
	UIImage *icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", identifierTitle]];
	if (!icon) {
		icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", identifierTitle]];
	}
	if (!icon) {
		icon = [UIImage imageNamed:@"MissingIcon.png"];
	}
	cell.icon = icon;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *article = [[indexes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	WHNavigationController *navCtrl = (WHNavigationController *)self.navigationController;
	[navCtrl pushViewControllerWithIdentifier:[article objectForKey:@"identifier"] animated:YES];
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
    [super dealloc];
}

- (NSString *)identifier {
	return @"SurvivalKit:";
}


@end

int compareByTitle(NSDictionary *obj1, NSDictionary *obj2, void *context) {
    return [[obj1 objectForKey:@"title"] compare:[obj2 objectForKey:@"title"] options:NSForcedOrderingSearch];
}

