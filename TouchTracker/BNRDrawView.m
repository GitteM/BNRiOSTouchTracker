//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by Brigitte Michau on 2014/08/30.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRDrawView.h"
#import "BNRLine.h"

@interface BNRDrawView () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPanGestureRecognizer *moveRecognizer;
@property (strong, nonatomic) NSMutableDictionary *linesInProgress;
@property (strong, nonatomic) NSMutableArray *finishedLines;

@property (weak, nonatomic) BNRLine *selectedLine;

@end

@implementation BNRDrawView

#pragma mark - Initialize and return a newly allocated view object

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc]init];
        self.finishedLines = [[NSMutableArray alloc]init];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
        
        UITapGestureRecognizer *doubleTapRecognizer =
        [[UITapGestureRecognizer alloc]initWithTarget:self
                                               action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer =
        [[UITapGestureRecognizer alloc]initWithTarget:self
                                               action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *pressRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
        
        self.moveRecognizer =
        [[UIPanGestureRecognizer alloc]initWithTarget:self
                                               action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.moveRecognizer];
        
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Menu Item action message

- (void)deleteLine:(id)sender {
    // remove the selected line from the list of _finishedLines
    [self.finishedLines removeObject:self.selectedLine];
    
    // redraw everything
    [self setNeedsDisplay];
    
}

#pragma mark - Draw the receiver’s image

- (void)strokeLine:(BNRLine *)line {
    
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)drawRect:(CGRect)rect {
    
    [[UIColor blackColor]set];
    for (BNRLine *line in self.finishedLines) {
        [self strokeLine:line];
    }
    
    [[UIColor redColor]set];
    for (NSValue *key in self.linesInProgress) {
        [self strokeLine:self.linesInProgress[key]];
    }
    
    if(self.selectedLine) {
        [[UIColor greenColor]set];
        [self strokeLine:self.selectedLine];
    }
}

#pragma mark - Get a BNRLine close to a given point

- (BNRLine *)lineAtPoint:(CGPoint)p {
    
    // find a line close to p
    for (BNRLine *line in self.finishedLines) {
        CGPoint start = line.begin;
        CGPoint end = line.end;
        
        // check a few points on the line
        for (float t = 0.0; t < 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            // if the tapped point is within 20 points, return the line
            if (hypot(x - p.x, y - p.y) < 20) {
                return line;
            }
        }
    }
    return nil;
}

#pragma mark - Respond to touch events

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
    
    if (self.selectedLine) {
        return;
    }
    
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
    
    if (self.selectedLine) {
        return;
    }
    
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
    
    if (self.selectedLine) {
        return;
    }
    
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

#pragma mark - Gesture Recognizer Methods

- (void)doubleTap:(UIGestureRecognizer *)gr {
    
    NSLog(@"Recognized double tap");
    
    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)tap:(UIGestureRecognizer *)gr {
    
    NSLog(@"Recognized tap");
    
    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    
    if (self.selectedLine) {
        
        // make ourselves the target of menu item action messages
        [self becomeFirstResponder];
        
        // grab the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        // create a new "Delete" UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc]initWithTitle:@"Delete"
                                                           action:@selector(deleteLine:)];
        
        menu.menuItems = @[deleteItem];
        
        // tell the menu where it should come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2)
                     inView:self];
        [menu setMenuVisible:YES animated:YES];
        
    } else {
        
        // hide menu if no line is selected
        [[UIMenuController sharedMenuController]setMenuVisible:NO animated:NO];
    }
    
    
    [self setNeedsDisplay];
}

- (void)longPress:(UIGestureRecognizer *)gr {
    
    if (gr.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];
        
        if (self.selectedLine) {
            [self.linesInProgress removeAllObjects];
        } else if (gr.state == UIGestureRecognizerStateEnded) {
            self.selectedLine = nil;
        }
        
        [self setNeedsDisplay];
    }
}

- (void)moveLine:(UIPanGestureRecognizer *)pgr {
    
    // no line selected, do nothing
    if (!self.selectedLine) {
        return;
    }
    
    [[UIMenuController sharedMenuController]setMenuVisible:NO animated:NO];

    // when the pan recognizer changes its position...
    if (pgr.state == UIGestureRecognizerStateChanged) {
        
        // how far has the pan moved
        CGPoint translation = [pgr translationInView:self];
        
        // add the translation to the current beginning and end points of the line
        CGPoint begin = [self.selectedLine begin];
        CGPoint end = [self.selectedLine end];
        
        begin.x += translation.x;
        begin.y += translation.y;
        
        end.x += translation.x;
        end.y += translation.y;
        
        // set the new beginning and end point of the line
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
        
        // redraw the screen
        [self setNeedsDisplay];
        
        [pgr setTranslation:CGPointZero inView:self];
    }
}

#pragma mark - UIGestureRecognizerDelegate protocol method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer; {
    
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    } else {
        return NO;
    }
}

@end
