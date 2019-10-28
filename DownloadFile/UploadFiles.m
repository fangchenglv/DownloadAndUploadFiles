//
//  UploadFiles.m
//  DownloadFile
//
//  Created by lfc on 2019/10/23.
//  Copyright © 2019 lfc. All rights reserved.
//

#import "UploadFiles.h"
#define kBOUNDARY @"abc"

@implementation UploadFiles


//上传多个文件
+ (void)upLoadFiles:(NSString *)urlString andFieldName:(NSString *)fieldName andFilePaths:(NSArray *)filePaths
         //andParamas:(NSDictionary *)paramas
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置post
    request.HTTPMethod = @"post";
    
    
    //设置请求头
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBOUNDARY] forHTTPHeaderField:@"Content-Type"];
    
    //设置请求体
    request.HTTPBody = [self makeBody:fieldName andFilePaths:filePaths];
//andParamas:paramas];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError)
        {
            NSLog(@"连接错误 %@",connectionError);
            return ;
        }
        
        //
        NSHTTPURLResponse *httpResponse  = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200 || httpResponse.statusCode ==304 )
        {
            //解析数据
            id josn = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSLog(@"%@",josn);
        }
        else
        {
            NSLog(@"服务器内部错误");
        }
    }];
}


+ (NSData *)makeBody:(NSString *)fieldName andFilePaths:(NSArray *)filePaths //andParamas:(NSDictionary *)paramas
{
    NSMutableData *mData = [NSMutableData data];
    //拼文件
    [filePaths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop)
     {
        NSMutableString *mString = [NSMutableString string];
        [mString appendFormat:@"\r\n--%@\r\n",kBOUNDARY];
        [mString appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",fieldName,[filePath lastPathComponent]];//obj lastPathComponent
        [mString appendString:@"Content-Type: application/octet-stream\r\n"];
        [mString appendString:@"\r\n"];
        //拼到二进制数据里
        [mData appendData:[mString dataUsingEncoding:NSUTF8StringEncoding]];
        
        //加载文件
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [mData appendData:data];
    }];
    //拼字符串
//    [paramas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop)
//    {
//        NSMutableString *mString = [NSMutableString string];
//        [mString appendFormat:@"\r\n--%@\r\n",kBOUNDARY];
//        [mString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key];
//
//        [mString appendString:@"\r\n"];
//        [mString appendFormat:@"%@",obj];
//
//        [mData appendData:[mString dataUsingEncoding:NSUTF8StringEncoding]];
//
//    }];
    
    NSString *end = [NSString stringWithFormat:@"\r\n--%@--",kBOUNDARY];
    [mData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    return mData.copy;
}
@end
