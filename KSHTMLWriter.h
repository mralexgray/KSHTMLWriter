
#import "KSXMLWriter.h"

extern NSString 	*KSHTMLWriterDocTypeHTML_4_01_Strict,       *KSHTMLWriterDocTypeHTML_4_01_Transitional,
                  *KSHTMLWriterDocTypeHTML_4_01_Frameset,     *KSHTMLWriterDocTypeXHTML_1_0_Strict,
                  *KSHTMLWriterDocTypeXHTML_1_0_Transitional,	*KSHTMLWriterDocTypeXHTML_1_0_Frameset,
                  *KSHTMLWriterDocTypeXHTML_1_1,              *KSHTMLWriterDocTypeHTML_5;


@interface KSHTMLWriter : KSXMLWriter	{
  @private
    BOOL            _isXHTML;
    NSString        *_docType;
    NSMutableSet    *_IDs;
    NSMutableArray  *_classNames;
}

typedef void (^VBlk)(void);

#define NEWWRITER(WRITER,STRINGVAR) \
NSMutableString* STRINGVAR = NSMutableString.new; KSHTMLWriter *WRITER = [KSHTMLWriter newWriter:STRINGVAR]

#define KSWRITE(X) [KSHTMLWriter.newWriter writeHTMLString:X]

+ (instancetype) newWriter:(id<KSWriter>)o;

#pragma mark Creating an HTML Writer
// if you desperately need to set a dtype b4 calling -startDocument:isXHTML: (perhaps because you're not going to call it!)
- (id)initWithOutputWriter:(id <KSWriter>)output docType:(NSString*)docType encoding:(NSStringEncoding)encoding;

#pragma mark DTD
@property(nonatomic, copy, readonly) NSString *docType; // Default is HTML5

// Whether empty elements should be written as <FOO> or <FOO />
// Default is YES. There's no setter method; instead, specify with -startDocumentWithDocType:encoding: or when initializing.
@property (readonly) BOOL isXHTML;
+ (BOOL) isDocTypeXHTML:(NSString*)docType;

#pragma mark CSS Class Name
// Class names are accumulated and written automatically as an attribute of the next element started
// You can also push a class name using -pushAttribute:value: if attribute is 'class'
- (void)  pushClassName:(NSString*)className;
- (void) pushClassNames:(NSArray*)classNames;
- (void)      pushClass:(id)classOrArray;

#pragma mark HTML Fragments
/*! Any newlines in the HTML will be adjusted to account for current indentation level, but that's all
    Terminating newline character will be added or removed if needed, as according to terminatingNewline argument */
- (void) writeHTMLString:(NSString*)html withTerminatingNewline:(BOOL)termNL;
- (void) writeHTMLString:(NSString*)html;

#pragma mark General

/*!  <tagName id="idName" class="className">  Pretty standard convenience methods */
- (void) startElement:(NSString*)tagName                       className:(NSString*)c;
- (void) startElement:(NSString*)tagName idName:(NSString*)idN className:(NSString*)c;
- (void) writeElement:(NSString*)name    idName:(NSString*)idN className:(NSString*)c content:(VBlk)c;

- (BOOL)    isIDValid:(NSString*)anID; // NO if the ID has already been used

#pragma mark Document
/*! Convenience to give you standard document structure. head is optional */
- (void) writeDocumentOfType:(NSString*)dType encoding:(NSStringEncoding)e
                        head:(VBlk)headBlock      body:(VBlk)bodyBlock;
#pragma mark Line Break

- (void) writeLineBreak; // <br />   OR  <br> - depends on isXHTML

#pragma mark Links
//  <a href="...." target="..." rel="nofollow">
- (void) writeAnchorElementWithHref:(NSString*)href
                              title:(NSString*)titString
                             target:(NSString*)trgtString
                                rel:(NSString*)relString
                            content:(VBlk)c; // a block must provided - an empty anchor doesn't make sense!

#pragma mark Images
//  <img src="..." alt="..." width="..." height="..." />
- (void) writeImageWithSrc:(NSString*)src
                      alt:(NSString*)alt
                    width:(id)width
                   height:(id)height;

#pragma mark - <link> Goes in <head> to link to scripts, CSS, etc.
- (void) writeLinkWithHref:(NSString*)href
                      type:(NSString*)type
                       rel:(NSString*)rel
                     title:(NSString*)title
                     media:(NSString*)media;

// Note: If a title is set, it is considered an *alternate* stylesheet. http://www.alistapart.com/articles/alternate/
- (void) writeLinkToStylesheet:(NSString*)href
                         title:(NSString*)title
                         media:(NSString*)media;
#pragma mark Scripts

- (void)     writeJavascriptWithSrc:(NSString*)src encoding:(NSStringEncoding)encoding;
- (void)     writeJavascriptWithSrc:(NSString*)src  charset:(NSString*)charset;
- (void)            writeJavascript:(NSString*)scr useCDATA:(BOOL)useCDATA;
- (void) writeJavascriptWithContent:(VBlk)content;

// Like -startCDATA and -endCDATA, but wrapped in a javascript comment so don't risk tripping up a browser's interpreter
- (void) startJavascriptCDATA;
- (void)   endJavascriptCDATA;

#pragma mark Param

- (void) writeParamElementWithName:(NSString*)name value:(NSString*)value;

#pragma mark Style
- (void) writeStyleElementWithCSSString:(NSString*)css;
- (void)     startStyleElementWithType:(NSString*)type;


#pragma mark Lists
@property (readonly) BOOL hasListOpen, topElementIsList;

+ (BOOL) elementIsList:(NSString*)element;

#pragma mark Element Primitives

//   />    OR    >   ...   Which is used depends on -isXHTML
- (void) closeEmptyElementTag;             


@end


#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
// CSS
#import "KSCSSWriter.h"
// DOM
#import "KSXMLWriterDOMAdaptor.h"
// XML
#import "KSXMLAttributes.h"
//#import "KSXMLWriter.h"
#import "KSStringXMLEntityEscaping.h"
// HTML
//#import "KSHTMLWriter.h"
#import "KSHTMLWriter+Convenience.h"

// KSWriter
#import "KSBlockWriter.h"
#import "KSBufferedWriter.h"
#import "KSForwardingWriter.h"
#import "KSMutableDataWriter.h"
#import "KSOutputStreamWriter.h"
#import "KSStringWriter.h"
#import "KSWriter.h"


//
//  KSHTMLWriter.h
//
//  Created by Mike Abdullah
//  Copyright © 2010 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
