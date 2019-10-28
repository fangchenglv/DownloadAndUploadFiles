//
//  UploadFiles.h
//  DownloadFile
//
//  Created by lfc on 2019/10/23.
//  Copyright © 2019 lfc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadFiles : NSObject

//上传多个文件
+ (void)upLoadFiles:(NSString *)urlString andFieldName:(NSString *)fieldName andFilePaths:(NSArray *)filePaths;

@end

NS_ASSUME_NONNULL_END
