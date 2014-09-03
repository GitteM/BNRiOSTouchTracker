//
//  BNRLine.m
//  TouchTracker
//
//  Created by Brigitte Michau on 2014/08/30.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRLine.h"

@implementation BNRLine

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _begin  = [aDecoder decodeCGPointForKey:@"begin"];
        _end = [aDecoder decodeCGPointForKey:@"end"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGPoint:self.begin forKey:@"begin"];
    [aCoder encodeCGPoint:self.end forKey:@"end"];
}

@end
