//
//  BNRLineStore.h
//  TouchTracker
//
//  Created by Brigitte Michau on 2014/09/03.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BNRLine;

@interface BNRLineStore : NSObject

@property (strong, nonatomic) NSArray *allLines;

+ (instancetype)sharedStore;
- (void)addLine:(BNRLine *)line;
- (BOOL)saveLines;

@end
