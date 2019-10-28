//
//  DownloaderManager.m
//  DownloadFile
//
//  Created by lfc on 2019/10/23.
//  Copyright © 2019 lfc. All rights reserved.
//

#import "DownloaderManager.h"
#import "Downloader.h"
@interface DownloaderManager()

@property (nonatomic,strong) NSMutableDictionary *downloaderCache;
@end

@implementation DownloaderManager

//懒加载
- (NSMutableDictionary *)downloaderCache
{
    if (_downloaderCache == nil) {
        _downloaderCache = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _downloaderCache;
}

//单例方法
+ (instancetype)sharedManager
{
    static id instance = nil;
    if(instance == nil)
    {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [self new];
        });
    }
    
    return instance;
}

- (void)download:(NSString *)urlString andSuccessBlock:(void (^)(NSString * _Nonnull))successBlock andProcessBlock:(void (^)(float))processBlock andErrorBlock:(void (^)(NSError * _Nonnull))errorBlock
{
    //判断缓冲池中是否有下载文件
    if(self.downloaderCache[urlString])
    {
        NSLog(@"已经在下载");
        return;
    }
    
    //下载文件
     Downloader *down = [Downloader new];
    //添加到缓冲池
    [self.downloaderCache setObject:down forKey:urlString];
     
    [down download:urlString andSuccessBlock:^(NSString * _Nonnull path) {
        //移除
        [self.downloaderCache removeObjectForKey:urlString];
        
        if (successBlock) {
            successBlock(path);
        }
        
    } andProcessBlock:processBlock andErrorBlock:^(NSError * _Nonnull error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    
}

//暂停
- (void)pause:(NSString *)urlString
{
    Downloader *down = self.downloaderCache[urlString];
    if (down == nil)
    {
        NSLog(@"此文件没有在下载中");
        return;
    }
    //zant
    [down pause];
    //删除缓冲池中的下载缓存
    [self.downloaderCache removeObjectForKey:urlString];
}

@end
