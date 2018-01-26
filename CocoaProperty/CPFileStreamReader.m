//
//  CPFileStreamReader.m
//  CocoaProperty
//
//  Created by xiaoyu on 2018/1/25.
//  Copyright © 2018年 xiaoyu. All rights reserved.
//

#import "CPFileStreamReader.h"

@interface CPFileStreamReader () <NSStreamDelegate>

@end

@implementation CPFileStreamReader {
    NSString *filepath;
    NSMutableData *fileFullData;
    
    void(^complteBlock)(NSData *resultData, CPFileStreamReaderError error);
}

- (instancetype)initWithFilepath:(NSString *)path {
    filepath = path;
    return [super init];
}

- (void)startReadAsyncComplete:(void (^)(NSData *data, CPFileStreamReaderError error))complete {
    if (!filepath || [filepath isEqualToString:@""]) {
        NSLog(@"CocoaProperty CPFileStreamReader filepath cannot empty");
        return;
    }
    complteBlock = complete;
    
    NSInputStream *readStream = [[NSInputStream alloc] initWithFileAtPath:filepath];
    readStream.delegate = self;
    
    [readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [readStream open];
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable: {
            //读
            NSInteger readBufferLength = 1024;
            NSMutableData *readDataBuffer = [[NSMutableData alloc] initWithLength:readBufferLength];
            NSInputStream *inputStream = (NSInputStream *)aStream;
            NSInteger readedLength = [inputStream read:[readDataBuffer mutableBytes] maxLength:readBufferLength];
            if (readedLength > 0) {
                if (!fileFullData) {
                    fileFullData = [NSMutableData data];
                }
                [fileFullData appendData:readDataBuffer];
            }
        }
            break;
        case NSStreamEventHasSpaceAvailable: {
            //写
        }
            break;
        case NSStreamEventErrorOccurred: {
            if (complteBlock) {
                complteBlock(nil, CPFileStreamReaderErrorReadingFile);
            }
        }
            break;
        case NSStreamEventEndEncountered: {
            //文件结尾
            [aStream close];
            //从运行循环中移除
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            //置为空
            aStream = nil;
            
            if (complteBlock) {
                if (fileFullData.length == 0) {
                    complteBlock(nil, CPFileStreamReaderErrorFileEmpty);
                    return;
                }
                complteBlock([NSData dataWithData:fileFullData], CPFileStreamReaderErrorNone);
            }
        }
            break;
        default:
            break;
    }
}

@end
