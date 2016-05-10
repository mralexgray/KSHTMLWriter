// JSONEntity.m VisualJSON Created by youknowone on 11. 12. 12..

#import "JSONEntity.h"


@implementation JSONNode


//- (NSUInteger)document:(VJDocument *)document outlineChildrenCountForItem:(id)item {
//    return [[item keys] count];
//}
//
//- (BOOL)document:(VJDocument *)document outlineIsItemExpandable:(id)item {
//    return [item keys] != nil;
//}
//
//- (NSString *)document:(VJDocument *)document outlineTitleForItem:(id)item {
//    return [item key];
//}
//
//- (NSString *)document:(VJDocument *)document outlineDescriptionForItem:(id)item {
//    return [item outlineDescription];
//}
//
//- (id)document:(VJDocument *)document outlineChild:(NSInteger)index ofItem:(id)item {
//    return [item childAtIndex:index];
//}

#pragma mark - outline delegate for 'tree' view

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {

  return !item ? 1 : ((JSONEntity*)item).keys.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {

  return !item ?: [item keys] != nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {

  return !item ? /* self.data */self :  [item childAtIndex:index];// [self.delegate document:self outlineChild:index ofItem:item];
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tc byItem:(id)item {

    item = item ?: self;//.data;
    NSString *title = [tc.headerCell title];
    return [title isEqualToString:@"node"] ? [item key] :
        //self.delegate document:self outlineTitleForItem:item];
          [title isEqualToString:@"description"] ?
          [item outlineDescription] : // [self.delegate document:self outlineDescriptionForItem:item];
          assert(NO), nil;
}

@end
//- (NSString *)document:(VJDocument *)document prettyTextFromData:(id)data {
//    return data ? [data description] : @"";
//}


@implementation JSONEntity NSDictionary *JSONEntityInitializers = nil;

+ (BOOL) isValid:(NSString*)rawData {

    NSInteger index = 0; unichar chr;
    do {
        if (index >= rawData.length) return NO;
        chr = [rawData characterAtIndex:index];
        index += 1;
    } while ([NSCharacterSet.whitespaceAndNewlineCharacterSet characterIsMember:chr]);
    return chr == '[' || chr == '{';
}

+ entitiyWithFile:(id)path { NSError __unused *error = nil;

  return [self.class entitiyWithData:[NSData dataWithContentsOfFile:path]];
}

+ (instancetype)entitiyWithData:(id)d { NSError *error = nil;

  id obj = [NSJSONSerialization JSONObjectWithData:[d isKindOfClass:NSString.class] ? [(NSString*)d dataUsingEncoding:NSUTF8StringEncoding] : d
                                           options:NSJSONReadingAllowFragments error:&error];
  return [self.class entityWithObject:!error ? obj : @{@"class": error.className, @"code": @(error.code), @"domain": error.domain, @"reason":error.localizedFailureReason}];
}
- initWithObject:(id)object {

	return  [object isKindOfClass:NSDictionary.class] ?   [self initWithDictionary:object] :
          [object isKindOfClass:NSArray.class]      ?   [self      initWithArray:object] :
                                                        [self   initWithTerminal:object];
}

+ entityWithObject:(id)object { return [self.alloc initWithObject:object]; }

- (id)initWithDictionary:(NSDictionary *)object { return (self = super.init) ?

  self.object = object,
  self.keys   = [object.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)],
  self        : nil;
}

- initWithArray:(NSArray*)object { if (!(self = super.init)) return nil;

  _object = object;
  NSMutableArray *keys = NSMutableArray.new;
  for (NSInteger i = 0; i < object.count; i++) [keys addObject:@(i)];
  _keys = keys.copy;
	return self;
}

- initWithTerminal:(id)object {  self = super.init; return self ? _object = object, self : nil; }

- childAtIndex:(NSInteger)index {

	if (!self.keys) return nil;
	if (!self.children) self.children = @{}.mutableCopy;
	id key = self.keys[index];
  return [self.children objectForKey:key] ?: ({ 	JSONEntity *child;

		child = [self.class entityWithObject:  [key isKindOfClass:NSNumber.class]
                                        ?  [self.object objectAtIndex:[key integerValue]]
                                        :  [self.object objectForKey:key]];
		child.parent  = self;
		child.key     = key;
		[self.children setObject:child forKey:key]; child;
	});
}

- (NSString *)outlineDescription {	return

  !self.keys ?
  [self.object isKindOfClass:NSNumber.class] ?
  [self.object jsonRepresentation] :
  [self.object description] :
  [self.object isKindOfClass:NSArray.class] ?
  [NSString stringWithFormat:@"Array(%lu): [%@]", self.keys.count, self.outlineArrayItems] :
  [self.object isKindOfClass:NSDictionary.class] ?
  [NSString stringWithFormat:@"Dict(%lu): {%@}", self.keys.count, self.outlineDictionaryItems] :
  [self.object description];
}

- (NSString *)description {	return [self descriptionWithDepth:0]; }

- (NSString *)descriptionWithDepth:(NSInteger)depth {

	if (!self.object) return @"";
	
	NSMutableString *indent = @"".mutableCopy;
	for (NSInteger i = 0; i < depth; i++) [indent appendString:@"\t"];
	NSString *indent2 = [indent stringByAppendingString:@"\t"];
	NSMutableString *desc = @"".mutableCopy;
	if ([self.object isKindOfClass:NSArray.class]) {
		[desc appendString:@"[\n"];
		for (NSInteger i = 0; i < self.keys.count; i++) {
			[desc appendString:indent2];
			[desc appendString:[[self childAtIndex:i] descriptionWithDepth:depth + 1]];
			[desc appendString:@",\n"];
		}
		NSInteger deleteCount = 1 + (self.keys.count != 0);
		[desc deleteCharactersInRange:NSMakeRange(desc.length - deleteCount, deleteCount)];
		[desc appendFormat:@"\n%@]", indent];
	} else if ([self.object isKindOfClass:NSDictionary.class]) {
		[desc appendString:@"{\n"];
		for (NSInteger i = 0; i < self.keys.count; i++)
			[desc appendFormat:@"%@\"%@\": %@,\n",indent2, [self.keys objectAtIndex:i], [[self childAtIndex:i] descriptionWithDepth:depth + 1]];
		[desc deleteCharactersInRange:NSMakeRange(desc.length-2, 2)];
		[desc appendFormat:@"\n%@}",indent];
	} else if ([self.object isKindOfClass:NSString.class]) {
		[desc appendFormat:@"\%@\"", [self.object stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
	} else
		[desc appendString:[self.object isKindOfClass:NSNumber.class]
                      ?[self.object jsonRepresentation]
                      :[self.object description]];
	return desc;
}

#pragma mark -  OutlineDescription

- (NSString *)outlineItemDescription:(id)item {

	return  [item isKindOfClass:NSArray.class]        ? [NSString stringWithFormat:@"Array(%lu)", [item count]] :
          [item isKindOfClass:NSDictionary.class]   ? [NSString stringWithFormat:@"Dict(%lu)", [[item allKeys] count]] :
          [item isKindOfClass:NSString.class]       ? [NSString stringWithFormat:@"\"%@\"", [item stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]] :
          [item isKindOfClass:NSNumber .class]      ? [item jsonRepresentation] :
                                                      [item description];
}

- (NSString *)outlineArrayItems { NSMutableArray *children = @[].mutableCopy;

  [self.object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[children addObject:[self outlineItemDescription:obj]];
	}];
	return [children componentsJoinedByString:@","]; 
}

- (NSString *)outlineDictionaryItems {
	NSDictionary *item = self.object;
	NSMutableArray *children = [NSMutableArray array];
	for (id key in self.keys) {
		NSString *desc = [self outlineItemDescription:[item objectForKey:key]];
		[children addObject:[NSString stringWithFormat:@"\"%@\":%@", key, desc]];
	}
	return [children componentsJoinedByString:@","]; 
}

@end

@implementation NSNumber (JSONEntity) - (NSString*) jsonRepresentation {

  NSString *defaultDescription = self.description;

  return  [self.className isEqualToString:@"__NSCFBoolean"]
              ? self.boolValue ? @"true" : @"false" :
          [self.className isEqualToString:@"__NSCFNumber"] ?



		(!strcmp(self.objCType, @encode(float)) ||
     !strcmp(self.objCType, @encode(double))) &&
    [defaultDescription rangeOfString:@"."].location != NSNotFound ?
        [defaultDescription stringByAppendingString:@".0"] :
        defaultDescription :
    [self.className isEqualToString:@"__NSCFBoolean"] ?
      self.boolValue ? @"YES" : @"NO" : self.description;
} @end


//@interface JSONEntity ()

// internal data form
//- (id)initWithDictionary:(NSDictionary *)dictionary;
//- (id)initWithArray:(NSArray *)array;
//- (id)initWithTerminal:(id)object;

//! @breif  'Text' view string representation
///- (NSString *)descriptionWithDepth:(NSInteger)depth;

//@end

//! @brief  'Tree' view internal representation
//@interface JSONEntity (OutlineDescription)

//- (NSString *)outlineItemDescription:(id)item;
//- (NSString *)outlineArrayItems;
//- (NSString *)outlineDictionaryItems;

//@end


//@interface NSNumber (JSONEntity)

//- (NSString *)jsonRepresentation;
//
//@end
