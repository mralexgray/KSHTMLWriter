//
//  JsonElement.h
//  VisualJSON
//
//  Created by youknowone on 11. 12. 12..
//  Copyright (c) 2011 youknowone.org. All rights reserved.
//

@import AppKit;

//@class JSONDocument;
//@protocol JSONDocumentDelegate <NSObject>
//- (NSUInteger)document:(VJDocument *)document outlineChildrenCountForItem:(id)item;
//- (BOOL)document:(VJDocument *)document outlineIsItemExpandable:(id)item;
//- (NSString *)document:(VJDocument *)document outlineTitleForItem:(id)item;
//- (NSString *)document:(VJDocument *)document outlineDescriptionForItem:(id)item;
//- (id)document:(VJDocument *)document outlineChild:(NSInteger)index ofItem:(id)item;
//
//@end

/*!
	@brief  JSON data to representation converter
	
	JsonElement get parsed NSArray or NSDictionary data as JSON data.
	JsonElement provides representation for data for each view type.
 */


@interface JSONEntity : NSObject

@property (weak)   JSONEntity * parent;
@property (strong)                  id   object;
@property (strong)           NSString * key;
@property (strong)            NSArray * keys;
@property (strong) NSMutableDictionary * children;

- (NSString*)  outlineDescription;

- childAtIndex:(NSInteger)i;
- initWithObject:(id)o;
+ entityWithObject:(id)o;
+ entitiyWithData:(NSData*)d;
+ entitiyWithFile:(id)path;

@end

typedef JSONEntity JSONE;

@interface JSONNode : NSObject <NSOutlineViewDataSource> @end

@interface  NSNumber (JSONEntity) @property (readonly) NSString* jsonRepresentation;
@end