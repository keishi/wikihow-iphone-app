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

#import "WHSearchXMLReader.h"
#import "GTMNSString+HTML.h"


@implementation WHSearchXMLReader

- (NSArray *)parseXMLData:(NSData *)XMLData parseError:(NSError **)error {
	_result = [[NSMutableArray alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLData];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	[parser parse];
	NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
    }
	[parser release];
	NSArray *result = [[_result copy] autorelease];
	[_result release];
	_result = nil;
	return result;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if (qName) {
        elementName = qName;
    }
	
	if ([elementName isEqualToString:@"R"]) {
		_article = [[NSMutableDictionary alloc] init];
		_contentOfElement = nil;
	} else if ([elementName isEqualToString:@"UE"]) {
		_contentOfElement = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"T"]) {
		_contentOfElement = [[NSMutableString alloc] init];
	} else {
		_contentOfElement =nil;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (qName) {
		elementName = qName;
	}
	if ([elementName isEqualToString:@"R"]) {
		NSDictionary *articleCopy = [_article copy];
		[_result addObject:articleCopy];
		[articleCopy release];
		[_article release];
		_article = nil;
	} else if ([elementName isEqualToString:@"UE"]) {
		NSString *identifier = [NSString stringWithFormat:@"Article:%@", [[[NSURL URLWithString:_contentOfElement] path] substringFromIndex:1]];
		[_article setObject:identifier forKey:@"identifier"];
		[_contentOfElement release];
		_contentOfElement = nil;
	} else if ([elementName isEqualToString:@"T"]) {
		NSString *title = [_contentOfElement stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
		title = [title stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
		title = [title substringToIndex:[title length] - 10]; // remove " - wikiHow" suffix
		title = [title gtm_stringByUnescapingFromHTML];
		[_article setObject:title forKey:@"title"];
		[_contentOfElement release];
		_contentOfElement = nil;
	} else {
		_contentOfElement =nil;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (_contentOfElement) {
        [_contentOfElement appendString:string];
    }
}

@end
