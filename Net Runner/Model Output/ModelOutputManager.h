//
//  ModelOutputManager.h
//  Net Runner
//
//  Created by Philip Dow on 8/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModelOutputManager : NSObject

+ (instancetype)sharedManager;

- (Class)classForType:(NSString*)type;

@end

NS_ASSUME_NONNULL_END
