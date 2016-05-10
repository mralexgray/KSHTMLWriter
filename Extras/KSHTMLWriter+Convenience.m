
//  KSHTMLWriter+AddedConvenience.m

#import "KSHTMLWriter+Convenience.h"

@implementation KSHTMLWriter (Convenience)

- (void) writeFormat:(NSString*)fmt, ... {   NSString *s;
  va_list list; va_start(list, fmt);
  s = [NSString.alloc initWithFormat:fmt arguments:list];
  va_end(list);
  [self writeString:[s copy]];
}
- (void) writeDocReady:(NSString*)first, ... {

  [self writeJavascriptWithSrc:@"https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" encoding:NSUTF8StringEncoding];
  NSMutableString *pasted = @"".mutableCopy;
  va_list list; va_start(list, first);
  NSString *arg=va_arg(list,NSString*);
  [pasted appendFormat:@"\n%@", arg];
  va_end(list);
   [self writeJavascriptWithContent:^{ [self writeFormat:@"$(function(){\n%@;\n%@ });",first, pasted, nil];
  }];
}
- (void) writeLinkToStylesheets:(NSArray*)sheets {

  [sheets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [self writeLinkToStylesheet:obj];
  }];
}
- (void) writeLinkToStylesheet:(NSString*)href {
  [self writeLinkToStylesheet:href title:nil media:nil];
}
- (void) writeLink:(NSString*)href attributes:(NSDictionary*)attrs content:(void(^)(void))content {

	[attrs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { [self pushAttribute:key value:obj];	}];
	[self pushAttribute:@"href" value:href];
	[self writeElement:@"a" content:content];
}
- (void) writeLink:(NSString*)href attributes:(NSDictionary*)attrs text:(NSString*)text {

	[attrs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { [self pushAttribute:key value:obj];	}];
	[self pushAttribute:@"href" value:href];
	[self writeElement:@"a" text:text];
}

- (void) writeElement:(NSString*)name   classes:(NSArray*)classes 	content:(void(^)(void))content {

	classes ? [self pushClassNames:classes] : nil;	[self writeElement:name content:content];
}
- (void) writeElement:(NSString*)name    idName:(NSString*)idName 	content:(void(^)(void))content {

	[self writeElement:name idName:idName className:nil content:content];
}
- (void) writeElement:(NSString*)name className:(NSString*)className content:(void(^)(void))content {

	className ? [self pushClassName:className] : nil;	[self writeElement:name content:content];
}

- (void) writeElement:(NSString*)name 	 idName:(NSString*)i className:(NSString*)c text:(NSString*)t {

	[self startElement:name idName:i className:c];	t ? [self writeCharacters:t] : nil;	[self endElement];
}
- (void) writeElement:(NSString*)name 	 idName:(NSString*)i 								  		  text:(NSString*)t {

	[self writeElement:name idName:i className:nil text:t];
}
- (void) writeElement:(NSString*)name                        className:(NSString*)c text:(NSString*)t {

	[self writeElement:name idName:nil className:c text:t];
}

- (void) writeElementAndClose:(NSString*)name 																				{

	[self writeElementAndClose:name idName:nil className:nil];
}
- (void) writeElementAndClose:(NSString*)name 	 idName:(NSString*)idName		 									{

	[self writeElementAndClose:name idName:idName className:nil];
}
- (void) writeElementAndClose:(NSString*)name 									  className:(NSString*)className	{

	[self writeElementAndClose:name idName:nil className:className];
}
- (void) writeElementAndClose:(NSString*)name 	 idName:(NSString*)idName className:(NSString*)className {

	idName 		? [self pushAttribute:@"id" value:idName] : nil;
	className	? [self pushClassName:className] 			: nil;

 	[self startElement:name];	[self endElement];
}

- (void) writeHorizontalLine	{	[self startElement:@"hr"];	[self endElement];	}

@end
