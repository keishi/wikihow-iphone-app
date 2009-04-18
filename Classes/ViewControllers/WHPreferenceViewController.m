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

#import "WHPreferenceViewController.h"
#import "WHMultiValuePreferenceViewController.h"
#import "WHToggleSwitchPreference.h"
#import "WHAboutViewController.h"
#import "WHTipsViewController.h"


@implementation WHPreferenceViewController

- (void)loadView {
	[super loadView];
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	preferences = [[NSMutableArray alloc] init];
	NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
	self.title = [settingsDict objectForKey:@"Title"];
	NSArray * preferenceSpecifiers = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	NSDictionary *preferenceSpecifier;
	for (preferenceSpecifier in preferenceSpecifiers) {
		NSString *preferenceSpecifierType = [preferenceSpecifier objectForKey:@"Type"];
		if ([preferenceSpecifierType isEqualToString:@"PSMultiValueSpecifier"]) {
			WHMultiValuePreferenceViewController *multiValuePreferenceViewController = [[WHMultiValuePreferenceViewController alloc] initWithSpecifier:preferenceSpecifier];
			[preferences addObject:multiValuePreferenceViewController];
			[multiValuePreferenceViewController release];
		} else if ([preferenceSpecifierType isEqualToString:@"PSToggleSwitchSpecifier"]) {
			WHToggleSwitchPreference *toggleSwitchPreference = [[WHToggleSwitchPreference alloc] initWithSpecifier:preferenceSpecifier];
			[preferences addObject:toggleSwitchPreference];
			[toggleSwitchPreference release];
			if ([toggleSwitchPreference.key isEqualToString:@"EnableShake"]) {
				[toggleSwitchPreference.toggleSwitch addTarget:self action:@selector(enableShakeDidChange:) forControlEvents:UIControlEventValueChanged];
			}
		}
	}
	[settingsDict release];
}

- (void)enableShakeDidChange:(UISwitch *)sender {
	UIAppDelegate.isShakeEnabled = sender.on;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section)
	{
		case 0:
			return [preferences count];
		case 1:
			return 2;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section)
	{
		case 0:
			return @"Settings";
		case 1:
			return nil;//@"Tips";
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			return [[preferences objectAtIndex:indexPath.row] cell];
			break;
		case 1:
			{
				static NSString *CellIdentifier = @"wikiHowAboutCell";
				
				UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				}
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				if (indexPath.row == 0) {
					cell.text = @"About wikiHow App";
				} else {
					cell.text = @"wikiHow Tips";
				}
				return cell;
			}
			break;
	}
	return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		id pref = [preferences objectAtIndex:indexPath.row];
		if ([pref class] == [WHMultiValuePreferenceViewController class]) {
			[self.navigationController pushViewController:pref animated:YES];
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			WHAboutViewController *aboutViewController = [[WHAboutViewController alloc] initWithStyle:UITableViewStyleGrouped];
			[self.navigationController pushViewController:aboutViewController animated:YES];
		} else if (indexPath.row == 1) {
			[UIAppDelegate showTips];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

- (void)dealloc {
	[preferences release];
    [super dealloc];
}

- (NSString *)identifier {
	return @"Settings:";
}


@end

