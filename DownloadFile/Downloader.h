//
//  Downloader.h
//  DownloadFile
//
//  Created by lfc on 2019/10/21.
//  Copyright © 2019 lfc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Downloader : NSObject

- (void)download:(NSString *)urlString andSuccessBlock:(void(^)(NSString *path))successBlock andProcessBlock:(void(^)(float process))processBlock andErrorBlock:(void(^)(NSError *error))errorBlock;

//暂停下载
- (void)pause;
@end

NS_ASSUME_NONNULL_END
