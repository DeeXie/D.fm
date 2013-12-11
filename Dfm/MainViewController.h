//
//  MainViewController.h
//  Dfm
//
//  Created by xieweizhi on 12/7/13.
//  Copyright (c) 2013 xieweizhi. All rights reserved.
//




#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "AudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LoginViewController.h"
@interface MainViewController : UIViewController<NSURLConnectionDataDelegate,AudioPlayerDelegate ,LoginViewControllerDelegate>
{
    NSArray *channels ;
    NSMutableArray *songs ;
    AudioPlayer *player ;
    
}

@property (nonatomic , strong) IBOutlet UIView      *volumeParentView ;
@property (nonatomic , strong) IBOutlet UIButton    *login ;
@property (nonatomic , strong) IBOutlet UIButton    *ChannelButton ;
@property (nonatomic , strong) IBOutlet UIImageView *songImageView ;
@property (nonatomic , strong) IBOutlet UILabel     *singer ;
@property (nonatomic , strong) IBOutlet UILabel     *songName ;


- (IBAction)playAction:(id)sender;

- (IBAction)nextAction:(id)sender;





@end
