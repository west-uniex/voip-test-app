//
//  ViewController.m
//  testtaskvoip
//
//  Created by Mykola on 5/27/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import "ViewController.h"
#import "AudioController.h"

#import "KMP_NSStreamController.h"

#import "CFSocketServer.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController () <
                                CFSocketServerDelegate,
                                AVAudioPlayerDelegate
                             >
{

    //AudioController            *audioController;
    //KMP_NSStreamController     *streamController;
}

@property (nonatomic, strong) AudioController        *audioController;

@property (nonatomic, strong) KMP_NSStreamController *clientStreamController;

@property (nonatomic, strong) CFSocketServer         *voipCFSocketServer;

@property (nonatomic, strong) AVAudioPlayer          *audioPlayer;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createRingSound];
    
    self.acceptVoIPCallButton.hidden = YES;
    
    //__weak __typeof__(self) weakSelf = self;
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(
                    dispatchQueue,
                    ^(void)
                     {
                         self.voipCFSocketServer = [[CFSocketServer alloc]    initOnPort: 5060
                                                                                delegate: self
                                                                           andServerType: SERVERTYPEVOIP];
                     }
                   );
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark

- (void)createRingSound
{
    NSError *error;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"ring" withExtension:@"caf"];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:(NSURL*)url error:&error];
    
    [self.audioPlayer prepareToPlay];

}



#pragma mark
#pragma mark  IB Actions

- (IBAction)makeCallByVoIP:(id)sender
{
    UIButton *thisButton = (UIButton *) sender;
    MDLog(@"\n\n\n");
    
    if ([thisButton.currentTitle isEqualToString: @"make VoIP call"])
    {
        if (_audioController == nil)
        {
            self.audioController = [[AudioController alloc] init];
        }
        
        [_audioController startIOUnit];
        
        //MDLog(@"AudioController: %@ \n\n\n", self.audioController);
        
        self.clientStreamController = [[KMP_NSStreamController alloc] initWithURLString: @"192.168.2.1"
                                                                         controllerType: CLIENT ];
        self.audioController.delegate = (id)_clientStreamController;
        [_clientStreamController start];
        
        [thisButton setTitle: @"End VoIP Call"
                    forState: UIControlStateNormal] ;
        
        [thisButton setTitleColor:[UIColor redColor]
                         forState:UIControlStateNormal] ;
    }
    else
    {
        [_audioController stopIOUnit];
        
        [_clientStreamController stop];
        
        [thisButton setTitle: @"make VoIP call"
                    forState: UIControlStateNormal] ;
        
        [thisButton setTitleColor:[UIColor blueColor]
                         forState:UIControlStateNormal] ;
    
    }
    
    

}

- (IBAction)acceptVoIPCallButtonDidTap:(id)sender
{
    MDLog(@"\n\n\n");
}

#pragma mark
#pragma mark   NSStreamDelegate  conforms

/*
typedef NS_OPTIONS(NSUInteger, NSStreamEvent) {
    NSStreamEventNone              = 0,
    NSStreamEventOpenCompleted     = 1UL << 0,
    NSStreamEventHasBytesAvailable = 1UL << 1,
    NSStreamEventHasSpaceAvailable = 1UL << 2,
    NSStreamEventErrorOccurred     = 1UL << 3,
    NSStreamEventEndEncountered    = 1UL << 4
};

*/

- (void)      stream: (NSStream      *) aStream
         handleEvent: (NSStreamEvent  ) eventCode
{
    NSDictionary *printDictionary = @{
                                        @0          : @"NSStreamEventNone",
                                        @(1UL << 0) : @"NSStreamEventOpenCompleted",
                                        @(1UL << 1) : @"NSStreamEventHasBytesAvailable",
                                        @(1UL << 2) : @"NSStreamEventHasSpaceAvailable",
                                        @(1UL << 3) : @"NSStreamEventErrorOccurred",
                                        @(1UL << 4) : @"NSStreamEventEndEncountered"
                                     };
    
    MDLog(@"aStream: %@\neventCode = %@ \n\n\n", aStream, [printDictionary objectForKey: @(eventCode) ] );

}


//@protocol CFSocketServerDelegate <NSObject>
//
//@optional
//
//- (void) needAcceptConnectionVoIPCall: (CFSocketServer *) theCFSocketServer;
//
//@end

#pragma mark
#pragma mark   CFSocketServerDelegate  conforms


- (void) needAcceptConnectionVoIPCall: (CFSocketServer *) theCFSocketServer

{
    
    MDLog(@" \n\n\n");
    //CFSocketServer *
    self.acceptVoIPCallButton.hidden = NO;
    
    [self.audioPlayer play];
    
}


- (void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player
                       successfully: (BOOL)flag
{
    NSLog(@"Finished playing the song");
    /* The [flag] parameter tells us if the playback was successfully
     finished or not */
    
    
//    if ([player isEqual:self.audioPlayer])
//    {
//        self.audioPlayer = nil;
//    }
//    else
//    {
//        /* Which audio player is this? We certainly didn't allocate
//         this instance! */
//    }
}


@end


//#pragma mark
//#pragma mark ConnectionDelegate conforms
//
////@required
//
//- (NSString *) ipAddress
//{
//    NSString *string = @"192.168.2.1";
//    return  string;
//
//}
//
//- (uint16_t  ) port
//{
//    return 1200;
//}
//
//- (void)dataReceived: (NSData *) packet //(KMP_Packet *) packet
//{
//    MDLog(@"packet: %@ \n\n\n", packet);
//
//}
//
////@optional
//
//- (void) connectionDidConnect
//{
//    MDLog(@" \n\n\n");
//}
//
//- (void) connectionDidDisconnect
//{
//    MDLog(@" \n\n\n");
//}
//
//- (void) connectionFailWithError:(int)error
//{
//    MDLog(@"errpr: %d \n\n\n", error);
//}
//
//
//

