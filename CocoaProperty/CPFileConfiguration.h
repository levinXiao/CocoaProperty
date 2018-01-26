//
//  CPFileConfiguration.h
//  CocoaProperty
//
//  Created by xiaoyu on 2018/1/25.
//  Copyright © 2018年 xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPFileConfiguration : NSObject

- (instancetype)initWithFilename:(NSString *)filename;

- (instancetype)initWithPath:(NSString *)path;

- (NSDictionary *)parseSync;

- (void)parseAsyncComplete:(void (^)(NSDictionary *propertyResult, NSError *error))complete;

@end
