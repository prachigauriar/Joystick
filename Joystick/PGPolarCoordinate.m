//
//  PGPolarCoordinate.m
//  Joystick
//
//  Created by Prachi Gauriar on 3/13/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "PGPolarCoordinate.h"

@implementation PGPolarCoordinate

- (id)init
{
    return [self initWithR:0 theta:0];
}


- (id)initWithR:(double)r theta:(double)theta
{
    self = [super init];
    if (self) {
        _r = r;
        _theta = theta;
    }
    
    return self;
}


+ (NSSet *)keyPathsForValuesAffectingCartesianPoint
{
    return [NSSet setWithObjects:@"r", @"theta", nil];
}


- (NSPoint)cartesianPoint
{
    return NSMakePoint(_r * cos(_theta), _r * sin(_theta));
}

@end
