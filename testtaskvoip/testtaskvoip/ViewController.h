//
//  ViewController.h
//  testtaskvoip
//
//  Created by Mykola on 5/27/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "KMP_CFNetworkingConnection.h"


@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *makeResetCallButton;

- (IBAction)makeCallByVoIP:(id)sender;

@end

