//
//  PGJoystickView.m
//  Joystick
//
//  Created by Prachi Gauriar on 3/13/2013.
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

#import "PGJoystickView.h"
#import "PGGeometryUtilities.h"

#pragma mark Constants

static const double PGJoystickViewCrosshairsWidth = 15.0;
static const double PGJoystickViewCrosshairsHalfWidth = PGJoystickViewCrosshairsWidth / 2;
static const double PGJoystickViewShadowCrosshairsBlurRadius = 2.0;

static NSString *const PGJoystickViewAngleBindingName = @"angle";
static NSString *const PGJoystickViewOffsetBindingName = @"offset";
static NSString *const PGJoystickViewMaximumOffsetBindingName = @"maximumOffset";


#pragma mark - Private Interface

@interface PGJoystickView ()

@property (strong, nonatomic) NSBezierPath *crosshairsPath;
@property (strong, nonatomic) NSShadow *shadowCrosshairs;

- (void)drawDisabledInRect:(NSRect)dirtyRect;

- (void)setAngle:(double)angle invalidatingRects:(BOOL)shouldInvalidateRects;
- (void)setOffset:(double)offset invalidatingRects:(BOOL)shouldInvalidateRects;

// Bindings
+ (NSSet *)bindingsNames;
+ (void *)contextForBinding:(NSString *)binding;

- (NSValueTransformer *)valueTransformerForBinding:(NSString *)binding;

- (void)updateObservedObjectForBinding:(NSString *)binding;

// Accessors
- (BOOL)isDisplayable;

- (NSRect)shadowCrosshairsRect;

- (NSSize)cartesianOffset;
- (void)setCartesianOffset:(NSSize)cartesianOffset;

- (void)updatePositionForMouseEvent:(NSEvent *)event;

@end


#pragma mark - Implementation

@implementation PGJoystickView {
    NSMutableDictionary *_bindingsMarkers;
}

+ (void)initialize
{
    if (self != [PGJoystickView class]) return;
    
    for (NSString *binding in [self bindingsNames]) {
        [self exposeBinding:binding];
    }
}


- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _angle = 315;
        _offset = 20;
        _maximumOffset = 25;
        
        NSUInteger bindingsCount = [[PGJoystickView bindingsNames] count];
        _bindingsInfo = [[NSMutableDictionary alloc] initWithCapacity:bindingsCount];
        _bindingsMarkers = [[NSMutableDictionary alloc] initWithCapacity:bindingsCount];
        
        // Setup our cached crosshairs path
        self.crosshairsPath = [NSBezierPath bezierPath];
        [_crosshairsPath moveToPoint:NSMakePoint(-PGJoystickViewCrosshairsHalfWidth, 0)];
        [_crosshairsPath lineToPoint:NSMakePoint(PGJoystickViewCrosshairsHalfWidth, 0)];
        [_crosshairsPath moveToPoint:NSMakePoint(0, -PGJoystickViewCrosshairsHalfWidth)];
        [_crosshairsPath lineToPoint:NSMakePoint(0, PGJoystickViewCrosshairsHalfWidth)];
        _crosshairsPath.lineWidth = 2.0;

        self.shadowCrosshairs = [[NSShadow alloc] init];
        _shadowCrosshairs.shadowBlurRadius = PGJoystickViewShadowCrosshairsBlurRadius;
        _shadowCrosshairs.shadowColor = [NSColor grayColor];
    }
    
    return self;
}


- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
    if (newSuperview) return;
    
    for (NSString *binding in [PGJoystickView bindingsNames]) {
        [self unbind:binding];
    }
}


- (void)drawRect:(NSRect)dirtyRect
{
    // If not displayable, draw disabled in rect
    if (!self.isDisplayable) {
        [self drawDisabledInRect:dirtyRect];
        return;
    }
    
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
    [self.shadowCrosshairs setShadowOffset:self.cartesianOffset];
    [self.shadowCrosshairs set];

    [[NSColor blackColor] set];
    [self.crosshairsPath stroke];
}


- (void)drawDisabledInRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    [[NSColor disabledControlTextColor] set];
    [NSBezierPath fillRect:bounds];
    [[NSColor controlShadowColor] setFill];
    NSFrameRect(bounds);
}


- (NSRect)shadowCrosshairsRect
{
    NSRect bounds = self.bounds;
    NSSize offset = self.cartesianOffset;
    
    return NSMakeRect(NSMidX(bounds) + offset.width - PGJoystickViewCrosshairsHalfWidth - PGJoystickViewShadowCrosshairsBlurRadius,
                      NSMidY(bounds) + offset.height - PGJoystickViewCrosshairsHalfWidth - PGJoystickViewShadowCrosshairsBlurRadius,
                      PGJoystickViewCrosshairsWidth + 2 * PGJoystickViewShadowCrosshairsBlurRadius,
                      PGJoystickViewCrosshairsWidth + 2 * PGJoystickViewShadowCrosshairsBlurRadius);
}


