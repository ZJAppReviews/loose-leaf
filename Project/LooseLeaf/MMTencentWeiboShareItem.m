//
//  MMTencentWeiboShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTencentWeiboShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation MMTencentWeiboShareItem{
    MMImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"tencentWeibo"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateButtonGreyscale];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTencentWeibo];
    if(fbSheet){
        [fbSheet setInitialText:@"Quick sketch drawn in Loose Leaf"];
        [fbSheet addImage:self.delegate.imageToShare];
        [fbSheet addURL:[NSURL URLWithString:@"http://getlooseleaf.com"]];
        fbSheet.completionHandler = ^(SLComposeViewControllerResult result){
            NSString* strResult;
            if(result == SLComposeViewControllerResultCancelled){
                strResult = @"Cancelled";
            }else if(result == SLComposeViewControllerResultDone){
                strResult = @"Sent";
            }
            if(result == SLComposeViewControllerResultDone){
                [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
            }
            [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"TencentWeibo",
                                                                         kMPEventExportPropResult : strResult}];
        };
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:fbSheet animated:YES completion:nil];
    }
    
    [delegate didShare];
}

-(BOOL) isAtAllPossible{
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTencentWeibo] != nil;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTencentWeibo]) {
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
