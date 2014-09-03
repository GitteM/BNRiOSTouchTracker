//
//  BNRLineStore.m
//  TouchTracker
//
//  Created by Brigitte Michau on 2014/09/03.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRLineStore.h"
#import "BNRDrawView.h"
#import "BNRLine.h"

@interface BNRLineStore ()

@property (strong, nonatomic) NSMutableArray *privateItems;
@end

@implementation BNRLineStore


+ (instancetype)sharedStore
{
    static BNRLineStore *sharedStore;
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        NSString *path = [self lineArchivePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_privateItems) {
            _privateItems = [[NSMutableArray alloc]init];
        }
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use [BNRLineStore sharedStore]"
                                 userInfo:nil];
}

- (void)addLine:(BNRLine *)line {
    if (![self.privateItems containsObject:line]) {
        [self.privateItems addObject:line];
    }
}

- (NSArray *)allLines {
    return [self.privateItems copy];
}

- (BOOL)saveLines {
    NSString *path = [self lineArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}

- (NSString *)lineArchivePath {
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"lines.archive"];
}

@end
