//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by Brigitte Michau on 2014/08/30.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRDrawView.h"
#import "BNRLine.h"
#import "BNRCircle.h"

@interface BNRDrawView ()

@property (strong, nonatomic) NSMutableDictionary *linesInProgress;
@property (strong, nonatomic) NSMutableArray *finishedLines;

@property (strong, nonatomic) NSMutableDictionary *boundingBox;
@property (strong, nonatomic) NSMutableArray *finishedCircle;

@end

@implementation BNRDrawView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc]init];
        self.finishedLines = [[NSMutableArray alloc]init];
        
        self.boundingBox = [[NSMutableDictionary alloc]init];
        self.finishedCircle = [[NSMutableArray alloc]init];
        
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

- (void)strokeCircle:(BNRCircle *)circle {
    
    CGRect rect = CGRectZero;
    
    if (circle.pointOne.x < circle.pointTwo.x) {
        rect.origin.x = circle.pointOne.x;
        rect.size.width = fabsf(circle.pointTwo.x - circle.pointOne.x);
    } else {
        rect.origin.x = circle.pointTwo.x;
        rect.size.width = fabsf(circle.pointOne.x - circle.pointTwo.x);
    }
    
    if (circle.pointOne.y < circle.pointTwo.y) {
        rect.origin.y = circle.pointOne.y;
        rect.size.height = fabsf(circle.pointTwo.y - circle.pointOne.y);
    } else {
        rect.origin.y = circle.pointTwo.y;
        rect.size.height = fabsf(circle.pointOne.y - circle.pointTwo.y);
    }
    
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:rect];
    bp.lineWidth = 8;
    
    [bp stroke];
}

- (void)drawRect:(CGRect)rect {

    [[UIColor blackColor]set];
    
    for (BNRLine *line in self.finishedLines) {
        [self strokeLine:line];
    }
    
    for (NSValue *key in self.linesInProgress) {
        [self strokeLine:self.linesInProgress[key]];
    }
    
    for (BNRCircle *circle in self.finishedCircle) {
        [self strokeCircle:circle];
    }
    
    for (NSValue *key in self.boundingBox) {
        [self strokeCircle:self.boundingBox[key]];
    }
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
    
    if (touches.count == 1) {
        
        for (UITouch *t in touches) {
            CGPoint location = [t locationInView:self];
            
            BNRLine *line = [[BNRLine alloc]init];
            line.begin = location;
            line.end = location;
            
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            self.linesInProgress[key] = line;
        }
        
    } else {
        
        BNRCircle *circle = [BNRCircle new];
        int i = 0;
        
        for (UITouch *t in touches) {
            CGPoint location = [t locationInView:self];
            
            i++;
            if (i == 1) {
                circle.pointOne = location;
            } else {
                circle.pointTwo = location;
            }
            
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            self.boundingBox[key] = circle;
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event {
    
    if (touches.count == 1) {
        
        for (UITouch *t in touches) {
            
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            BNRLine *line = self.linesInProgress[key];
            
            line.end = [t locationInView:self];
        }
        
    } else {
        
        int i = 0;
        for (UITouch *t in touches) {
            
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            BNRCircle *circle = self.boundingBox[key];
            
            i++;
            if (i == 1) {
                circle.pointOne = [t locationInView:self];
            } else {
                circle.pointTwo = [t locationInView:self];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event {
    
    if (touches.count == 1) {
        
        for (UITouch *t in touches) {
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            
            BNRLine *line = self.linesInProgress[key];
            
            [self.finishedLines addObject:line];
            [self.linesInProgress removeObjectForKey:key];
        }
        
    } else {
        
        BNRCircle *circle;
        NSValue *key;
        int i = 0;
        
        for (UITouch *t in touches) {
            
            key = [NSValue valueWithNonretainedObject:t];
            
            i++;
            if (i == 1) {
                circle = self.boundingBox[key];
            } else {
                circle = self.boundingBox[key];
            }
            
        }
        [self.finishedCircle addObject:circle];
        [self.boundingBox removeObjectForKey:key];
        
    }
    [self setNeedsDisplay];
}

@end
