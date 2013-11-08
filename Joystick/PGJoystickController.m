//
//  PGJoystickController.m
//  Joystick
//
//  Created by Prachi Gauriar on 3/19/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
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

#import "PGJoystickController.h"

#import "PGPolarCoordinate.h"
#import "PGJoystickView.h"
#import "PGGeometryUtilities.h"

@interface PGJoystickController ()
@property (strong) NSMutableArray *positions;
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
