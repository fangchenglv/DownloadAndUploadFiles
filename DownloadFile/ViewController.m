//
//  ViewController.m
//  DownloadFile
//
//  Created by lfc on 2019/10/21.
//  Copyright © 2019 lfc. All rights reserved.
//

#import "ViewController.h"
#import "ProcessView.h"
#import "DownloaderManager.h"

#import "UploadFile.h"
#import "UploadFiles.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet ProcessView *processView;

//@property(nonatomic,strong) Downloader *down;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//上传单个文件
- (IBAction)upLoadFile:(id)sender {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"01.jpg" ofType:nil];
    
    [UploadFile uploadFile:@"http://127.0.0.1/upload_file.php" andFieldName:@"file" andFieldPath:path];
    
}

//上传多个文件
- (IBAction)upLoadFiles:(id)sender {
    
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"11.zip" ofType:nil];
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"111.jpg" ofType:nil];
    
    NSArray *filePaths = @[path1,path2];
    
    [UploadFiles upLoadFiles:@"http://127.0.0.1/sss.php" andFieldName:@"myFile[]" andFilePaths:filePaths];
}



- (IBAction)start:(id)sender {
    
    [[DownloaderManager sharedManager] download:@"http://127.0.0.1/n1.zip" andSuccessBlock:^(NSString * _Nonnull path) {
        NSLog(@"下载完成 %@",path);
    } andProcessBlock:^(float process) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.processView.process = process;
        });
    } andErrorBlock:^(NSError * _Nonnull error) {
        NSLog(@"下载出错 %@",error);
    }];
    
    
}

- (IBAction)pause:(id)sender {
    //[self.down pause];
    [[DownloaderManager sharedManager]pause:@"http://127.0.0.1/n1.zip"];
}






@end
