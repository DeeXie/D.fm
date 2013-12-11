//
//  LoginViewController.h
//  Dfm
//
//  Created by xieweizhi on 12/10/13.
//  Copyright (c) 2013 xieweizhi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController ;

@protocol LoginViewControllerDelegate <NSObject>

-(void) didPressOkButton  ;

@end

@interface LoginViewController : UIViewController < NSURLConnectionDataDelegate>
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property  (strong , nonatomic) id<LoginViewControllerDelegate> delegate ;
- (IBAction)okAction:(id)sender;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
