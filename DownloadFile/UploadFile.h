//
//  UploadFile.h
//  DownloadFile
//
//  Created by lfc on 2019/10/23.
//  Copyright © 2019 lfc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadFile : NSObject

+ (void) uploadFile:(NSString *)urlString andFieldName:(NSString *)fieldName andFieldPath:(NSString *)fieldPath;

@end

NS_ASSUME_NONNULL_END
