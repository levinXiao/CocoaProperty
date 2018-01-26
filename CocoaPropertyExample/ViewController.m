//
//  ViewController.m
//  CocoaPropertyExample
//
//  Created by xiaoyu on 2018/1/25.
//  Copyright © 2018年 xiaoyu. All rights reserved.
//

#import "ViewController.h"

#import "CocoaProperty.h"
@interface ViewController ()

@end

@implementation ViewController {
    CPFileConfiguration *fileConfigurationAsync;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *filename = @"test";
    
    NSTimeInterval starttime = [[NSDate date] timeIntervalSince1970];
    CPFileConfiguration *fileConfigurationSync = [[CPFileConfiguration alloc] initWithFilename:filename];
    NSDictionary *result = [fileConfigurationSync parseSync];
    NSLog(@"%@",result);
    NSLog(@"sync finish parse ,用时 %.2f秒",[[NSDate date] timeIntervalSince1970]-starttime);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"property"];
    NSTimeInterval starttimeAsync = [[NSDate date] timeIntervalSince1970];
    fileConfigurationAsync = [[CPFileConfiguration alloc] initWithPath:path];
    [fileConfigurationAsync parseAsyncComplete:^(NSDictionary *propertyResult, NSError *error) {
        NSLog(@"%@",propertyResult);
        NSLog(@"async finish parse ,用时 %.2f秒",[[NSDate date] timeIntervalSince1970]-starttimeAsync);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
