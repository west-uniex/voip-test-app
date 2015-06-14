//
//  KMP_CFNetworkingConnection.m
//  testtaskvoip
//
//  Created by Mykola on 6/1/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import "KMP_CFNetworkingConnection.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>


typedef enum eNetworkState
{
    NetworkStateDisconnect = 0,
    NetworkStateConnecting,
    NetworkStateConnected
    
}   NetworkState ;


@interface KMP_CFNetworkingConnection ()

{
    //KMP_PacketMemoryManager manager ;
}


@property (nonatomic, weak, readwrite) id<ConnectionDelegate> delegate ;

@property (nonatomic, strong) NSThread         *threadNetwork ;

@property (nonatomic, assign) NetworkState      networkState ;

//@property (nonatomic, strong) KMP_PacketSendList *packetSendList ;

@property (nonatomic, strong) NSInputStream    *inputStream ;

@property (nonatomic, strong) NSOutputStream   *outputStream ;


@end


@implementation KMP_CFNetworkingConnection


- (id)initWithDelegate:(id<ConnectionDelegate>) aDelegate
{
    self = [super init] ;
    
    if (self)
    {
        _networkState   = NetworkStateDisconnect ;
        //_packetSendList = [[KDPacketSendList alloc] init] ;
        _delegate       = aDelegate ;
    }
    
    return self ;
}



- (void)dealloc
{
    if (_threadNetwork && ![_threadNetwork isCancelled])
    {
        [_threadNetwork cancel] ;
    }
}


#pragma mark
#pragma mark - Connection protocol conforming

- (BOOL)isConnect
{
    return _networkState == NetworkStateConnected ;
}

- (void) connect
{
    MDLog(@" ");
    
    if (!_threadNetwork)
    {
        self.threadNetwork = [[NSThread alloc] initWithTarget: self
                                                     selector: @selector(threadEntry)
                                                       object: nil] ;
        [_threadNetwork start] ;
    }
}

- (void)closeConnection
{
    if (_threadNetwork && ![_threadNetwork isCancelled])
    {
        [_threadNetwork cancel] ;
    }
}


