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


@interface ViewController ()
{

    //AudioController            *audioController;
    //KMP_NSStreamController     *streamController;
    
    AVAudioPlayer                *_audioPlayer;
}

@property (nonatomic, strong) AudioController        *audioController;

@property (nonatomic, strong) KMP_NSStreamController *clientStreamController;

@property (nonatomic, strong) CFSocketServer         *voipCFSocketServer;


@end



@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createRingSound];
    
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
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:(NSURL*)url error:&error];

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
        _audioController.delegate = _clientStreamController;
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

@end
