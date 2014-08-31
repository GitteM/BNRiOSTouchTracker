//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by Brigitte Michau on 2014/08/30.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRDrawView.h"
#import "BNRLine.h"

@interface BNRDrawView ()

@property (strong, nonatomic) NSMutableDictionary *linesInProgress;
@property (strong, nonatomic) NSMutableArray *finishedLines;

@end

@implementation BNRDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc]init];
        self.finishedLines = [[NSMutableArray alloc]init];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
    }
    return self;
}

- (void)strokeLine:(BNRLine *)line {
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)drawRect:(CGRect)rect {
    // Draw finised lines in black
    [[UIColor blackColor]set];

    for (BNRLine *line in self.finishedLines) {
        [self strokeLine:line];
    }
    
    for (NSValue *key in self.linesInProgress) {
        [self strokeLine:self.linesInProgress[key]];
    }
    
}

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

@end
