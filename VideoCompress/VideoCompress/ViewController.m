//
//  ViewController.m
//  VideoCompress
//
//  Created by caifeng on 2017/6/5.
//  Copyright © 2017年 facaishu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ViewController{

    UIImagePickerController *_imgPicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)chooseLocalVideo:(id)sender {
    
    // iOS Device
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imgPicker.mediaTypes = @[@"public.movie"];
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:nil];
    _imgPicker.showsCameraControls = NO;
    _imgPicker.cameraOverlayView = [[UIView alloc] init];
    // iOS-Simulator
//    NSURL *sourceUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Library/OnePiece.mp4"]];
//    
//    NSData *data = [NSData dataWithContentsOfURL:sourceUrl];
//    NSLog(@"original size = %.2f", data.length/1024.0/1024.0);
//    [self compressVideoWithFileURL:sourceUrl];
    
    
}

- (IBAction)recordingVideo:(id)sender {
    
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imgPicker.mediaTypes = @[@"public.movie"];
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:nil];
    
    
    
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
    /*
     AVAssetExportSessionStatusUnknown,
     AVAssetExportSessionStatusWaiting,
     AVAssetExportSessionStatusExporting,
     AVAssetExportSessionStatusCompleted,
     AVAssetExportSessionStatusFailed,
     AVAssetExportSessionStatusCancelled
     */
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
                NSLog(@"%.2f", [NSData dataWithContentsOfURL:outputUrl].length/1024/1024.0);
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
