//
//  RSAddTextViewTextStorage.m
//  RealSocial
//
//  Created by Kira on 2018/6/20.
//  Copyright © 2018 scnukuncai. All rights reserved.
//

#import "RSAddTextViewTextStorage.h"

@implementation RSAddTextViewTextStorage
{
    NSTextStorage *_imp;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _imp = [NSTextStorage new];
    }
    
    return self;
}


#pragma mark - Reading Text

- (NSString *)string
{
    return _imp.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_imp attributesAtIndex:location effectiveRange:range];
}


#pragma mark - Text Editing

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    // Normal replace
    [self beginEditing];
    [_imp replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
    
//    [self addAttribute:NSUnderlineStyleAttributeName  value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, self.string.length)];
    
//    // Regular expression matching all iWords -- first character i, followed by an uppercase alphabetic character, followed by at least one other character. Matches words like iPod, iPhone, etc.
//    static NSDataDetector *linkDetector;
//    linkDetector = linkDetector ?: [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:NULL];
//
//    // Clear text color of edited range
//    NSRange paragaphRange = [self.string paragraphRangeForRange: NSMakeRange(range.location, str.length)];
//    [self removeAttribute:NSLinkAttributeName range:paragaphRange];
//    [self removeAttribute:NSBackgroundColorAttributeName range:paragaphRange];
//    [self removeAttribute:NSUnderlineStyleAttributeName range:paragaphRange];
//
//    // Find all iWords in range
//    [linkDetector enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//        // Add red highlight color
//        [self addAttribute:NSLinkAttributeName value:result.URL range:result.range];
//        [self addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:result.range];
//        [self addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:result.range];
//    }];
    
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

//-(void)processEditing
//{
//
//    [self setAttributes:@{@"LSYSecretAttribute":@"secretAttribute"} range:NSMakeRange(0, self.string.length)];
//
//    [super processEditing];
//
//}

@end
