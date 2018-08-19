//
//  RSAddTextViewLayoutManager.m
//  RealSocial
//
//  Created by Kira on 2018/6/20.
//  Copyright © 2018 scnukuncai. All rights reserved.
//

#import "RSAddTextViewLayoutManager.h"
static CGFloat R = 8.f;
static CGFloat LINE_WIDTH = 2.f;
@interface RSAddTextViewLayoutManager() {
    NSInteger maxIndex;
    CGFloat offsetY;
    CGFloat extendWidth;
}
@property (nonatomic, strong) NSArray * pointArray;
@property (nonatomic, strong) UIBezierPath *path;;
@property (nonatomic, strong) NSMutableArray *rectArray;


@end

@implementation RSAddTextViewLayoutManager

//-(void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
//{
//    NSRange range = [self characterRangeForGlyphRange:glyphsToShow
//                                     actualGlyphRange:NULL];
//    [self.textStorage enumerateAttribute:@"LSYSecretAttribute" inRange:range options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
//        if ([value isEqualToString:@"secretAttribute"]) {
//            NSRange glyphRange = [self glyphRangeForCharacterRange:range
//                                              actualCharacterRange:NULL];
//            NSTextContainer *
//            container = [self textContainerForGlyphAtIndex:glyphRange.location
//                                            effectiveRange:NULL];
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            CGContextSaveGState(context);   //保存当前的绘图配置信息
//            CGContextTranslateCTM(context, origin.x, origin.y); //转换初始坐标系到绘制字形的位置
//            [[UIColor blackColor] setFill];
//            CGRect rect = [self boundingRectForGlyphRange:glyphRange inTextContainer:container];
//            [self drawSecret:rect]; //开始绘制
//            CGContextRestoreGState(context); //恢复绘图配置信息
//        }
//        else
//        {
//            [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
//        }
//
//    }];
//}

- (void)setContext:(CGContextRef)context ifClear:(BOOL)isClear {
    if (isClear) {
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor clearColor] setStroke];
    } else {
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        if (self.useColor) {
            [self.useColor setFill];
            [self.useColor setStroke];
        } else {
            [[UIColor blackColor] setFill];
            [[UIColor whiteColor] setStroke];
        }
    }
}

