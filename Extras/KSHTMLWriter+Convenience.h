
#import "KSHTMLWriter.h"

@interface KSHTMLWriter (Convenience)

- (void) writeLink:(NSString*)href attributes:(NSDictionary*)attrs content:(void(^)(void))c;
- (void) writeLink:(NSString*)href attributes:(NSDictionary*)attrs 	 text:(NSString*)text;

- (void) writeElement:(NSString*)name   classes:(NSArray*)classes content:(void(^)(void))c;
- (void) writeElement:(NSString*)name 	 idName:(NSString*)idName content:(void(^)(void))c;
- (void) writeElement:(NSString*)name className:(NSString*)classN content:(void(^)(void))c;

- (void) writeElement:(NSString*)name    idName:(NSString*)idN     	text:(NSString*)t;
- (void) writeElement:(NSString*)name className:(NSString*)cNm	  	text:(NSString*)t;
- (void) writeElement:(NSString*)name  	 idName:(NSString*)idN className:(NSString*)cls text:(NSString*)text;

- (void) writeElementAndClose:(NSString*)name;
- (void) writeElementAndClose:(NSString*)name idName:(NSString*)idN;
- (void) writeElementAndClose:(NSString*)name idName:(NSString*)idN className:(NSString*)cNm;
- (void) writeElementAndClose:(NSString*)name 						          className:(NSString*)cNm;

- (void) writeHorizontalLine;

@end

//
//  KSHTMLWriter+Convenience.h
//
//  Created by Alex Gray
//  Copyright © 2013 Karelia Software
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
