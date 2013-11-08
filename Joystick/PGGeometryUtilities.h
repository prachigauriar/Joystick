//
//  PGGeometryUtilities.h
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

/*!
 @header PGGeometryUtilities
 @abstract Defines useful functions and classes for working with geometrical objects.
 @discussion The utility functions easily convert between radians and degrees. Value transformers
     are provided for converting between radians and degrees, converting between an angle and
     a circular slider value, and converting from an NSPoint to a string.
 @author Prachi Gauriar
 */

#import <Foundation/Foundation.h>

#pragma mark Conversion Functions

/*!
 @abstract Converts the specified angle from radians to degrees.
 @param angle The angle in radians.
 @result The angle in degrees.
 */
extern double PGConvertRadiansToDegrees(double angle);

/*!
 @abstract Converts the specified angle from degrees to radians.
 @param angle The angle in degrees.
 @result The input angle in radians.
 */
extern double PGConvertDegreesToRadians(double angle);


#pragma mark - Value Transformers

/*!
 @abstract A value transformer for converting angles between radians and degrees.
 @discussion PGRadiansToDegreesValueTransformers transform object values whose double values
     are in radians into NSNumbers in degrees. Values must respond to -doubleValue (with a
     double, obviously). The transformer supports reverse transformation.
 */
@interface PGRadiansToDegreesValueTransformer : NSValueTransformer
@end


/*!
 @abstract A value transformer for converting angles into circular NSSlider values.
 @discussion Circular NSSliders start with their initial value at 12 o'clock and increase 
     clockwise. Conventionally, angles start with 0 radians (0°) at 3 o'clock and increase
     counter-clockwise to 2π (360°). PGCircularSliderAngleValueTransformers transform object
     values so that they map appropriately onto a circular slider whose minimum value is 0
     and whose maximum value is 360. Object values can be in either radians or degrees.
 */
@interface PGCircularSliderAngleValueTransformer : NSValueTransformer

/*!
 @abstract Whether the instance expects object values in degrees.
 */
@property(readonly, assign) BOOL usesDegrees;

/*!
 @abstract Returns an initialized PGCircularSliderAngleValueTransformer that does not use degrees. 
 @result An initialized PGCircularSliderAngleValueTransformer.
 */
- (id)init;

/*!
 @abstract Returns an initialized PGCircularSliderAngleValueTransformer.
 @param usesDegrees Whether the returned transformed should use degrees.
 @result An initialized PGCircularSliderAngleValueTransformer.
 */
- (id)initUsingDegrees:(BOOL)usesDegrees;

@end


/*!
 @abstract The name with which the PGCircularSliderAngleValueTransformer that uses degrees
     is registered.
 @discussion Registration occurs in the class's initialize method and can be manually triggered
     by invoking [PGCircularSliderAngleValueTransformer self]. The value for this string is simply
     @"PGDegreesToCircularSliderAngleValueTransformer". Note that the value transformer that does
     not use degrees is accessible using the name @"PGCircularSliderAngleValueTransformer", as it
     is the default transformer returned by -init.
 */
extern NSString *const PGDegreesToCircularSliderAngleValueTransformerName;


/*!
 @abstract A value transformer for converting NSPoints to strings.
 @discussion PGPointToStringValueTransformer transforms NSPoints (wrapped in NSValues) into
     NSStrings. Values must respond to -pointValue with an NSPoint. The transformer does not
     support reverse transformation.
 */
@interface PGPointToStringValueTransformer : NSValueTransformer

/*!
 @abstract The number formatter to use when formatting individual coordinates.
 @discussion If nil, the default number formatter (returned by +defaultNumberFormatter) will be
     used.
 */
@property(readwrite, retain) NSNumberFormatter *numberFormatter;

/*!
 @abstract Returns the default number formatter used by PGPointToStringValueTransformer instances.
 @discussion This number formatter is simply the default number formatter for the user's locale,
     but displays at most one fractional digit.
 @result The default number formatter.
 */
+ (NSNumberFormatter *)defaultNumberFormatter;

@end


#pragma mark - Categories

/*!
 @abstract The PointComparator category to NSValue adds a comparator method for comparing point 
     values.
 */
@interface NSValue (PointComparator)

/*!
 @abstract Compares the point value of the receiver to that of another NSValue instance.
 @discussion The point comparison is done by simply comparing the X coordinates of each point
     and then, if those are equal, the Y coordinates of each point. This is admittedly a weak
     method of comparison.
 @param other The other NSValue instance to which to compare the receiver.
 @result Returns NSOrderedAscending if the receiver’s X coordinate is less than other’s or if
     their X coordinates are the same, but the receiver’s Y coordinate is less than other’s. 
     Returns NSOrderedSame if the two points have the same X and Y coordinates. Returns 
     NSOrderedDescending otherwise.
 */
- (NSComparisonResult)compareToPoint:(NSValue *)other;

@end
