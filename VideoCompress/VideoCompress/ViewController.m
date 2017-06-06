//
//  ViewController.m
//  VideoCompress
//
//  Created by caifeng on 2017/6/5.
//  Copyright © 2017年 facaishu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "VideoCompress-Swift.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ViewController{

    UIImagePickerController *_imgPicker;
    __weak IBOutlet UILabel *cacheDisplayLbl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)chooseLocalVideo:(id)sender {
    
#if TARGET_IPHONE_SIMULATOR

    // iOS-Simulator
    NSString *dirPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *subPaths = [manager subpathsAtPath:dirPath];
    
    NSString *movieAbsolutePath;
    
    for (NSString *subPath in subPaths) {
        
//        NSString *fileAbsolutePath = [dirPath stringByAppendingPathComponent:subPath];
//        NSDictionary *attr = [manager attributesOfItemAtPath:fileAbsolutePath error:nil];
//        NSLog(@"%@ - %.2f", subPath ,attr.fileSize/1024/1024.0);
        
        if ([subPath containsString:@".mp4"]) {
        
            movieAbsolutePath = [dirPath stringByAppendingPathComponent:subPath];
        }
    }
    
    NSLog(@"original movie size : %@", [MECache cacheSizeWithPath:movieAbsolutePath]);
    
    if (movieAbsolutePath) {
        
        [self compressVideoWithFileURL:[NSURL fileURLWithPath:movieAbsolutePath]];
    }
#else
    
    // iOS Device
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imgPicker.mediaTypes = @[@"public.movie"];
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:nil];
    _imgPicker.showsCameraControls = NO;
    _imgPicker.cameraOverlayView = [[UIView alloc] init];
#endif
   
    
    
}

- (IBAction)recordingVideo:(id)sender {
    
#if TARGET_IPHONE_SIMULATOR
    
   
    
#else
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imgPicker.mediaTypes = @[@"public.movie"];
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:nil];
#endif
}


- (IBAction)readCache:(id)sender {
    
    cacheDisplayLbl.text = [MECache cacheSizeWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library"]];
    
}

- (IBAction)cleanCache:(id)sender {
    
    // 清除缓存测试
    [MECache cleanCacheWithPath:[NSHomeDirectory() stringByAppendingString:@"/Library"]];
    cacheDisplayLbl.text = @"0.0MB";
}




- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
   
    NSLog(@"%@", info);
    NSURL *tmpUrl = info[@"UIImagePickerControllerMediaURL"];
//    NSString *refPath = info[@"UIImagePickerControllerReferenceURL"];
    NSLog(@"tmp size = %.2fMB", [NSData dataWithContentsOfURL:tmpUrl].length/1024/1024.0);
    [_imgPicker dismissViewControllerAnimated:YES completion:nil];
    
    [self compressVideoWithFileURL:tmpUrl];
}



- (void)compressVideoWithFileURL:(NSURL *)tmpUrl {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSURL *outputUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Library/output-%@.mp4", [formatter stringFromDate:[NSDate date]]]];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:tmpUrl options:nil];;
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
//    exportSession.shouldOptimizeForNetworkUse = YES;
   
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@", [NSThread currentThread]);

        switch (exportSession.status) {
            case AVAssetExportSessionStatusUnknown:
                
                NSLog(@"AVAssetExportSessionStatusUnknown");
                break;
                
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"AVAssetExportSessionStatusWaiting");

                break;
                
            case AVAssetExportSessionStatusExporting:
                NSLog(@"AVAssetExportSessionStatusExporting");
                NSLog(@"%.2fMB", [NSData dataWithContentsOfURL:outputUrl].length/1024/1024.0);
                break;
                
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"AVAssetExportSessionStatusCompleted");
                NSLog(@"%.2fMB", [NSData dataWithContentsOfURL:outputUrl].length/1024/1024.0);

                break;
                
            case AVAssetExportSessionStatusFailed:
                NSLog(@"AVAssetExportSessionStatusFailed");

                break;
                
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"AVAssetExportSessionStatusCancelled");

                break;
                
            default:
                break;
        }
        
    }];
}




- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [_imgPicker dismissViewControllerAnimated:YES completion:nil];

}


@end
