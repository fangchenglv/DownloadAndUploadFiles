//
//  DownloaderManager.h
//  DownloadFile
//
//  Created by lfc on 2019/10/23.
//  Copyright © 2019 lfc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloaderManager : NSObject

+ (instancetype)sharedManager;

- (void)download:(NSString *)urlString andSuccessBlock:(void(^)(NSString *path))successBlock andProcessBlock:(void(^)(float process))processBlock andErrorBlock:(void(^)(NSError *error))errorBlock;
- (void)pause:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