-(void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    
    NSRange range = [self characterRangeForGlyphRange:glyphsToShow
                                     actualGlyphRange:NULL];
    NSRange glyphRange = [self glyphRangeForCharacterRange:range
                                      actualCharacterRange:NULL];
    
//    NSLog(@"sqmTest:first : %f last : %f", firstPosition, lastPosition);
//    NSLog(@"sqmTest:rect: %f,%f, %f,%f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);   //保存当前的绘图配置信息
    CGContextTranslateCTM(context, origin.x, origin.y); //转换初始坐标系到绘制字形的位置
    [self setContext:context ifClear:NO];
    self.path = nil;
    [self.rectArray removeAllObjects];
    [self enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        
        CGRect newRect = CGRectMake(usedRect.origin.x - extendWidth, usedRect.origin.y + offsetY, usedRect.size.width + extendWidth * 2, usedRect.size.height);
        NSValue *value = [NSValue valueWithCGRect:newRect];
        [self.rectArray addObject:value];
    }];
    [self preProccess];
    if (self.type == RSAddTextBackGroundTypeSolid) {
        for (int i = 0; i < self.rectArray.count; i ++) {
            NSValue *curValue = [self.rectArray objectAtIndex:i];
            CGRect cur = curValue.CGRectValue;
            R = cur.size.height * 0.18;
            [self.path appendPath:[UIBezierPath bezierPathWithRoundedRect:cur cornerRadius:R]];
            CGRect last = CGRectNull;
            if (i > 0) {
                NSValue *lastValue = [self.rectArray objectAtIndex:i-1];
                last = lastValue.CGRectValue;
                CGPoint a = cur.origin;
                CGPoint b = CGPointMake(CGRectGetMaxX(cur), cur.origin.y);
                CGPoint c = CGPointMake(last.origin.x, CGRectGetMaxY(last));
                CGPoint d = CGPointMake(CGRectGetMaxX(last), CGRectGetMaxY(last));
                
                if (a.x - c.x >= 2*R) {
                    //Draw
                    //                CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 0 , 0, 1.0);
                    //                CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
                    UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(a.x - R, a.y + R) radius:R startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
                    
                    [addPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(a.x + R, a.y + R) radius:R startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES]];
                    [addPath addLineToPoint:CGPointMake(a.x - R, a.y)];
                    [self.path appendPath:addPath];
                    //Remove
                    
                }
                if (a.x == c.x) {
                    //Draw
                    [self.path moveToPoint:CGPointMake(a.x, a.y - R)];
                    [self.path addLineToPoint:CGPointMake(a.x, a.y + R)];
                    [self.path addArcWithCenter:CGPointMake(a.x + R, a.y + R) radius:R startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
                    [self.path addArcWithCenter:CGPointMake(a.x + R, a.y - R) radius:R startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
                    //Remove
                }
                if (d.x - b.x >= 2*R) {
                    //Draw
                    UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(b.x + R, b.y + R) radius:R startAngle:M_PI_2 * 3 endAngle:M_PI clockwise:NO];
                    [addPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(b.x - R, b.y + R) radius:R startAngle:0 endAngle:3 * M_PI_2 clockwise:NO]];
                    [addPath addLineToPoint:CGPointMake(b.x + R, b.y)];
                    [self.path appendPath:addPath];
                    //Remove
                    
                }
                if (d.x == b.x) {
                    //Draw
                    [self.path moveToPoint:CGPointMake(b.x, b.y - R)];
                    [self.path addLineToPoint:CGPointMake(b.x, b.y + R)];
                    [self.path addArcWithCenter:CGPointMake(b.x - R, b.y + R) radius:R startAngle:0 endAngle:M_PI_2 * 3 clockwise:NO];
                    [self.path addArcWithCenter:CGPointMake(b.x - R, b.y - R) radius:R startAngle:M_PI_2 endAngle:0 clockwise:NO];
                    //Remove
                }
                if (c.x - a.x >= 2*R) {
                    //Draw
                    UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x - R, c.y - R) radius:R startAngle:M_PI_2 endAngle:0 clockwise:NO];
                    [addPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x + R, c.y - R) radius:R startAngle:M_PI endAngle:M_PI_2 clockwise:NO]];
                    [addPath addLineToPoint:CGPointMake(c.x - R, c.y)];
                    [self.path appendPath:addPath];
                    //Remove
                }
                if (b.x - d.x >= 2*R) {
                    //Draw
                    UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(d.x + R, d.y - R) radius:R startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
                    [addPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(d.x - R, d.y - R) radius:R startAngle:0 endAngle:M_PI_2 clockwise:YES]];
                    [addPath addLineToPoint:CGPointMake(d.x + R, d.y)];
                    [self.path appendPath:addPath];
                    //Remove
                }
            }
        }
        [self.path stroke];
        [self.path fill];
    }
    if (self.type == RSAddTextBackGroundTypeBorder) {
        for (int i = 0; i < self.rectArray.count; i ++) {
            NSValue *curValue = [self.rectArray objectAtIndex:i];
            CGRect cur = curValue.CGRectValue;
            R = cur.size.height * 0.18;
            LINE_WIDTH = R * 0.25;
            [self setContext:context ifClear:NO];
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:cur cornerRadius:R];
            [path setLineWidth:LINE_WIDTH];
            [path stroke];

            CGRect last = CGRectNull;
            if (i > 0) {
                NSValue *lastValue = [self.rectArray objectAtIndex:i-1];
                last = lastValue.CGRectValue;
                CGPoint a = cur.origin;
                CGPoint b = CGPointMake(CGRectGetMaxX(cur), cur.origin.y);
                CGPoint c = CGPointMake(last.origin.x, CGRectGetMaxY(last));
                CGPoint d = CGPointMake(CGRectGetMaxX(last), CGRectGetMaxY(last));
                CGFloat centerX = ((a.x > c.x? a.x : c.x) + (b.x > d.x? d.x : b.x)) / 2.f;
                
                if (a.x - c.x >= 2*R) {
                    [self setContext:context ifClear:YES];
                    UIBezierPath * clearPath = [UIBezierPath bezierPath];
                    [clearPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(a.x + R, a.y + R) radius:R startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES]];
                    [clearPath addLineToPoint:CGPointMake(centerX + 1, a.y)];
                    [clearPath addLineToPoint:CGPointMake(a.x - R, a.y)];
                    [clearPath setLineWidth:LINE_WIDTH * 1.25];
                    [clearPath stroke];
                    
                    [self setContext:context ifClear:NO];
                    UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(a.x - R, a.y + R) radius:R startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
                    [addPath setLineWidth:LINE_WIDTH];
                    [addPath setLineCapStyle:kCGLineCapRound];
                    [addPath stroke];
                }
                if (a.x == c.x) {
                    [self setContext:context ifClear:YES];
                    UIBezierPath * clearPath = [UIBezierPath bezierPath];
                    [clearPath addArcWithCenter:CGPointMake(a.x + R, a.y + R) radius:R startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
                    [clearPath addLineToPoint:CGPointMake(centerX + 1, a.y)];
                    [clearPath addArcWithCenter:CGPointMake(a.x + R, a.y - R) radius:R startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
                    [clearPath setLineWidth:LINE_WIDTH * 1.25];
                    [clearPath stroke];
                    
                    [self setContext:context ifClear:NO];
                    UIBezierPath * addPath = [UIBezierPath bezierPath];
                    [addPath moveToPoint:CGPointMake(a.x, a.y - R)];
                    [addPath addLineToPoint:CGPointMake(a.x, a.y + R)];
                    [addPath setLineWidth:LINE_WIDTH];
                    [addPath setLineCapStyle:kCGLineCapRound];
                    [addPath stroke];
                }
                if (d.x - b.x >= 2*R) {
                    
                    [self setContext:context ifClear:YES];
                    UIBezierPath * clearPath = [UIBezierPath bezierPath];
                    [clearPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(b.x - R, b.y + R) radius:R startAngle:0 endAngle:3 * M_PI_2 clockwise:NO]];
                    [clearPath addLineToPoint:CGPointMake(centerX - 1, b.y)];
                    [clearPath addLineToPoint:CGPointMake(b.x + R, b.y)];
                    [clearPath setLineWidth:LINE_WIDTH * 1.25];
                    [clearPath stroke];
                    
                    [self setContext:context ifClear:NO];
                    UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(b.x + R, b.y + R) radius:R startAngle:M_PI_2 * 3 endAngle:M_PI clockwise:NO];
                    [addPath setLineWidth:LINE_WIDTH];
                    [addPath setLineCapStyle:kCGLineCapRound];
                    [addPath stroke];
                }
                if (d.x == b.x) {
                    
                    [self setContext:context ifClear:YES];
                    UIBezierPath * clearPath = [UIBezierPath bezierPath];
                    [clearPath addArcWithCenter:CGPointMake(b.x - R, b.y + R) radius:R startAngle:0 endAngle:M_PI_2 * 3 clockwise:NO];
                    [clearPath addLineToPoint:CGPointMake(centerX - 1, a.y)];
                    [clearPath addArcWithCenter:CGPointMake(b.x - R, b.y - R) radius:R startAngle:M_PI_2 endAngle:0 clockwise:NO];
                    [clearPath setLineWidth:LINE_WIDTH * 1.25];
                    [clearPath stroke];
                    
                    [self setContext:context ifClear:NO];
                    UIBezierPath * addPath = [UIBezierPath bezierPath];
                    [addPath moveToPoint:CGPointMake(b.x, b.y - R)];
                    [addPath addLineToPoint:CGPointMake(b.x, b.y + R)];
                    [addPath setLineWidth:LINE_WIDTH];
                    [addPath setLineCapStyle:kCGLineCapRound];
                    [addPath stroke];
                }
                if (c.x - a.x >= 2*R) {
                    [self setContext:context ifClear:YES];
                    UIBezierPath * clearPath = [UIBezierPath bezierPath];
                    [clearPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x + R, c.y - R) radius:R startAngle:M_PI endAngle:M_PI_2 clockwise:NO]];
                    [clearPath addLineToPoint:CGPointMake(centerX + 1, c.y)];
                    [clearPath addLineToPoint:CGPointMake(c.x - R, c.y)];
                    [clearPath setLineWidth:LINE_WIDTH * 1.25];
                    [clearPath stroke];
                    
                    [self setContext:context ifClear:NO];
                    UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x - R, c.y - R) radius:R startAngle:M_PI_2 endAngle:0 clockwise:NO];
                    [addPath setLineWidth:LINE_WIDTH];
                    [addPath setLineCapStyle:kCGLineCapRound];
                    [addPath stroke];
                }
                if (b.x - d.x >= 2*R) {
                    [self setContext:context ifClear:YES];
                    UIBezierPath * clearPath = [UIBezierPath bezierPath];
                    [clearPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(d.x - R, d.y - R) radius:R startAngle:0 endAngle:M_PI_2 clockwise:YES]];
                    [clearPath addLineToPoint:CGPointMake(centerX - 1, d.y)];
                    [clearPath addLineToPoint:CGPointMake(d.x + R, d.y)];
                    [clearPath setLineWidth:LINE_WIDTH * 1.25];
                    [clearPath stroke];
                    
                    [self setContext:context ifClear:NO];
                    UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(d.x + R, d.y - R) radius:R startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
                    [addPath setLineWidth:LINE_WIDTH];
                    [addPath setLineCapStyle:kCGLineCapRound];
                    [addPath stroke];
                }
            }
        }
    }
    CGContextRestoreGState(context); //恢复绘图配置信息
}

