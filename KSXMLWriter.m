//
//  KSXMLWriter.m
//  Sandvox
//
//  Created by Mike on 19/05/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSXMLWriter.h"

#import "NSString+Karelia.h"


@interface KSXMLWriter ()

- (void)writeStringByEscapingXMLEntities:(NSString *)string escapeQuot:(BOOL)escapeQuotes;

#pragma mark Element Primitives

//  <tagName
//  Records the tag using -pushElement:. You must call -writeEndTag or -popElement later.
- (void)openTag:(NSString *)element;

//   attribute="value"
- (void)writeAttribute:(NSString *)attribute
                 value:(NSString *)value;

//  Starts tracking -writeString: calls to see if element is empty
- (void)didStartElement;

//  >
//  Then increases indentation level
- (void)closeStartTag;

//   />
- (void)closeEmptyElementTag;             

- (void)writeEndTag:(NSString *)tagName;    // primitive version that ignores open elements stack

- (BOOL)elementCanBeEmpty:(NSString *)tagName;  // YES for everything in pure XML

@end


#pragma mark -


@implementation KSXMLWriter

#pragma mark Init & Dealloc

- (id)initWithOutputWriter:(id <KSWriter>)output; // designated initializer
{
    [super initWithOutputWriter:output];
    
    _openElements = [[NSMutableArray alloc] init];
    _attributes = [[NSMutableArray alloc] initWithCapacity:2];
    
    return self;
}

- (void)dealloc
{    
    [_openElements release];
    [_attributes release];
    
    [super dealloc];
}

#pragma mark Writer Status

- (void)close;
{
    [self flush];
    [super close];
}

- (void)flush; { }

#pragma mark Document

- (void)startDocument:(NSString *)DTD;  // at present, expect DTD to be complete tag
{
    [self writeString:DTD];
    [self startNewline];
}

#pragma mark Text

- (void)writeText:(NSString *)string;
{
    // Quotes are acceptable characters outside of attribute values
    [self writeStringByEscapingXMLEntities:string escapeQuot:NO];
}

#pragma mark Elements

- (void)writeElement:(NSString *)elementName text:(NSString *)text;
{
    [self startElement:elementName attributes:nil];
    [self writeText:text];
    [self endElement];
}

- (void)startElement:(NSString *)elementName;
{
    [self openTag:elementName];
    [self didStartElement];
}

- (void)addAttribute:(NSString *)attribute value:(NSString *)value; // call before -startElement:
{
    NSParameterAssert(value);
    [_attributes addObject:attribute];
    [_attributes addObject:value];
}

- (void)startElement:(NSString *)elementName attributes:(NSDictionary *)attributes;
{
    for (NSString *aName in attributes)
    {
        NSString *aValue = [attributes objectForKey:aName];
        [self addAttribute:aName value:aValue];
    }
    
    [self startElement:elementName];
}

- (void)endElement;
{
    // Handle whitespace
	[self decreaseIndentationLevel];
    if (![self isWritingInline]) [self startNewline];   // was this element written entirely inline?
    
    
    // Write the tag itself.
    if (_elementIsEmpty)
    {
        [self popElement];  // turn off _elementIsEmpty first or regular start tag will be written!
        [self closeEmptyElementTag];
    }
    else
    {
        [self writeEndTag:[self topElement]];
        [self popElement];
    }
}

- (void)startNewline;   // writes a newline character and the tabs to match -indentationLevel
{
    [self writeString:@"\n"];
    
    for (int i = 0; i < [self indentationLevel]; i++)
    {
        [self writeString:@"\t"];
    }
}

#pragma mark Comments

- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
{
    [self openComment];
    [self writeStringByEscapingXMLEntities:comment escapeQuot:YES];
    [self closeComment];
}

- (void)openComment;
{
    [self writeString:@"<!--"];
}

- (void)closeComment;
{
    [self writeString:@"-->"];
}

#pragma mark CDATA