- (void) sendData: (NSData *) packet
{
    NSUInteger size = [packet length] / sizeof(unsigned char);
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


#pragma mark
#pragma mark - read & write callback functions

void readStreamClientCallBack (
                                CFReadStreamRef   stream,
                                CFStreamEventType event,
                                void              *myPtr
                              )
{
    @autoreleasepool
    {
        KMP_CFNetworkingConnection *p_self = (__bridge KMP_CFNetworkingConnection *)myPtr ;
        MDLog(@" %@", p_self);
        //CPacketMemoryManager *pManager = &(p_self->manager) ;
        /*
        if ((event & kCFStreamEventHasBytesAvailable) != 0)
        {
            UInt8 bufferRead[2048] ;
            CFIndex bytesRead = 0 ;
            do
            {
                bytesRead = CFReadStreamRead(stream, bufferRead, sizeof(bufferRead)) ;
                if (bytesRead > 0)
                {
                    NSLog(@"read len %ld", bytesRead) ;
                    pManager->addToBuffer(bufferRead, bytesRead) ;
                    if (!CFReadStreamHasBytesAvailable(stream))
                    {
                        break ;
                    }
                }
            } while (bytesRead > 0) ;
            
            while (1)
            {
                unsigned int len = pManager->getUseBufferLength() ;
                
                if (len > sizeof(BaseNetworkPacket))
                {
                    unsigned char *p = pManager->getBufferPointer() ;
                    NSData *data = [NSData dataWithBytes: p
                                                  length: sizeof(BaseNetworkPacket)] ;
                    KDPacket *packet = [KDPacket deSerialization:data] ;
                    unsigned int packetLen = packet.packet->header.length ;
                    
                    if (len < packetLen)
                    {
                        break ;
                    }
                    
                    data = [NSData dataWithBytes: p
                                          length: packetLen] ;
                    
                    packet = [KDPacket deSerialization:data] ;
                    pManager->removeBuffer(packetLen) ;
                    
                    BaseNetworkPacket *basePacket = [packet packet] ;
                    
                    if (basePacket->header.cmd == Cmd_Text)
                    {
                        TextPacket *textpacket = (TextPacket *)basePacket ;
                        textpacket->text[textpacket->textLen] = '\0' ;
                        [p_self.delegate dataReceived:packet] ;
                    }
                    
                }
                else
                {
                    break ;
                }
            }
        }
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
        {
            NSLog(@"app in background") ;
        }
        
        if ((event & kCFStreamEventErrorOccurred) != 0)
        {
            NSInputStream *s = (__bridge NSInputStream *)stream ;
            NSLog(@"read stream error %@", [s streamError]) ;
            NSThread *thread = [NSThread currentThread] ;
            [thread cancel] ;
        }
        
        if ((event & kCFStreamEventEndEncountered) != 0)
        {
            NSLog(@"A Read Stream Event End!") ;
            NSThread *thread = [NSThread currentThread] ;
            [thread cancel] ;
        }
         */
    }
}


void writeStreamClientCallBack (
                                    CFWriteStreamRef   stream,
                                    CFStreamEventType  type,
                                    void               *clientCallBackInfo
                                )
{
    @autoreleasepool
    {
        MDLog(@"\nclientCallBackInfo %@\n\n\n", clientCallBackInfo);
        
        id mayBeIvar = (__bridge id)clientCallBackInfo;
        KMP_CFNetworkingConnection * _self = nil;
        
        if ( YES == [mayBeIvar isKindOfClass: [KMP_CFNetworkingConnection class]] )
        {
            _self = (KMP_CFNetworkingConnection *) mayBeIvar;
        }
        
        if (type & kCFStreamEventErrorOccurred)
        {
            NSOutputStream *s = (__bridge NSOutputStream *)stream ;
            MDLog(@"\nwrite stream error:\n %@\n\n\n", [s streamError]) ;
            NSThread *thread = [NSThread currentThread] ;
            [thread cancel] ;
            // ???
            //                        if ( repeatCounterForThreadEntry < 2)
            //                        {
            //                            MDLog(@"\ntry to reconnect to server \n\n\n");
            //                            _self.threadNetwork = [[NSThread alloc] initWithTarget: _self
            //                                                                          selector: @selector(threadEntry)
            //                                                                              object: nil] ;
            //                            [_self.threadNetwork performSelector: @selector(start)
            //                                                      withObject: nil
            //                                                      afterDelay: 1.0] ;
            //                            repeatCounterForThreadEntry ++;
            //                        }
            //                        else
            //                        {
            //                            repeatCounterForThreadEntry = 0;
            //                        }
        }
        
        if (type & kCFStreamEventEndEncountered)
        {
            MDLog(@"\nwrite stream end\n\n\n") ;
            NSThread *thread = [NSThread currentThread] ;
            [thread cancel] ;
        }
    }
}


#pragma mark
#pragma mark

- (void) threadEntry
{
    @autoreleasepool
    {
        CFReadStreamRef  readStreamRef  = nil ;
        CFWriteStreamRef writeStreamRef = nil ;
        NSString        *strIp          = [_delegate ipAddress] ;
        uint16_t         port           = [_delegate port] ;
        
        CFStreamCreatePairWithSocketToHost(
                                                NULL,
                                                (__bridge CFStringRef)strIp,
                                                port,
                                                &readStreamRef,
                                                &writeStreamRef
                                           ) ;
        
        CFStreamClientContext myContext =
        {
            0,
            (__bridge void *)self,
            NULL,
            NULL,
            NULL
        };
        
        CFOptionFlags registeredEventsR = kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered ;
        CFOptionFlags registeredEventsW = kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered ;
        
        CFReadStreamSetClient (
                                    readStreamRef,
                                    registeredEventsR,
                                    readStreamClientCallBack,
                                    &myContext
                              ) ;
        
        CFWriteStreamSetClient (
                                    writeStreamRef,
                                    registeredEventsW,
                                    writeStreamClientCallBack,
                                    &myContext
                               ) ;
        
        CFReadStreamScheduleWithRunLoop (
                                            readStreamRef,
                                            CFRunLoopGetCurrent(),
                                            kCFRunLoopDefaultMode
                                         ) ;
        
        CFWriteStreamScheduleWithRunLoop (
                                            writeStreamRef,
                                            CFRunLoopGetCurrent(),
                                            kCFRunLoopDefaultMode
                                          ) ;
        
        self.inputStream  = (__bridge_transfer NSInputStream  *) readStreamRef ;
        //self.inputStream.delegate = self;
        
        self.outputStream = (__bridge_transfer NSOutputStream *) writeStreamRef ;
        //self.outputStream.delegate = self;
        
        BOOL bSetProperty = [_inputStream setProperty: NSStreamNetworkServiceTypeVoIP
                                               forKey: NSStreamNetworkServiceType];
        NSLog(@"set NSStreamNetworkServiceTypeVoIP on read stream %u", bSetProperty) ;
        
        bSetProperty = [_outputStream setProperty: NSStreamNetworkServiceTypeVoIP
                                           forKey: NSStreamNetworkServiceType] ;
        NSLog(@"set NSStreamNetworkServiceTypeVoIP on write stream %u", bSetProperty) ;
        
        [_inputStream  open] ;
        [_outputStream open] ;
        
        dispatch_async (
                        dispatch_get_main_queue(),
                        ^()
                        {
                            [_delegate connectionDidConnect] ;
                            self.networkState = NetworkStateConnected ;
                        }
                        ) ;
        
        while (![_threadNetwork isCancelled])
        {
            SInt32 result = CFRunLoopRunInMode (
                                                    kCFRunLoopDefaultMode,
                                                    4.0,
                                                    true
                                                ) ;
            switch (result)
            {
                case kCFRunLoopRunFinished:
                    NSLog(@"kCFRunLoopRunFinished") ;
                    break;
                    
                case kCFRunLoopRunStopped:
                    NSLog(@"kCFRunLoopRunStopped") ;
                    break ;
                    
                case kCFRunLoopRunTimedOut:
                    NSLog(@"kCFRunLoopRunTimedOut") ;
                    break ;
                    
                case kCFRunLoopRunHandledSource:
                    NSLog(@"kCFRunLoopRunHandledSource") ;
                    break ;
                    
                default:
                    break;
            }
        }
        
        dispatch_async ( dispatch_get_main_queue(),
                        ^()
                        {
                            [_delegate connectionDidDisconnect] ;
                            self.networkState = NetworkStateDisconnect ;
                        }
                        ) ;
        
        [_inputStream  close] ;
        [_outputStream close] ;
        
        _inputStream  = nil ;
        _outputStream = nil ;
        
        MDLog(@"\nthread stoped\n\n\n") ;
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




@end