- (UIBezierPath *)path {
    if (!_path) {
        _path = [UIBezierPath bezierPath];
    }
    return _path;
}

- (NSMutableArray *)rectArray {
    if (!_rectArray) {
        _rectArray = @[].mutableCopy;
    }
    return _rectArray;
}

- (void)preProccess {
    maxIndex = 0;
    if (self.rectArray.count < 2) {
        return;
    }
    for (int i = 1; i < self.rectArray.count; i++) {
        maxIndex = i;
        [self processRectIndex:i];
    }
}

- (void)processRectIndex:(int) index {
    if (self.rectArray.count < 2 || index < 1 || index > maxIndex) {
        return;
    }
    NSValue *value1 = [self.rectArray objectAtIndex:index - 1];
    NSValue *value2 = [self.rectArray objectAtIndex:index];
    CGRect last = value1.CGRectValue;
    CGRect cur = value2.CGRectValue;
    R = cur.size.height * 0.18;
    
    //if t1 == true 改变cur的rect
    BOOL t1 = ((cur.origin.x - last.origin.x < 2 * R) && (cur.origin.x > last.origin.x)) || ((CGRectGetMaxX(cur) - CGRectGetMaxX(last) > -2 * R) && (CGRectGetMaxX(cur) < CGRectGetMaxX(last)));
    //if t2 == true 改变last的rect
    BOOL t2 = ((last.origin.x - cur.origin.x < 2 * R) && (last.origin.x > cur.origin.x)) || ((CGRectGetMaxX(last) - CGRectGetMaxX(cur) > -2 * R) && (CGRectGetMaxX(last) < CGRectGetMaxX(cur)));
    
    if (t2) {
        //将last的rect替换为cur的rect
        CGRect newRect = CGRectMake(cur.origin.x, last.origin.y, cur.size.width, last.size.height);
        NSValue *newValue = [NSValue valueWithCGRect:newRect];
        [self.rectArray replaceObjectAtIndex:index - 1 withObject:newValue];
        [self processRectIndex:index - 1];
    }
    if (t1) {
        //将cur的rect替换为last的rect
        CGRect newRect = CGRectMake(last.origin.x, cur.origin.y, last.size.width, cur.size.height);
        NSValue *newValue = [NSValue valueWithCGRect:newRect];
        [self.rectArray replaceObjectAtIndex:index withObject:newValue];
        [self processRectIndex:index + 1];
    }
    return;
}

