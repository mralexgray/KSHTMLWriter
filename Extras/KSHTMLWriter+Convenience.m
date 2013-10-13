
//  KSHTMLWriter+AddedConvenience.m

#import "KSHTMLWriter+Convenience.h"

@implementation KSHTMLWriter (Convenience)

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

- (void) writeElement:(NSString*)name 	  idName:(NSString*)idName className:(NSString*)className text:(NSString*)text {

	[self startElement:name idName:idName className:className];	text ? [self writeCharacters:text] : nil;	[self endElement];
}
- (void) writeElement:(NSString*)name 	  idName:(NSString*)idName 								  		 text:(NSString*)text {

	[self writeElement:name idName:idName className:nil text:text];
}
- (void) writeElement:(NSString*)name className:(NSString*)className 					      	  	 text:(NSString*)text {

	[self writeElement:name idName:nil className:className text:text];
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
