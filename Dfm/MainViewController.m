//
//  MainViewController.m
//  Dfm
//
//  Created by xieweizhi on 12/7/13.
//  Copyright (c) 2013 xieweizhi. All rights reserved.
//

#import "MainViewController.h"
#import "CJSONDeserializer.h"
#import "SelectChannelViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@interface MainViewController ()

@end

@implementation MainViewController


#pragma  mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadChannels] ;
    [self loadSongsWithType:kLoadSongsTypeNew] ;
    [self setupPlayer] ;
    self.songName.hidden = YES ;
    self.singer.hidden = YES ;
    
    
    //setup volumeView
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:self.volumeParentView.bounds];
    [volumeView setShowsVolumeSlider:YES];
    [volumeView setShowsRouteButton:YES];
    [volumeView sizeToFit];
    [self.volumeParentView addSubview:volumeView];
}

-(void)viewWillAppear:(BOOL)animated {
    NSString *channelName = [[NSUserDefaults standardUserDefaults] objectForKey:kChannelName] ;
    NSLog(@"main:%@" , channelName) ;
    if (channelName) {
        [self.ChannelButton setTitle:channelName forState:UIControlStateNormal] ;
    }
    //if current channel has not changed ,don't load songs
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kChannelName] isEqualToString:self.ChannelButton.titleLabel.text]) {
        [self loadSongsWithType:kLoadSongsTypeNew] ;
    }
    
    if (!channels) {
        [self loadChannels];
    }
}

-(void) loadChannels {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.douban.com/j/app/radio/channels"]] ;
    [request setHTTPMethod:@"GET"] ;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init] ;
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil){
            NSError *parseError = nil ;
            NSArray *channelsArray = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&parseError][@"channels"] ;
            channels = channelsArray ;
        }
    }] ;
}
-(void) loadSongsWithType:(NSString *) type {
    if (!type) {
        type = @"n" ;
    }
    //http://www.douban.com/j/app/radio/people
    
    //setting up the http params
    NSMutableString *url = [[NSMutableString alloc] init ] ;
    [url appendString:@"http://www.douban.com/j/app/radio/people"] ;
    [url appendString:@"?app_name=radio_desktop_win" ];
    [url appendString:@"&version=100"] ;
    
    //if login , add some parameters
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:kUserid] ;
    if (userid) {
        [url appendFormat:@"&user_id=%@" , userid] ;
        [url appendFormat:@"&expire=%@",[[NSUserDefaults standardUserDefaults] objectForKey:kExpire]] ;
        [url appendFormat:@"&token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:kToken]] ;
    }

    [url appendFormat:@"&channel=%@",[[NSUserDefaults standardUserDefaults] objectForKey:kChannelId]] ;
    [url appendFormat:@"&type=%@", type] ;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]] ;
    [request setHTTPMethod:@"GET"] ;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init] ;
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSAssert(!error , @"error while loading songs") ;
        if ([data length] > 0 && error == nil){
            NSError *parseError = nil ;
            NSDictionary *songsDic = [[CJSONDeserializer deserializer ] deserializeAsDictionary:data error:&parseError] ;
            songs = [NSMutableArray arrayWithArray:songsDic[@"song"]] ;
            NSLog(@"songs %@" , songs) ;
            if (songs.count>0) {
                [self playSong] ;
                [self setUpUIWhileHavingSongs] ;
            }
            for (NSDictionary* song in songs) {
                NSLog(@"song name : --> %@" , song[@"title"]) ;
            }
        }
    }];
}



-(void) setupPlayer {
    player = [[AudioPlayer alloc] init] ;
    player.delegate = self ;
}
-(void) setUpUIWhileHavingSongs {
    if (songs.count <= 0 ) {
        [self loadSongsWithType:kLoadSongsTypeNew] ;
        return ;
    }
    NSString *songImageURL = songs[0][@"picture"] ;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:songImageURL]] ;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.songName.hidden = NO ;
            self.singer.hidden = NO ;
            [self.songName setText:songs[0][@"title"] ] ;
            [self.singer setText:songs[0][@"artist"] ];

            if (imageData)
                self.songImageView.image = [UIImage imageWithData:imageData] ;
        }) ;
    }) ;
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show select channel view"]) {
        SelectChannelViewController *destVC = (SelectChannelViewController *) segue.destinationViewController ;
        destVC.channelsArray = channels ;
    }
    
    if ([segue.identifier isEqualToString:@"login view"]) {
        LoginViewController *destVC =   (LoginViewController *) segue.destinationViewController ;
        destVC.delegate = self ;
    }
}

-(void) playSong {
    if (songs.count > 0 ) {
        NSURL *url = [NSURL URLWithString:songs[0][@"url"]] ;
        [player setDataSource:[player dataSourceFromURL:url] withQueueItemId:url] ;
    }
}

#pragma mark - Button Action

- (IBAction)playAction:(id)sender {
    if (player.state == AudioPlayerStatePaused)
	{
		[player resume];
	}
	else
	{
		[player pause];
	}
}

- (IBAction)nextAction:(id)sender {
    //load more songs while all songs are played
    if (songs.count == 0 ) {
        [self loadSongsWithType:kLoadSongsTypeSkip] ;
    } else {
        [self PlayNextSong] ;
    }
}

-(void) PlayNextSong {
    NSURL *url ;
    if (songs.count > 0 ) {
        [songs removeObjectAtIndex:0] ;
        url = [NSURL URLWithString:[songs firstObject][@"url"]] ;
    } else {
        [self loadSongsWithType:kLoadSongsTypeNew] ;
    }
    if (url) {
        [player setDataSource:[player dataSourceFromURL:url] withQueueItemId:url] ;
    }
    [self setUpUIWhileHavingSongs];
}

#pragma mark - LoginViewControllerDelegate
-(void)didPressOkButton {
    //reset the login button
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserName] ;
    [self.login setTitle:userName forState:UIControlStateNormal] ;
    self.login.enabled = NO ;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil] ;
}

#pragma mark - AudioPlayerDelegate
-(void) audioPlayer:(AudioPlayer*)audioPlayer stateChanged:(AudioPlayerState)state {

}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode {
    if (errorCode != AudioPlayerErrorNone) {
        [self PlayNextSong ] ;
    }
    NSLog(@"%@" ,NSStringFromSelector(_cmd)) ;
    NSLog(@"AudioPlayerErrorCode : %u" , errorCode) ;
}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
     NSLog(@"%@" ,NSStringFromSelector(_cmd)) ;
}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
     NSLog(@"%@" ,NSStringFromSelector(_cmd)) ;
}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
     NSLog(@"%@" ,NSStringFromSelector(_cmd)) ;
}

@end