- (void) A {
//    NSLog(@"sqmsqm: LastRect:(%f, %f),(%f,%f)",lastRect.origin.x,lastRect.origin.y,lastRect.size.width,lastRect.size.height);
//    NSLog(@"sqmsqm: CurrentRect:(%f, %f),(%f,%f)",usedRect.origin.x,usedRect.origin.y,usedRect.size.width,usedRect.size.height);
//
//    [self.path appendPath:[UIBezierPath bezierPathWithRoundedRect:usedRect cornerRadius:8.f]];
//    if (!CGRectIsEmpty(lastRect)) {
//        if (CGRectContainsPoint(lastRect, CGPointMake(usedRect.origin.x, floor(usedRect.origin.y)))) {
//            //A1
//            [self.path moveToPoint:CGPointMake(usedRect.origin.x - 8.f, usedRect.origin.y)];
//            [self.path addArcWithCenter:CGPointMake(usedRect.origin.x - 8.f, usedRect.origin.y + 8.f) radius:8.f startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
//        }
//        if (CGRectContainsPoint(lastRect, CGPointMake(usedRect.origin.x + usedRect.size.width, floor(usedRect.origin.y)))) {
//            //A2
//        }
//        if (CGRectContainsPoint(usedRect, CGPointMake(lastRect.origin.x, ceil(lastRect.origin.y + lastRect.size.height)))) {
//            //B1
//        }
//        if (CGRectContainsPoint(usedRect, CGPointMake(lastRect.origin.x + lastRect.size.width, ceil(lastRect.origin.y + lastRect.size.height)))) {
//            //B2
//        }
//    }
//    lastRect = usedRect;
}
//-(void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
//{
//    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
//    NSRange range = [self characterRangeForGlyphRange:glyphsToShow
//                                     actualGlyphRange:NULL];
//    NSRange glyphRange = [self glyphRangeForCharacterRange:range
//                                      actualCharacterRange:NULL];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);   //保存当前的绘图配置信息
//    CGContextTranslateCTM(context, origin.x, origin.y); //转换初始坐标系到绘制字形的位置
//    [[UIColor blackColor] setFill];
//    CGRect rect = [self boundingRectForGlyphRange:glyphRange inTextContainer:[self textContainerForGlyphAtIndex:glyphRange.location
//                                                                                                 effectiveRange:NULL]];
//    [self drawSecret:rect]; //开始绘制
//    CGContextRestoreGState(context); //恢复绘图配置信息
//}

