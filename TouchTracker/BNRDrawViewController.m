//
//  BNRDrawViewController.m
//  TouchTracker
//
//  Created by Brigitte Michau on 2014/08/30.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRDrawViewController.h"
#import "BNRDrawView.h"

@implementation BNRDrawViewController

- (void)loadView {
    self.view = [[BNRDrawView alloc]initWithFrame:CGRectZero];
}

@end
