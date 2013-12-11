//
//  LoginViewController.m
//  Dfm
//
//  Created by xieweizhi on 12/10/13.
//  Copyright (c) 2013 xieweizhi. All rights reserved.
//

#import "LoginViewController.h"
#import "CJSONDeserializer.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserName] ;
    if (userName) {
        self.userName.text = userName ;
    }
}

- (IBAction)okAction:(id)sender {
    if ([self.userName.text isEqualToString:@""] || [self.password.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"输入错误" message:nil delegate:self cancelButtonTitle:@"ok"  otherButtonTitles:nil , nil] ;
        [alertView show] ;
        return ;
    }
    [self login] ;
}

- (IBAction)hideKeyboard:(id)sender {
    if ([sender class] == [UITextField class]) {
        [sender resignFirstResponder] ;
    }
    else {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil ] ;
}


-(void) login {
    NSString *url = [NSString stringWithFormat:@"http://www.douban.com/j/app/login?app_name=radio_desktop_win&version=99&email=%@&password=%@", self.userName.text,self.password.text] ;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]] ;
    
    [request setHTTPMethod:@"GET"] ;
    [request setValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"] ;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self ] ;
    [connection start] ;
}


#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    NSError *error = nil ;
    NSDictionary *loginInfo = [[CJSONDeserializer deserializer] deserializeAsDictionary:d error:&error] ;
    
    int loginSuccess = [loginInfo[kErrorCode] intValue];
    //if login success
    if (loginSuccess == 1) {
        NSLog(@"login failed") ;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"用户名或者密码输入错误" message:nil delegate:self cancelButtonTitle:@"ok"  otherButtonTitles:nil , nil] ;
        [alertView show] ;
        return ;
    } else {
        NSLog(@"login success") ;
        //save user info
        [[NSUserDefaults standardUserDefaults] setObject:loginInfo[kUserName] forKey:kUserName] ;
        [[NSUserDefaults standardUserDefaults] setObject:loginInfo[kUserid] forKey:kUserid] ;
        [[NSUserDefaults standardUserDefaults] setObject:loginInfo[kExpire] forKey:kExpire] ;
        [[NSUserDefaults standardUserDefaults] setObject:loginInfo[kToken] forKey:kToken] ;
        [[NSUserDefaults standardUserDefaults] setInteger:[loginInfo[kErrorCode] intValue] forKey:kErrorCode] ;
        [self.delegate didPressOkButton] ;
    }
}




@end
