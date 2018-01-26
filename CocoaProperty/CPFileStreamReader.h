//
//  CPFileStreamReader.h
//  CocoaProperty
//
//  Created by xiaoyu on 2018/1/25.
//  Copyright © 2018年 xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CPFileStreamReaderError) {
    CPFileStreamReaderErrorNone,
    CPFileStreamReaderErrorFileEmpty,
    CPFileStreamReaderErrorReadingFile,
};

@interface CPFileStreamReader : NSObject

- (instancetype)initWithFilepath:(NSString *)path;

- (void)startReadAsyncComplete:(void (^)(NSData *data, CPFileStreamReaderError error))complete;

@end
