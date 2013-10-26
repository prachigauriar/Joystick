//
//  PGJoystickController.m
//  Joystick
//
//  Created by Prachi Gauriar on 3/19/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "PGJoystickController.h"

#import "PGPolarCoordinate.h"
#import "PGJoystickView.h"
#import "PGGeometryUtilities.h"

@interface PGJoystickController ()
@property(readwrite, retain) NSMutableArray *positions;
@end


@implementation PGJoystickController

- (id)init
{
    self = [super init];
    if (self) {
        self.positions = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (void)awakeFromNib
{
    self.joystickView.maximumOffset = 100;
    self.positionController.content = _positions;
    
    [self.joystickView bind:@"angle"
               toObject:self.positionController
            withKeyPath:@"selection.theta"
                options:@{ NSValueTransformerNameBindingOption : @"PGRadiansToDegreesValueTransformer" }];
    
    [self.joystickView bind:@"offset" toObject:self.positionController withKeyPath:@"selection.r" options:nil];
}


- (NSUInteger)countOfPositions
{
    return _positions.count;
}


- (PGPolarCoordinate *)objectInPositionsAtIndex:(NSUInteger)index
{
    return _positions[index];
}


- (void)insertObject:(PGPolarCoordinate *)position inPositionsAtIndex:(NSUInteger)index
{
    [_positions insertObject:position atIndex:index];
}


- (void)removeObjectFromPositionsAtIndex:(NSUInteger)index
{
    [_positions removeObjectAtIndex:index];
}


- (void)replaceObjectInPositionsAtIndex:(NSUInteger)index withObject:(PGPolarCoordinate *)position
{
    _positions[index] = position;
}

@end
