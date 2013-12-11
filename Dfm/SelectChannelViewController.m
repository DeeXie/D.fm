//
//  SelectChannelViewController.m
//  Dfm
//
//  Created by xieweizhi on 12/7/13.
//  Copyright (c) 2013 xieweizhi. All rights reserved.
//

#import "SelectChannelViewController.h"

@interface SelectChannelViewController ()

@end

@implementation SelectChannelViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBackAction) ] ;
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight] ;
    [self.view addGestureRecognizer:swipeGesture] ;
}


- (void) swipeBackAction {
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationTransition: trans forView: [self view] cache: YES];
    [UIView commitAnimations];
    [NSThread sleepForTimeInterval:0.3] ;
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

-(void)viewDidAppear:(BOOL)animated {
    if (!self.channelsArray) {
        [self dismissViewControllerAnimated:NO completion:nil ] ;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.channelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"channel cell";
    UITableViewCell *cell  ;
    if (indexPath.row > 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ] ;
        UILabel *channelNameLabel = (UILabel *) [cell viewWithTag:1] ;
        NSString *channelName = self.channelsArray[indexPath.row - 2][@"name"] ;
        channelNameLabel.text = channelName ;
        
        NSString *selectedChannelName = [[NSUserDefaults standardUserDefaults] objectForKey:kChannelName] ;
        if ([selectedChannelName isEqualToString: channelName]) {
            cell.backgroundColor = [UIColor grayColor] ;
        }
        
    } else if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"] ;
        cell.userInteractionEnabled = NO ;
    } else if (indexPath.row == 0 ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"] ;
        cell.userInteractionEnabled = NO ;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //save the channel id that user selected

    NSDictionary *channelDic = self.channelsArray[indexPath.row-2 ] ;
        NSLog(@"%@" , channelDic[@"name"]) ;
    [[NSUserDefaults standardUserDefaults] setObject:channelDic[kChannelId] forKey:kChannelId] ;
    [[NSUserDefaults standardUserDefaults] setObject:channelDic[@"name"] forKey:kChannelName] ;
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

@end
