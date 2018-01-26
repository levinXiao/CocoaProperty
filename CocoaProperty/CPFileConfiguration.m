//
//  CPFileConfiguration.m
//  CocoaProperty
//
//  Created by xiaoyu on 2018/1/25.
//  Copyright © 2018年 xiaoyu. All rights reserved.
//

#import "CPFileConfiguration.h"

#import "CPFileStreamReader.h"

@implementation CPFileConfiguration {
    NSString *filepath;
    NSMutableData *propertyLineBufferData;
    
    CPFileStreamReader *fileReader;
}

- (instancetype)initWithFilename:(NSString *)filename {
    if (!filename || [filename isEqualToString:@""]) {
        NSLog(@"CocoaProperty filename cannot empty");
        return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"property"];
    return [self initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    if (!path || [path isEqualToString:@""]) {
        NSLog(@"CocoaProperty filepath cannot empty");
        return nil;
    }
    filepath = path;
    return [super init];
}

- (NSDictionary *)parseSync {
    NSData *fileReadData = [[NSData alloc] initWithContentsOfFile:filepath];
    [self shootData:fileReadData];
    NSDictionary *parseResult = [self parse];
    return parseResult;
}

- (void)parseAsyncComplete:(void (^)(NSDictionary *propertyResult, NSError *error))complete {
    fileReader = [[CPFileStreamReader alloc] initWithFilepath:filepath];
    [fileReader startReadAsyncComplete:^(NSData *data, CPFileStreamReaderError errorcode) {
        if (errorcode != CPFileStreamReaderErrorNone) {
            if (complete) complete(nil, [NSError errorWithDomain:@"parse error" code:errorcode userInfo:nil]);
            return;
        }
        if (data.length == 0) {
            if (complete) complete(nil, [NSError errorWithDomain:@"file empty" code:CPFileStreamReaderErrorFileEmpty userInfo:nil]);
            return;
        }
        [self shootData:data];
        NSDictionary *parseDictionary = [self parse];
        if (complete) complete(parseDictionary, nil);
    }];
}


- (void)shootData:(NSData *)data {
    if (data && data.length > 0) {
        if (!propertyLineBufferData) {
            propertyLineBufferData = [NSMutableData data];
        }
        [propertyLineBufferData appendData:data];
    }
}

- (NSDictionary *)parse {
    if (propertyLineBufferData.length == 0) {
        NSLog(@"CocoaProperty file cannot empty");
        return nil;
    }
    
    NSString *fileString = [[NSString alloc] initWithData:propertyLineBufferData encoding:NSUTF8StringEncoding];
    NSArray *propertyArray = [fileString componentsSeparatedByString:@"\n"];
    
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
    
    for (NSString *propertyString in propertyArray) {
        NSString *trimString = [propertyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimString.length > 0) {
            NSString *firstString = [trimString substringToIndex:1];
            //忽略注释行
            if ([firstString isEqualToString:@"#"] ||
                [firstString isEqualToString:@"!"] ||
                [firstString isEqualToString:@"！"]) {
                continue;
            }else{
                //非注释
                NSRange emitStringRange = [trimString rangeOfString:@"="];
                //找到=
                if (emitStringRange.length == 0) {
                    emitStringRange = [trimString rangeOfString:@":"];
                }
                if (emitStringRange.length == 0) {
                    continue;
                }
                NSString *key = [trimString substringWithRange:(NSRange){0,emitStringRange.location}];
                NSString *value = [trimString substringWithRange:(NSRange){
                    emitStringRange.location+emitStringRange.length,
                    trimString.length - (emitStringRange.location+emitStringRange.length)
                }];
                
                key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (key && ![key isEqualToString:@""] &&
                    value && ![value isEqualToString:@""]) {
                    [resultDictionary setObject:value forKey:key];
                }
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:resultDictionary];
}

@end
