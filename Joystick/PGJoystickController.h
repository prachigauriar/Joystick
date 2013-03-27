//
//  PGJoystickController.h
//  Joystick
//
//  Created by Prachi Gauriar on 3/19/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PGPolarCoordinate, PGJoystickView;

@interface PGJoystickController : NSObject <NSApplicationDelegate>

@property(weak) IBOutlet NSWindow *window;
@property(weak) IBOutlet PGJoystickView *joystickView;
@property(weak) IBOutlet NSObjectController *positionController;

@end
