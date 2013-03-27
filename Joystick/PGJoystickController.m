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
@property(readwrite, retain) PGPolarCoordinate *position;
@end


@implementation PGJoystickController

- (id)init
{
    self = [super init];
    if (self) {
        self.position = [[PGPolarCoordinate alloc] init];
    }
    
    return self;
}


- (void)awakeFromNib
{
    [_joystickView setMaximumOffset:100];
    [_positionController setContent:_position];
    
    [_joystickView bind:@"angle"
               toObject:_positionController
            withKeyPath:@"selection.theta"
                options:@{ NSValueTransformerNameBindingOption : @"PGRadiansToDegreesValueTransformer" }];
    
    [_joystickView bind:@"offset" toObject:_positionController withKeyPath:@"selection.r" options:nil];
}


@end
