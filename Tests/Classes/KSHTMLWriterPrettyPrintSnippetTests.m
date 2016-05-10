//
//  KSHTMLWriterPrettyPrintSnippetTests.m
//  KSHTMLWriterPrettyPrintSnippetTests
//
//  Created by Sam Deane on 24/02/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriterSnippetTests.h"

#import "KSHTMLWriter.h"
#import "KSStringWriter.h"
#import "KSXMLWriterDOMAdaptor.h"

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>

@interface KSHTMLWriterPrettyPrintSnippetTests : KSHTMLWriterSnippetTests

@end

@implementation KSHTMLWriterPrettyPrintSnippetTests

+ (NSString*)snippetsPath
{
    return @"Snippets/Pretty";
}

- (void) testPrettyPrintSnippetsWithWriterClass:(Class)klass
{
    NSURL* snippetURL = self.parameterisedTestDataItem;
    
    NSError* error = nil;
    NSString* inputHTML = [NSString stringWithContentsOfURL:[snippetURL URLByAppendingPathComponent:@"input.html"] encoding:NSUTF8StringEncoding error:&error];
    NSString* outputHTML = [NSString stringWithContentsOfURL:[snippetURL URLByAppendingPathComponent:@"output.html"] encoding:NSUTF8StringEncoding error:&error];
    
    WebView* view = [self webViewWithStubPage];
    DOMDocument* document = view.mainFrame.DOMDocument;
    DOMHTMLElement* element = (DOMHTMLElement*) [document getElementById:@"content"];
    
    [element setInnerHTML:inputHTML];
    
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSHTMLWriter* writer = [[klass alloc] initWithOutputWriter:output];
    KSXMLWriterDOMAdaptor* adaptor = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer options:KSXMLWriterDOMAdaptorPrettyPrint];
    
    [adaptor writeInnerOfDOMNode:element];
    
    NSString* written = [output string];
    [self assertString:written matchesString:outputHTML];
}

- (void) parameterisedTestWritingSnippetWithHTMLWriterPretty
{
    [self testPrettyPrintSnippetsWithWriterClass:[KSHTMLWriter class]];
}


@end