- (BOOL)isOpaque
{
    return YES;
}


- (BOOL)acceptsFirstResponder
{
    return YES;
}


#pragma mark - Bindings

+ (NSSet *)bindingsNames
{
    static NSSet *names = nil;
    if (!names) {
        names = [NSSet setWithObjects:PGJoystickViewAngleBindingName, PGJoystickViewOffsetBindingName, PGJoystickViewMaximumOffsetBindingName, nil];
    }
    
    return names;
}


+ (void *)contextForBinding:(NSString *)binding
{
    return (__bridge void *)[[self bindingsNames] member:binding];
}


- (NSDictionary *)infoForBinding:(NSString *)binding
{
    return [[PGJoystickView bindingsNames] containsObject:binding] ? [_bindingsInfo objectForKey:binding] : [super infoForBinding:binding];
}


- (NSValueTransformer *)valueTransformerForBinding:(NSString *)binding
{
    NSDictionary *options = _bindingsInfo[binding][NSOptionsKey];
    if (!options) return nil;
    
    // Try to get a value transformer instance first
    id transformer = options[NSValueTransformerBindingOption];
    if (transformer && transformer != [NSNull null]) return transformer;
    
    // Else, try to get the value transformer by name
    id name = options[NSValueTransformerNameBindingOption];
    return (name && name != [NSNull null]) ? [NSValueTransformer valueTransformerForName:name] : nil;
}


- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    // If context is null, the binding is not ours, so hand it off to our superclass
    void *context = [PGJoystickView contextForBinding:binding];
    if (!context) {
        [super bind:binding toObject:observable withKeyPath:keyPath options:options];
        return;
    }
    
    // If binding is established, unbind it
    if ([_bindingsInfo objectForKey:binding]) {
        [self unbind:binding];
    }
    
    // Save information about binding in _bindingsInfo
    NSDictionary *bindingInfo = @{ NSObservedObjectKey: observable,
                                   NSObservedKeyPathKey: [keyPath copy],
                                   NSOptionsKey: options ? [options copy] : @{} };
    [_bindingsInfo setObject:bindingInfo forKey:binding];
    
    // Start observing observable's value for keyPath
    [observable addObserver:self
                 forKeyPath:keyPath
                    options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                    context:context];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    // If the context isn't for one of our bindings, pass it to the superclass. Note that we can't simply do set membership,
    // because if the binding is not ours, we can't guarantee it's an object.
    NSString *binding = (__bridge NSString *)context;
    if (binding != PGJoystickViewAngleBindingName && binding != PGJoystickViewOffsetBindingName && binding != PGJoystickViewMaximumOffsetBindingName) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    // Get the new value for the changed object
    id value = change[NSKeyValueChangeNewKey];
    if (!value || value == [NSNull null]) {
        value = [object valueForKeyPath:keyPath];
    }
    
    if (NSIsControllerMarker(value)) {
        // Intentionally don't use accessors to avoid triggering KVO notifications
        if (binding == PGJoystickViewAngleBindingName) {
            _angle = -1;
        } else if (binding == PGJoystickViewOffsetBindingName) {
            _offset = -1;
        }
        
        // If we were displayable before, we need to be redrawn
        BOOL wasDisplayable = self.isDisplayable;
        _bindingsMarkers[binding] = value;
        if (wasDisplayable) {
            [self setNeedsDisplay:YES];
        }
        
        return;
    }
    
    // If we got this far, there shouldn't be a marker value for this binding in our dictionary
    BOOL wasDisplayable = self.isDisplayable;
    [_bindingsMarkers removeObjectForKey:binding];
    
    // If we weren't displayable before, but we're displayable now, redraw the whole view
    if (!wasDisplayable && self.isDisplayable) {
        [self setNeedsDisplay:YES];
    }
    
    // If there's a value transformer for this binding, transform the value
    NSValueTransformer *valueTransformer = [self valueTransformerForBinding:binding];
    if (valueTransformer) {
        value = [valueTransformer transformedValue:value];
    }
    
    // Set the value for the appropriate key    
    [self setValue:value forKey:binding];
}


