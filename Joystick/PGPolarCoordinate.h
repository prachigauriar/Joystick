//
//  PGPolarCoordinate.h
//  Joystick
//
//  Created by Prachi Gauriar on 3/13/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGPolarCoordinate : NSObject

@property(readwrite, assign) double r;
@property(readwrite, assign) double theta;

- (id)initWithR:(double)r theta:(double)theta;

- (NSPoint)cartesianPoint;

@end