- (void)startCDATA;
{
    [self writeString:@"<![CDATA["];
}

- (void)endCDATA;
{
    [self writeString:@"]]>"];
}

#pragma mark Indentation

@synthesize indentationLevel = _indentation;

- (void)increaseIndentationLevel;
{
    [self setIndentationLevel:[self indentationLevel] + 1];
}

- (void)decreaseIndentationLevel;
{
    [self setIndentationLevel:[self indentationLevel] - 1];
}

#pragma mark Elements Stack

- (BOOL)canWriteElementInline:(NSString *)tagName;
{
    // In standard XML, no elements can be inline, unless it's the start of the doc
    return (_inlineWritingLevel == 0);
}

- (NSUInteger)openElementsCount;
{
    return [_openElements count];
}

- (BOOL)hasOpenElementWithTagName:(NSString *)tagName;
{
    // Seek an open element, matching case insensitively
    for (NSString *anElement in _openElements)
    {
        if ([anElement caseInsensitiveCompare:tagName] == NSOrderedSame)
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)topElement;
{
    return [_openElements lastObject];
}

- (void)pushElement:(NSString *)tagName;
{
    [_openElements addObject:tagName];
    [self startWritingInline];
}

- (void)popElement;
{
    _elementIsEmpty = NO;
    
    [_openElements removeLastObject];
    
    // Time to cancel inline writing?
    if (![self isWritingInline]) [self stopWritingInline];
}

#pragma mark Element Primitives

- (void)openTag:(NSString *)element;        //  <tagName
{
    [self openTag:element writeInline:[self canWriteElementInline:element]];
}

- (void)openTag:(NSString *)element writeInline:(BOOL)writeInline;
{
    // Can only write suitable tags inline if containing element also allows it
    if (!writeInline)
    {
        [self startNewline];
        [self stopWritingInline];
    }
    
    element = [element lowercaseString];    // writes coming from the DOM are uppercase
    [self writeString:@"<"];
    [self writeString:element];
    
    // Must do this AFTER writing the string so subclasses can take early action in a -writeString: override
    [self pushElement:element];
    
    
    // Write attributes
    for (int i = 0; i < [_attributes count]; i+=2)
    {
        NSString *attribute = [_attributes objectAtIndex:i];
        NSString *value = [_attributes objectAtIndex:i+1];
        [self writeAttribute:attribute value:value];
    }
    [_attributes removeAllObjects];
}

- (void)writeAttribute:(NSString *)attribute
                 value:(NSString *)value;
{
    [self writeString:@" "];
    [self writeString:attribute];
    [self writeString:@"=\""];
    [self writeStringByEscapingXMLEntities:value escapeQuot:YES];	// make sure to escape the quote mark
    [self writeString:@"\""];
}

- (void)didStartElement;
{
    // For elements which can't be empty, might as well go ahead and close the start tag now
    _elementIsEmpty = [self elementCanBeEmpty:[self topElement]];
    if (!_elementIsEmpty) [self closeStartTag];
}

- (void)closeStartTag;
{
    [self writeString:@">"];
    [self increaseIndentationLevel];
}

- (void)closeEmptyElementTag; { [self writeString:@" />"]; }

- (void)writeEndTag:(NSString *)tagName;    // primitive version that ignores open elements stack
{
    [self writeString:@"</"];
    [self writeString:tagName];
    [self writeString:@">"];
}

- (BOOL)elementCanBeEmpty:(NSString *)tagName; { return YES; }

#pragma mark Inline Writing

/*! How it works:
 *
 *  _inlineWritingLevel records the number of objects in the Elements Stack at the point inline writing began (-startWritingInline).
 *  A value of NSNotFound indicates that we are not writing inline (-stopWritingInline). This MUST be done whenever about to write non-inline content (-openTag: does so automatically).
 *  Finally, if _inlineWritingLevel is 0, this is a special value to indicate we're at the start of the document/section, so the next element to be written is inline, but then normal service shall resume.
 */

- (BOOL)isWritingInline;
{
    return ([self openElementsCount] >= _inlineWritingLevel);
}

- (void)startWritingInline;
{
    // Is it time to switch over to inline writing? (we may already be writing inline, so can ignore request)
    if (_inlineWritingLevel >= NSNotFound || _inlineWritingLevel == 0)
    {
        _inlineWritingLevel = [self openElementsCount];
    }
}

- (void)stopWritingInline; { _inlineWritingLevel = NSNotFound; }

static NSCharacterSet *sCharactersToEntityEscapeWithQuot;
static NSCharacterSet *sCharactersToEntityEscapeWithoutQuot;

+ (void)initialize
{
    // Cache the characters to be escaped. Doing it in +initialize should be threadsafe
	if (!sCharactersToEntityEscapeWithQuot)
    {
        sCharactersToEntityEscapeWithQuot = [[NSCharacterSet characterSetWithCharactersInString:@"&<>\""] retain];
    }
    if (!sCharactersToEntityEscapeWithoutQuot)
    {
        sCharactersToEntityEscapeWithoutQuot = [[NSCharacterSet characterSetWithCharactersInString:@"&<>"] retain];
    }
}

/*!	Escape & < > " ... does NOT escape anything else.  Need to deal with character set in subsequent pass.
 Escaping " so that strings work within HTML tags
 */

// Explicitly escape, or don't escape, double-quots as &quot;
// Within a tag like <foo attribute="%@"> then we have to escape it.
// In just about all other contexts it's OK to NOT escape it, but many contexts we don't know if it's OK or not.
// So I think we want to gradually shift over to being explicit when we know when it's OK or not.
- (void)writeStringByEscapingXMLEntities:(NSString *)string escapeQuot:(BOOL)escapeQuotes;
{
    NSCharacterSet *charactersToEntityEscape = (escapeQuotes ?
                                                sCharactersToEntityEscapeWithQuot :
                                                sCharactersToEntityEscapeWithoutQuot);
    
    // Look for characters to escape. If there are none can bail out quick without having had to allocate anything. #78710
    NSRange searchRange = NSMakeRange(0, [string length]);
    NSRange range = [string rangeOfCharacterFromSet:charactersToEntityEscape options:0 range:searchRange];
    if (range.location == NSNotFound) return [self writeString:string];
    
    
    while (searchRange.length)
	{
        // Write characters not needing to be escaped. Don't bother if there aren't any
		NSRange unescapedRange = searchRange;
        if (range.location != NSNotFound)
        {
            unescapedRange.length = range.location - searchRange.location;
        }
        if (unescapedRange.length)
        {
            [self writeString:[string substringWithRange:unescapedRange]];
        }
        
        
		// Process characters that need escaping
		if (range.location != NSNotFound)
        {            
            NSAssert(range.length == 1, @"trying to escaping non-single character string");    // that's all we should deal with for HTML escaping
			
            unichar ch = [string characterAtIndex:range.location];
            switch (ch)
            {
                case '&':	[self writeString:@"&amp;"];    break;
                case '<':	[self writeString:@"&lt;"];     break;
                case '>':	[self writeString:@"&gt;"];     break;
                case '"':	[self writeString:@"&quot;"];   break;
            }
		}
        else
        {
            break;  // no escapable characters were found so we must be done
        }
        
        
        // Continue the search
        searchRange.location = range.location + range.length;
        searchRange.length = [string length] - searchRange.location;
        range = [string rangeOfCharacterFromSet:charactersToEntityEscape options:0 range:searchRange];
	}	
}

- (void)writeString:(NSString *)string;
{
    // Is this string some element content? If so, the element is no longer empty so must close the tag and mark as such
    if (_elementIsEmpty && [string length])
    {
        _elementIsEmpty = NO;   // comes first to avoid infinte recursion
        [self closeStartTag];
    }
    
    [super writeString:string];
}

@end
