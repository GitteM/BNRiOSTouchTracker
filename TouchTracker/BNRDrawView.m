//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by Brigitte Michau on 2014/08/30.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRDrawView.h"
#import "BNRLine.h"
#import "BNRLineStore.h"
#import <math.h>

@interface BNRDrawView ()

@property (strong, nonatomic) NSMutableDictionary *linesInProgress;
@property (strong, nonatomic) NSMutableArray *finishedLines;

@end

@implementation BNRDrawView

#pragma mark - Initialize

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc]init];
        self.finishedLines = [[NSMutableArray alloc]init];
        if ([[[BNRLineStore sharedStore]allLines]count] > 0) {
                [self.finishedLines addObjectsFromArray:[[BNRLineStore sharedStore]allLines]];
        }
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
    }
    return self;
}

#pragma mark - Draw lines

- (UIColor *)colorOfLine:(BNRLine *)line {
    
    double deltaY = line.end.y - line.begin.y;
    double deltaX = line.end.x - line.begin.x;
    
    double angleInDegrees = atan2(deltaY, deltaX) * 180 / M_PI;
    
    double threeSixty;
    if (angleInDegrees < 0) {
        threeSixty = 360 + angleInDegrees;
    } else {
        threeSixty = angleInDegrees;
    }
    
    UIColor *lineColor = [UIColor colorWithHue:threeSixty/360
                                    saturation:1
                                    brightness:1
                                         alpha:1];
    return lineColor;
}

- (void)strokeLine:(BNRLine *)line {
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    UIColor *lineColor = [self colorOfLine:line];
    [lineColor setStroke];
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)drawRect:(CGRect)rect {
    
    for (BNRLine *line in self.finishedLines) {
        [self strokeLine:line];
        [[BNRLineStore sharedStore]addLine:line];
    }
    
    for (NSValue *key in self.linesInProgress) {
        [self strokeLine:self.linesInProgress[key]];
    }
}

#pragma mark - UIResponder methods

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
    
    // Put a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        
        CGPoint location = [t locationInView:self];
        
        BNRLine *line = [[BNRLine alloc]init];
        line.begin = location;
        line.end = location;
        
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.linesInProgress[key] = line;
        
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event {
    
    // Let's put a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        BNRLine *line = self.linesInProgress[key];
        
        line.end = [t locationInView:self];
    }
    
    [self setNeedsDisplay];
    
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event {
    
    // Let's put a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        BNRLine *line = self.linesInProgress[key];
        
        [self.finishedLines addObject:line];
        
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}


- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event {
    
    // let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

@end
