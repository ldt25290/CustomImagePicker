//
//  ViewController.h
//  Camera
//
//  Created by Rada Mislovaty on 1/2/14.
//  Copyright (c) 2014 Rada Mislovaty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    int state; //0 - nothing, 1 - camera, 2 - gallery
    
    UILabel *flashLbl;
}
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *picture;

- (IBAction)onPhoto:(id)sender;

@end
