//
//  PGGeometryUtilities.m
//
//  Created by Prachi Gauriar on 3/17/2013.
//  Copyright (c) 2013 Prachi Gauriar.
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

#import "PGGeometryUtilities.h"

#pragma mark Constants

NSString *const PGDegreesToCircularSliderAngleValueTransformerName = @"PGDegreesToCircularSliderAngleValueTransformer";


#pragma mark - Functions

double PGConvertRadiansToDegrees(double angle)
{
    return angle * 180 / M_PI;
}


double PGConvertDegreesToRadians(double angle)
{
    return angle * M_PI / 180;
}


static inline double PGConvertAngleSlider(double angle)
{
    angle = fmod(90 - angle, 360);
    return (angle >= 0) ? angle : angle + 360;
}


#pragma mark - PGRadiansToDegreesValueTransformer

@implementation PGRadiansToDegreesValueTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}


+ (BOOL)allowsReverseTransformation
{
    return YES;
}


- (id)transformedValue:(id)value
{
    if (!value) return nil;
    return @(PGConvertRadiansToDegrees([value doubleValue]));
}


- (id)reverseTransformedValue:(id)value
{
    if (!value) return nil;
    return @(PGConvertDegreesToRadians([value doubleValue]));
}


@end


#pragma mark - PGCircularSliderAngleValueTransformer

@implementation PGCircularSliderAngleValueTransformer

+ (void)initialize
{
    if (self != [PGCircularSliderAngleValueTransformer class]) return;
    [NSValueTransformer setValueTransformer:[[PGCircularSliderAngleValueTransformer alloc] initUsingDegrees:YES]
                                    forName:PGDegreesToCircularSliderAngleValueTransformerName];
}


- (id)init
{
    return [self initUsingDegrees:NO];
}

- (id)initUsingDegrees:(BOOL)usesDegrees
{
    self = [super init];
    if (self) {
        _usesDegrees = usesDegrees;
    }
    
    return self;
}


+ (Class)transformedValueClass
{
    return [NSNumber class];
}


+ (BOOL)allowsReverseTransformation
{
    return YES;
}


- (id)transformedValue:(id)value
{
    if (!value) return nil;
    double angle = _usesDegrees ? [value doubleValue] : PGConvertRadiansToDegrees([value doubleValue]);
    return @(PGConvertAngleSlider(angle));
}


- (id)reverseTransformedValue:(id)value
{
    if (!value) return nil;
    double angle = PGConvertAngleSlider([value doubleValue]);
    return @(_usesDegrees ? angle : PGConvertDegreesToRadians(angle));
}

@end


#pragma mark - PGPointToStringValueTransformer

@implementation PGPointToStringValueTransformer

+ (NSNumberFormatter *)defaultNumberFormatter
{
    NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        formatter.maximumFractionDigits = 1;
    }
    
    return formatter;
}


+ (Class)transformedValueClass
{
    return [NSString class];
}


+ (BOOL)allowsReverseTransformation
{
    return NO;
}


- (id)transformedValue:(id)value
{
    if (!value) return nil;
    NSPoint point = [value pointValue];
    NSNumberFormatter *formatter = _numberFormatter ? _numberFormatter : [PGPointToStringValueTransformer defaultNumberFormatter];
    return [NSString stringWithFormat:@"(%@, %@)", [formatter stringFromNumber:@(point.x)], [formatter stringFromNumber:@(point.y)]];
}

@end


#pragma mark - Categories

@implementation NSValue (PointComparator)

- (NSComparisonResult)compareToPoint:(NSValue *)otherPoint
{
    NSPoint p1 = self.pointValue;
    NSPoint p2 = otherPoint.pointValue;
    
    if (p1.x < p2.x) return NSOrderedAscending;
    if (p1.x > p2.x) return NSOrderedDescending;
    if (p1.y < p2.y) return NSOrderedAscending;
    if (p1.y > p2.y) return NSOrderedDescending;
    return NSOrderedSame;
}

@end
