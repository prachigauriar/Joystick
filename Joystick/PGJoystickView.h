//
//  PGJoystickView.h
//  Joystick
//
//  Created by Prachi Gauriar on 3/13/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGJoystickView : NSView

@property(readwrite, assign, nonatomic) double angle;
@property(readwrite, assign, nonatomic) double offset;
@property(readwrite, assign, nonatomic) double maximumOffset;

@end
