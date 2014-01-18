//
//  ViewController.m
//  Camera
//
//  Created by Rada Mislovaty on 1/2/14.
//  Copyright (c) 2014 Rada Mislovaty. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define IS_4INCH ([UIScreen mainScreen].bounds.size.height > 480)

typedef enum PickerState{
    pickerStateNone,
    pickerStateCamera,
    pickerStateLibrary
}PickerState;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    state = pickerStateNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

-(void)gotoLibrary:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.view setFrame:CGRectMake(0, 80, 320, 350)];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [imagePicker setDelegate:self];
    
    [_imagePicker presentViewController:imagePicker animated:YES completion:nil];
    state = pickerStateLibrary;
}

-(void)cancelPhoto
{
    [_imagePicker.delegate imagePickerControllerDidCancel:_imagePicker];
}

- (void) takePhoto
{
    [_imagePicker takePicture];
}

-(void)frontRearButtonClicked
{
    [UIView transitionWithView:_imagePicker.view
                      duration:0.5
                       options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        if ( _imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear )
                            _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                        else
                            _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                    } completion:NULL];
}

- (void) onFlash
{
    if(_imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff)
    {
        _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        flashLbl.text = @"On";
        
    }
    else  if(_imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn)
    {
        _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        flashLbl.text = @"Auto";
    }
    else  if(_imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeAuto)
    {
        _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        flashLbl.text = @"Off";
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * img = info[UIImagePickerControllerOriginalImage];
    self.picture.image = img;

    [picker dismissViewControllerAnimated:(state < pickerStateLibrary) completion:^{
        if(state == pickerStateLibrary){
            [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        }
        state = pickerStateNone;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if(picker == _imagePicker){
        state = pickerStateNone;
    }
    else{
        state = pickerStateCamera;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPhoto:(id)sender
{
    state = pickerStateCamera;
    
    [self setupImagePicker];
    
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void) setupImagePicker
{
    // creating the image picker, free of system camera controls
    _imagePicker = [[UIImagePickerController alloc] init];
    [_imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [_imagePicker setDelegate:self];
    _imagePicker.showsCameraControls=NO;
    
    // creating a custom "cancel" button
    UIButton * cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 500, 60, 40)];
    if(!IS_4INCH){
        cancelButton.frame = CGRectMake(10, _imagePicker.view.bounds.size.height - 35, 60, 40);
    }
    [cancelButton addTarget:self action:@selector(cancelPhoto) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_imagePicker.view addSubview:cancelButton];
    
    // creating a custom "rotate camera" button
    UIButton * rotateBut = [[UIButton alloc] initWithFrame:CGRectMake(100, 440, 30, 30)];
    if(!IS_4INCH){
        rotateBut.frame = CGRectMake(20, _imagePicker.view.bounds.origin.y + 30, 30, 30);
    }
    [rotateBut addTarget:self action:@selector(frontRearButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [rotateBut setImage:[UIImage imageNamed:@"rotate"] forState:UIControlStateNormal];
    [_imagePicker.view addSubview:rotateBut];
    
    // creating custrom flash:
    // 1) button with icon
    UIButton *flashBut = [[UIButton alloc] initWithFrame:CGRectMake(190, 440, 30, 30)];
    if(!IS_4INCH){
        flashBut.frame = CGRectMake(240, _imagePicker.view.bounds.origin.y + 30, 30, 30);
    }
    [flashBut addTarget:self action:@selector(onFlash) forControlEvents:UIControlEventTouchUpInside];
    [flashBut setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [_imagePicker.view addSubview:flashBut];
   
    // 2) label with current flash state
    flashLbl = [[UILabel alloc]initWithFrame:CGRectMake(220, 440, 50, 30)];
    if(!IS_4INCH){
        flashLbl.frame = CGRectMake(270, _imagePicker.view.bounds.origin.y + 30, 50, 30);
    }
    flashLbl.backgroundColor = [UIColor clearColor];
    flashLbl.text =  @"Auto";
    flashLbl.font = [UIFont systemFontOfSize:14];
    flashLbl.textColor = [UIColor whiteColor];
    [_imagePicker.view addSubview:flashLbl];
    
    // 3) transparent button to make the clickable area larger
    UIButton *voidButton = [[UIButton alloc] initWithFrame:CGRectMake(190, 440, 80, 30)];
    if(!IS_4INCH){
        voidButton.frame = CGRectMake(240, _imagePicker.view.bounds.origin.y + 30, 80, 30);
    }
    [voidButton addTarget:self action:@selector(onFlash) forControlEvents:UIControlEventTouchUpInside];
    voidButton.backgroundColor = [UIColor clearColor];
    [_imagePicker.view addSubview:voidButton];
    
    // creating a custom "take photo" button
    UIButton * shootButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 500, 60, 60)];
    if(!IS_4INCH){
        shootButton.frame = CGRectMake(130, _imagePicker.view.bounds.size.height - 65, 60, 60);
    }
    [shootButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    shootButton.layer.cornerRadius = 30;
    shootButton.layer.borderColor = [UIColor blueColor].CGColor;
    shootButton.layer.borderWidth = 4;
    shootButton.backgroundColor = [UIColor whiteColor];
    [_imagePicker.view addSubview:shootButton];
    
    // creating a button that will allow access to the photo albums
    __block UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(240, 500, 40, 45)];
    if(!IS_4INCH){
        button.frame = CGRectMake(270, _imagePicker.view.bounds.size.height - 50, 40, 45);
    }
    [button addTarget:self action:@selector(gotoLibrary:) forControlEvents:UIControlEventTouchUpInside];
    
    // accessing the last photo in order to show it ont the button, hence giving a visual clue to the button's role
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if ([group numberOfAssets] > 0)
        {
            // Chooses the photo at the last index
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                
                // The end of the enumeration is signaled by asset == nil.
                if (alAsset) {
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                    [button setImage:latestPhoto forState:UIControlStateNormal];
                }
            }];
        }
        else{
            // empty photo gallery - no need to do anything
        }
    } failureBlock: ^(NSError *error) {
        NSLog(@"Failure");
        
    }];
    [_imagePicker.view addSubview:button];
}

@end