-(void)drawSecret:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:8.f];
    [path fill];
}

//- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin
//{
//    NSLog(@"sqmTest:under: range.location: %lu, range.length: %lu,lineRect: (%f, %f),(%f, %f) \n lineGlyphRange.location: %lu, lineGlyphRange.length: %lu, containerOrigin:(%f,%f)",(unsigned long)glyphRange.location,glyphRange.length,lineRect.origin.x, lineRect.origin.y, lineRect.size.width, lineRect.size.height, lineGlyphRange.location, lineGlyphRange.length,containerOrigin.x,containerOrigin.y);
//    // Left border (== position) of first underlined glyph
//    CGFloat firstPosition = [self locationForGlyphAtIndex: glyphRange.location].x;
//
//    // Right border (== position + width) of last underlined glyph
//    CGFloat lastPosition;
//
//    // When link is not the last text in line, just use the location of the next glyph
//    if (NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange)) {
//        lastPosition = [self locationForGlyphAtIndex: NSMaxRange(glyphRange)].x;
//    }
//    // Otherwise get the end of the actually used rect
//    else {
//        lastPosition = [self lineFragmentUsedRectForGlyphAtIndex:NSMaxRange(glyphRange)-1 effectiveRange:NULL].size.width;
//    }
//
//    // Inset line fragment to underlined area
//    lineRect.origin.x += firstPosition;
//    lineRect.size.width = lastPosition - firstPosition;
//
//    // Offset line by container origin
//    lineRect.origin.x += containerOrigin.x;
//    lineRect.origin.y += containerOrigin.y;
//
//    // Align line to pixel boundaries, passed rects may be
//    lineRect = CGRectInset(CGRectIntegral(lineRect), .5, .5);
//
//    [[UIColor greenColor] set];
//    [[UIBezierPath bezierPathWithRect: lineRect] stroke];
//}

@end
