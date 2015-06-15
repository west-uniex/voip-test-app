//
//  KMP_NSStreamController.m
//  testtaskvoip
//
//  Created by Mykola on 6/6/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import "KMP_NSStreamController.h"
#import "NSStream+StreamToHost.h"

#import "AudioController.h"
#import "CFSocketServer.h"


@interface KMP_NSStreamController () <
                                        //KMP_Connection,
                                        AudioControllerDelegate,
                                        NSStreamDelegate
                                     >
{


}

@property (nonatomic, strong) CFSocketServer *voipCFSocketServer;


@end


@implementation KMP_NSStreamController

#pragma mark
#pragma mark    override method from superclass (LLNNetworkingController)


- (void) loadCurrentStatusForConnectingWithURL: (NSURL *)url
{
    if (self.controllerType == SERVER)
    {
        ALog(@"BAD case ");
    }
    
    
    self.inputStream  = nil;
    self.outputStream = nil;
    
    NSInputStream  *readStream  = nil;
    NSOutputStream *writeStream = nil;
    
    [NSStream createReadAndWriteStreamsToHostNamed: url.host
                                              port: url.port.integerValue
                                       inputStream: & readStream
                                      outputStream: & writeStream ];
    //  set input stream
    [readStream setDelegate: self];
    [readStream scheduleInRunLoop: [NSRunLoop currentRunLoop]
                          forMode: NSDefaultRunLoopMode];
    [readStream setProperty: NSStreamNetworkServiceTypeVoIP
                     forKey: NSStreamNetworkServiceType] ;
    self.inputStream = readStream;
    [readStream open];
    
    //  set output stream
    [writeStream setDelegate: self];
    
    [writeStream scheduleInRunLoop: [NSRunLoop currentRunLoop]
                           forMode: NSDefaultRunLoopMode];
    [writeStream setProperty: NSStreamNetworkServiceTypeVoIP
                      forKey: NSStreamNetworkServiceType] ;
    
    self.outputStream = writeStream;
    [writeStream open];
    
    [[NSRunLoop currentRunLoop] run];
}

- (void) stop

{
    [self.outputStream close];
    [self.inputStream  close];

}

#pragma mark
#pragma mark   


- (void) sendData: (NSData *) packet
{
    NSUInteger size = [packet length] / sizeof(char);
    unsigned char* array = (unsigned char*) [packet bytes];
    
    NSInteger l = 0 ;
    while (1)
    {
        l = [_outputStream     write: (const uint8_t *)array
                           maxLength: size  ] ;
        if (l > 0)
        {
            NSLog(@"send data len:%zd", l) ;
        }
        else
        {
            break ;
        }
    }
}





//@protocol KMP_Connection <NSObject>
//
//- (BOOL) isConnect ;
//- (void) connect ;
//- (void) closeConnection ;
//- (void) sendData: (NSData *) packet; //(KMP_Packet *)packet ;
//
//@end

//#pragma mark
//#pragma mark   KMP_Connection  conforms
//
//- (BOOL) isConnect
//{
//    return <#expression#>
//}
//
//- (void) connect ;
//- (void) closeConnection ;
//- (void) sendData: (NSData *) packet; //(KMP_Packet *)packet ;
//


#pragma mark
#pragma mark   NSStreamDelegate  conforms

/*
 typedef NS_OPTIONS(NSUInteger, NSStreamEvent) 
 {
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
    
    NSString *flagStream = nil;
    
    if (aStream == self.outputStream)
    {
        flagStream = @"Output Stream";
    }
    else if (aStream == self.inputStream)
    {
        flagStream = @"Input Stream";
    }
    else
    {
        sleep(0);
    }
    
    MDLog(@"%@: %@\neventCode = %@ \n\n\n", flagStream, aStream, [printDictionary objectForKey: @(eventCode) ] );
    
}

//@protocol AudioControllerDelegate <NSObject>
//
//- (void) sendVoIPPacketAfterRendering: (NSData *) packet;
//
//@end

#pragma mark
#pragma mark AudioControllerDelegate conforms

- (void) sendVoIPPacketAfterRendering: (NSData *) packet
{
    [self sendData: packet];

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
