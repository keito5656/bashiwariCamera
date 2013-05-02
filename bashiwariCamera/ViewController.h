//
//  ViewController.h
//  bashiwariCamera
//
//  Created by 山本洸希 on 12/11/18.
//  Copyright (c) 2012年 山本洸希. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationBarDelegate>
{
    AVCaptureVideoPreviewLayer *previewLayer;
}
- (IBAction)clearView:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) AVCaptureSession *session;
@property (strong,nonatomic) AVCaptureStillImageOutput *stillImageOutput;
- (IBAction)takePicture:(id)sender;
@end
