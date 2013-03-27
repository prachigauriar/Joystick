//
//  PGJoystickView.m
//  Joystick
//
//  Created by Prachi Gauriar on 3/13/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "PGJoystickView.h"
#import "PGGeometryUtilities.h"

#pragma mark Constants

static const double PGJoystickViewCrosshairsHalfWidth = 7.5;


#pragma mark - Private Interface

@interface PGJoystickView ()

@property(readwrite, retain) NSBezierPath *crosshairsPath;
@property(readwrite, retain) NSShadow *shadowCrosshairs;

- (NSSize)cartesianOffset;
- (void)setCartesianOffset:(NSSize)cartesianOffset;

- (void)updatePositionForMouseEvent:(NSEvent *)event;

@end


#pragma mark - Implementation

@implementation PGJoystickView

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _angle = 315;
        _offset = 20;
        _maximumOffset = 25;
        
        // Setup our cached crosshairs path
        self.crosshairsPath = [NSBezierPath bezierPath];
        [_crosshairsPath moveToPoint:NSMakePoint(-PGJoystickViewCrosshairsHalfWidth, 0)];
        [_crosshairsPath lineToPoint:NSMakePoint(PGJoystickViewCrosshairsHalfWidth, 0)];
        [_crosshairsPath moveToPoint:NSMakePoint(0, -PGJoystickViewCrosshairsHalfWidth)];
        [_crosshairsPath lineToPoint:NSMakePoint(0, PGJoystickViewCrosshairsHalfWidth)];
        [_crosshairsPath setLineWidth:2.0];

        self.shadowCrosshairs = [[NSShadow alloc] init];
        [_shadowCrosshairs setShadowBlurRadius:2.0];
        [_shadowCrosshairs setShadowColor:[NSColor grayColor]];
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    
    // Draw the background
    [[NSColor controlBackgroundColor] set];
    [NSBezierPath fillRect:bounds];
    [[NSColor controlShadowColor] setFill];
    NSFrameRect(bounds);
    
    // Translate the origin to the center of our view
    NSAffineTransform *originTranslation = [[NSAffineTransform alloc] init];
    [originTranslation translateXBy:NSMidX(bounds) yBy:NSMidY(bounds)];
    [originTranslation concat];
    
    // Put our shadow crosshairs in the right spot and set it
    [_shadowCrosshairs setShadowOffset:[self cartesianOffset]];
    [_shadowCrosshairs set];

    [[NSColor blackColor] set];
    [_crosshairsPath stroke];
}


- (BOOL)isOpaque
{
    return YES;
}


- (BOOL)acceptsFirstResponder
{
    return YES;
}


#pragma mark - Accessors

- (NSSize)cartesianOffset
{
    double angleInRadians = PGConvertDegreesToRadians(_angle);
    return NSMakeSize(_offset * cos(angleInRadians), _offset * sin(angleInRadians));
}


- (void)setCartesianOffset:(NSSize)cartesianOffset
{
    self.offset = hypot(cartesianOffset.width, cartesianOffset.height);
    self.angle = PGConvertRadiansToDegrees(atan2(cartesianOffset.height, cartesianOffset.width));
}


- (void)setAngle:(double)angle
{
    angle = fmod(angle, 360);
    if (angle < 0) angle += 360;
    if (angle == _angle) return;
    _angle = angle;
    [self setNeedsDisplay:YES];
}


- (void)setOffset:(double)offset
{
    offset = fmin(fabs(offset), _maximumOffset);
    if (offset == _offset) return;
    _offset = offset;
    [self setNeedsDisplay:YES];
}


- (void)setMaximumOffset:(double)maximumOffset
{
    _maximumOffset = fabs(maximumOffset);
    [self setOffset:_offset];
}


#pragma mark - Event Handling

- (void)updatePositionForMouseEvent:(NSEvent *)event
{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    NSRect bounds = [self bounds];
    [self setCartesianOffset:NSMakeSize(point.x - NSMidX(bounds), point.y - NSMidY(bounds))];
}


- (void)mouseDown:(NSEvent *)event
{
    [self updatePositionForMouseEvent:event];
}


- (void)mouseDragged:(NSEvent *)event
{
    [self updatePositionForMouseEvent:event];
}


- (void)mouseUp:(NSEvent *)event
{
    [self updatePositionForMouseEvent:event];
}


- (void)keyDown:(NSEvent *)event
{
    NSString *characters = [event charactersIgnoringModifiers];
    unichar key = [characters characterAtIndex:0];
    
    NSSize cartesianOffset = [self cartesianOffset];
    switch (key) {
        case NSUpArrowFunctionKey:
            cartesianOffset.height += 1;
            break;
        case NSDownArrowFunctionKey:
            cartesianOffset.height -= 1;
            break;
        case NSRightArrowFunctionKey:
            cartesianOffset.width += 1;
            break;
        case NSLeftArrowFunctionKey:
            cartesianOffset.width -= 1;
            break;
        case '0':
            cartesianOffset.height = cartesianOffset.width = 0;
            break;
        default:
            [super keyDown:event];
            return;
    }
    
    [self setCartesianOffset:cartesianOffset];
}

@end