- (void)unbind:(NSString *)binding
{
    // If context is null, the binding is not ours, so hand it off to our superclass
    void *context = [PGJoystickView contextForBinding:binding];
    if (!context) {
        [super unbind:binding];
        return;
    }
    
    // If there is no binding info, the binding hasn't been established
    NSDictionary *bindingInfo = _bindingsInfo[binding];
    if (!bindingInfo) return;

    // Stop observing the value of the binding's observed object's key path
    id observedObject = bindingInfo[NSObservedObjectKey];
    NSString *observedKeyPath = bindingInfo[NSObservedKeyPathKey];
    [observedObject removeObserver:self forKeyPath:observedKeyPath context:context];
    
    // Remove the binding info from our dictionary
    [_bindingsInfo removeObjectForKey:binding];
    if (_bindingsMarkers[binding]) {
        [_bindingsMarkers removeObjectForKey:binding];
        [self setNilValueForKey:binding];
    }
}


- (void)updateObservedObjectForBinding:(NSString *)binding
{
    // If there is no established binding, we're done
    NSDictionary *bindingInfo = _bindingsInfo[binding];
    if (!bindingInfo) return;
    
    // Get the value to set on the observed object
    id value = [self valueForKey:binding];

    // If there's a value transformer for this binding and it supports reverse transformation, transform the value
    NSValueTransformer *valueTransformer = [self valueTransformerForBinding:binding];
    if (valueTransformer && [[valueTransformer class] allowsReverseTransformation]) {
        value = [valueTransformer reverseTransformedValue:value];
    }
    
    // Update the observed object's value for the observed key path
    id observedObject = bindingInfo[NSObservedObjectKey];
    NSString *observedKeyPath = bindingInfo[NSObservedKeyPathKey];
    [observedObject setValue:value forKeyPath:observedKeyPath];
}


#pragma mark - Accessors

- (BOOL)isDisplayable
{
    return _bindingsMarkers.count == 0;
}


- (NSSize)cartesianOffset
{
    double angleInRadians = PGConvertDegreesToRadians(_angle);
    return NSMakeSize(_offset * cos(angleInRadians), _offset * sin(angleInRadians));
}


- (void)setCartesianOffset:(NSSize)cartesianOffset
{
    [self setNeedsDisplayInRect:self.shadowCrosshairsRect];
    
    double oldOffset = _offset;
    [self setOffset:hypot(cartesianOffset.width, cartesianOffset.height) invalidatingRects:NO];
    if (oldOffset != _offset) {
        [self updateObservedObjectForBinding:PGJoystickViewOffsetBindingName];
    }
    
    double oldAngle = _angle;
    [self setAngle:PGConvertRadiansToDegrees(atan2(cartesianOffset.height, cartesianOffset.width)) invalidatingRects:NO];
    if (oldAngle != _angle) {
        [self updateObservedObjectForBinding:PGJoystickViewAngleBindingName];
    }
    
    [self setNeedsDisplayInRect:self.shadowCrosshairsRect];
}


- (void)setNilValueForKey:(NSString *)key
{
    if (![[PGJoystickView bindingsNames] containsObject:key]) {
        [super setNilValueForKey:key];
        return;
    }
    
    [self setValue:@0 forKey:key];
}


- (void)setAngle:(double)angle invalidatingRects:(BOOL)shouldInvalidateRects
{
    angle = fmod(angle, 360);
    if (angle < 0) angle += 360;
    if (_angle == angle) return;
    if (shouldInvalidateRects) [self setNeedsDisplayInRect:self.shadowCrosshairsRect];
    _angle = angle;
    if (shouldInvalidateRects) [self setNeedsDisplayInRect:self.shadowCrosshairsRect];
}


- (void)setAngle:(double)angle
{
    [self setAngle:angle invalidatingRects:YES];
}


- (void)setOffset:(double)offset invalidatingRects:(BOOL)shouldInvalidateRects
{
    offset = fmin(fabs(offset), _maximumOffset);
    if (offset == _offset) return;
    if (shouldInvalidateRects) [self setNeedsDisplayInRect:self.shadowCrosshairsRect];
    _offset = offset;
    if (shouldInvalidateRects) [self setNeedsDisplayInRect:self.shadowCrosshairsRect];
}


- (void)setOffset:(double)offset
{
    [self setOffset:offset invalidatingRects:YES];
}


- (void)setMaximumOffset:(double)maximumOffset
{
    _maximumOffset = fabs(maximumOffset);
    
    if (_offset > _maximumOffset) {
        self.offset = _offset;
        [self updateObservedObjectForBinding:PGJoystickViewOffsetBindingName];
    }
}


#pragma mark - Event Handling

- (void)updatePositionForMouseEvent:(NSEvent *)event
{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    NSRect bounds = self.bounds;
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
    
    NSSize cartesianOffset = self.cartesianOffset;
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
    
    self.cartesianOffset = cartesianOffset;
}

@end
