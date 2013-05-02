//
//  ViewController.m
//  bashiwariCamera
//
//  Created by 山本洸希 on 12/11/18.
//  Copyright (c) 2012年 山本洸希. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property CGRect faceRect;
@property float widthScale;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [super viewDidLoad];
    
    
    NSError *error = nil;
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        
    }
    if(!deviceInput){
        
    }
    if ( [self.session canAddInput:deviceInput] ){
        [self.session addInput:deviceInput];
    }else{
        
    }
    
    self.stillImageOutput = [AVCaptureStillImageOutput new];
    if ( [self.session canAddOutput:self.stillImageOutput] ){
        [self.session addOutput:self.stillImageOutput];
    }else{
        
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    //UIView *previewView = [[UIView alloc] initWithFrame:CGRectMake(0,  0, 320, 416)];
    UIView *previewView = [[UIView alloc] initWithFrame:CGRectMake(0,  0, 320, self.view.frame.size.height-44)];
    previewView.tag = 101;
    CALayer *rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    [self.view addSubview:previewView];
    
    [self.session startRunning];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
            break;
	}

    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            // キャプチャしたデータを取る
            NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            //プレビューを消す
            for (UIView *view in [self.view subviews]) {
                if (view.tag==101) {
                    view.hidden = YES;
                }
            }
            for (UIView *view in [self.imageView subviews]) {
                if (view.tag >= 200) {
                    [view removeFromSuperview];
                }
            }
            // 押されたボタンにキャプチャした静止画を設定する
            self.imageView.image = [UIImage imageWithData:data];
            [self waribashi];
        }
    }
     ];
}

-(void)waribashi {
    
    // 検出器生成
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    
    // 検出
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:self.imageView.image.CGImage];
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];
    NSArray *array = [detector featuresInImage:ciImage options:imageOptions];
    
    // 検出されたデータを取得
    for (CIFaceFeature *faceFeature in array) {
        // 割り箸画像追加処理へ
        [self drawMeganeImage:faceFeature];
    }
    
}

- (void)drawMeganeImage:(CIFaceFeature *)faceFeature
{
    if (faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition && faceFeature.hasMouthPosition) {
        
        // 顔のサイズ情報を取得
        CGRect faceRect = [faceFeature bounds];
        float temp = faceRect.size.width;
        faceRect.size.width = faceRect.size.height;
        faceRect.size.height = temp;
        temp = faceRect.origin.x;
        faceRect.origin.x = faceRect.origin.y;
        faceRect.origin.y = temp;
        
        // 比率計算
        float widthScale = self.imageView.frame.size.width / self.imageView.image.size.width;
        float heightScale = self.imageView.frame.size.height / self.imageView.image.size.height;
        // 割り箸画像のxとy、widthとheightのサイズを比率似合わせて変更
        faceRect.origin.x *= widthScale;
        faceRect.origin.y = (faceRect.origin.y * heightScale) + (100 * heightScale);
        faceRect.size.width *= widthScale;
        faceRect.size.height *= heightScale;
        
        // 割り箸のUIImageViewを作成
        UIImage *glassesImage = [UIImage imageNamed:@"waribashi.png"];
        UIImageView *glassesImageView = [[UIImageView alloc]initWithImage:glassesImage];
        glassesImageView.tag = 200;
        glassesImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // 割り箸画像のリサイズ
        glassesImageView.frame = faceRect;
        
        // 割り箸レイヤを撮影した写真に重ねる
        [self.imageView addSubview:glassesImageView];
        self.faceRect = faceRect;
        self.widthScale = widthScale;
    }
}

- (IBAction)clearView:(id)sender {
    for (UIView *view in [self.view subviews]) {
        if (view.tag==101) {
            view.hidden = NO;
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    
    if ( touch.view.tag == 200 ) {
		for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self.imageView];

            CGRect faceRect = self.faceRect;
            faceRect.origin.x = location.x - (110 * self.widthScale);
            faceRect.origin.y = location.y;
            
            // 割り箸のUIImageViewを作成
            UIImage *glassesImage = [UIImage imageNamed:@"waribashi.png"];
            UIImageView *glassesImageView = [[UIImageView alloc]initWithImage:glassesImage];
            glassesImageView.tag = 200;
            glassesImageView.contentMode = UIViewContentModeScaleAspectFit;
            // 割り箸画像のリサイズ
            glassesImageView.frame = faceRect;
            
            // 割り箸レイヤを撮影した写真に重ねる
            [self.imageView addSubview:glassesImageView];
        }
        
    }
}

@end
