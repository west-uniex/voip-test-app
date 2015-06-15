//
//  CFSocketServer.m
//  EchoTcpSvrCFSocket
//
//  Created by Jon Hoffman on 4/19/13.
//  Copyright (c) 2013 Jon Hoffman. All rights reserved.
//

#import "CFSocketServer.h"

#import <CoreFoundation/CFSocket.h>

#include <sys/socket.h>
#include <netinet/in.h>
#import <arpa/inet.h>

#define LISTENQ 1024




typedef NS_ENUM (NSUInteger, CFSocketServerState)
{
    
    LISTEN_FOR_CONNECTION_STATE,
    
    ACCEPT_VOIP_CONNECTION_STATE,
    READ_WRITE_VOIP_STREAM_STATE
    
};



@interface CFSocketServer ()

@property (nonatomic, assign)  CFSocketServerState   thisServerState;
@property (nonatomic, strong)  NSTimer              *timerAcceptVoIPCall;


@end


@implementation CFSocketServer


-(instancetype) initOnPort: (int) port
             andServerType: (CFNetworkServerType) sType
{
    struct sockaddr_in servaddr;
	CFRunLoopSourceRef source;
    const CFSocketContext context = {
                                        0,
                                        (__bridge void *) self,         // void *info;
                                        NULL,
                                        NULL,
                                        NULL
                                    };
	self.errorCode = NOERROR;
    int listenfd = socket (
                                AF_INET,      // int domaine    // #define	AF_INET	    2   /* internetwork: UDP, TCP, etc. */
                                SOCK_STREAM,  // int type       // #define	SOCK_STREAM	1	/* stream socket                */
                                IPPROTO_TCP   // int protocol   // #define	IPPROTO_TCP	6	/* tcp                          */
                           );
    
	if ( listenfd < 0)
    {
        self.self.errorCode = SOCKETERROR;
    }
    else
    {
        //  clean struct sockaddr_in  - Socket address, internet style.
        memset (
                    &servaddr,
                    0,
                    sizeof(servaddr)
                );
        
        servaddr.sin_family      =  AF_INET;
        servaddr.sin_addr.s_addr =  htonl(INADDR_ANY);
        servaddr.sin_port        =  htons(port);
        
        //  bind a name to a socket
        int result = bind (
                             listenfd,                       // int                   socket
                             (struct sockaddr *)&servaddr,   // const struct sockaddr *address
                             sizeof(servaddr)                // socklen_t             address_len
                          );
        if ( result < 0)
        {
            self.self.errorCode = BINDERROR;
        }
        else
        {
            //      listen for connections on a socket
            
            self.thisServerState = LISTEN_FOR_CONNECTION_STATE;
            
            result = listen (
                                listenfd,           //  int socket
                                LISTENQ             //  int backlog            //   #define LISTENQ 1024
                            );
            if ( result < 0)
            {
                self.errorCode = LISTENERROR;
            }
            else
            {
                if (sType == SERVERTYPEECHO)
                {
                    self.sRef = CFSocketCreateWithNative (
                                                            NULL,                       //  CFAllocatorRef allocator
                                                            listenfd,
                                                            kCFSocketAcceptCallBack,
                                                            acceptConnectionEcho,
                                                            &context
                                                         );
                }
                else if (sType == SERVERTYPEIMAGE)
                {
                    self.sRef = CFSocketCreateWithNative (
                                                            NULL,
                                                            listenfd,
                                                            kCFSocketAcceptCallBack,
                                                            acceptConnectionData,
                                                            &context
                                                         );
                }
                else if (sType == SERVERTYPEVOIP)
                {
                    self.sRef = CFSocketCreateWithNative (
                                                            NULL,
                                                            listenfd,
                                                            kCFSocketAcceptCallBack,
                                                            acceptConnectionVoIPCall,
                                                            &context
                                                          );

                
                }
                else
                {
                    self.sRef = NULL;
                }
                
                
                if (self.sRef == NULL)
                {
                    self.errorCode = CFSOCKETCREATEERROR;
                }
                else
                {
                    MDLog(@"\nStarting LEASENING\n\n\n");
                    source = CFSocketCreateRunLoopSource (
                                                            NULL,
                                                            self.sRef,
                                                            0
                                                         );
                    
                    CFRunLoopAddSource (
                                            CFRunLoopGetCurrent(),
                                            source,
                                            kCFRunLoopDefaultMode
                                       );
                    
                    CFRelease(source);
                    
                    CFRunLoopRun();
                }
            }
        }
        
    }
    return self;
}


#pragma mark 
#pragma mark For Echo text server

void acceptConnectionEcho (
                            CFSocketRef             sRef,
                            CFSocketCallBackType    cType,
                            CFDataRef               address,
                            const void              *data,
                            void                    *info
                          )
{

	CFSocketNativeHandle csock = *(CFSocketNativeHandle *)data;
	CFSocketRef          sn;
	CFRunLoopSourceRef   source;
    
    const CFSocketContext context = {0, NULL, NULL, NULL, NULL};
    
	sn = CFSocketCreateWithNative (
                                        NULL,
                                        csock,
                                        kCFSocketDataCallBack,
                                        receiveDataEcho,
                                        &context
                                  );
    
    source = CFSocketCreateRunLoopSource (
                                            NULL,       //  CFAllocatorRef  allocator
                                            sn,         //  CFSocketRef     s
                                            0           //  CFIndex         order
                                         );
    
    CFRunLoopAddSource (
                            CFRunLoopGetCurrent(),
                            source,
                            kCFRunLoopDefaultMode
                       );
    
    CFRelease(source);
    CFRelease(sn);
}


void receiveDataEcho(CFSocketRef sRef, CFSocketCallBackType cType,CFDataRef address, const void *data, void *info)
{
    CFDataRef df = (CFDataRef) data;
    long len     = CFDataGetLength(df);
    
    if(len <= 0)
    {
        return;
    }
    
    UInt8 buf[len];
    CFRange range = CFRangeMake(0,len);
    
    CFDataGetBytes(df, range, buf);
    buf[len]='\0';
    NSString *str = [[NSString alloc] initWithData:(__bridge NSData*)data
                                          encoding:NSASCIIStringEncoding];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIONTEXT object:str];
    
    // Echo back
    
    CFSocketSendData (
                        sRef,
                        address,
                        df,
                        0
                     );
    
}



#pragma mark
#pragma mark For Data server


void acceptConnectionData (
                            CFSocketRef             sRef,
                            CFSocketCallBackType    cType,
                            CFDataRef               address,
                            const void              *data,
                            void                    *info
                          )
{
    NSLog(@"Accepting");
	CFSocketNativeHandle csock = *(CFSocketNativeHandle *)data;
	CFSocketRef sn;
	CFRunLoopSourceRef source;
    
    const CFSocketContext context = {0, NULL, NULL, NULL, NULL};
    
    //CF_EXPORT CFSocketRef	CFSocketCreateWithNative(CFAllocatorRef allocator, CFSocketNativeHandle sock, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context);
    
	sn = CFSocketCreateWithNative (
                                    NULL,                       //  CFAllocatorRef          allocator
                                    csock,                      //  CFSocketNativeHandle    sock
                                    kCFSocketDataCallBack,      //  CFOptionFlags           callBackTypes
                                    receiveDataData,            //  CFSocketCallBack        callout
                                    &context                    //  const CFSocketContext   *context
                                 );
    
    source = CFSocketCreateRunLoopSource (
                                            NULL,
                                            sn,
                                            0
                                         );
    
    CFRunLoopAddSource (
                            CFRunLoopGetCurrent(),
                            source,
                            kCFRunLoopDefaultMode
                       );
    
    CFRelease(source);
    CFRelease(sn);
}

void receiveDataData (
                        CFSocketRef            sRef,
                        CFSocketCallBackType   cType,
                        CFDataRef              address,
                        const void             *data,
                        void                   *info
                     )
{
    
    CFDataRef df       = (CFDataRef)         data;
    NSData    *imgData = (__bridge NSData *) df;
    
    NSLog(@"Receiving data: %zu", imgData.length);
    
    struct sockaddr_in addr = *(struct sockaddr_in *) CFDataGetBytePtr(address);
    char buf[INET6_ADDRSTRLEN];
    
    const char *ipAddress = inet_ntop (
                                        AF_INET,
                                        &addr.sin_addr,
                                        buf,
                                        sizeof(buf)
                                     );
    NSString *connStr = [NSString stringWithFormat:@"Connection from %s, port %d", ipAddress, ntohs(addr.sin_port) ];
    NSLog(@"%@", connStr);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATIONIMAGE
                                                        object: imgData];
}


#pragma mark
#pragma mark For VoIP server

void acceptConnectionVoIPCall (
                               CFSocketRef             sRef,
                               CFSocketCallBackType    cType,
                               CFDataRef               address,
                               const void              *data,
                               void                    *info
                           )
{
    
    // make ring
    CFSocketServer __weak *weakSelf = (__bridge CFSocketServer *) info;
    
    
    dispatch_async (
                        dispatch_get_main_queue(),
                        ^(void)
                         {
                             CFSocketServer *strongSelf = weakSelf;
                             [weakSelf.delegate needAcceptConnectionVoIPCall: strongSelf] ;
                         }
                   ) ;

    
    CFSocketServer *strongSelf = weakSelf;
    
    strongSelf.timerAcceptVoIPCall = [NSTimer scheduledTimerWithTimeInterval: 30.0
                                                                      target: strongSelf
                                                                    selector: nil
                                                                    userInfo: nil
                                                                     repeats: NO];
    do
    {
        //    check  timer
        
        if (strongSelf.timerAcceptVoIPCall.isValid == NO)
        {
            return;
        }
        
    } while (strongSelf.thisServerState == LISTEN_FOR_CONNECTION_STATE );
    
    if (strongSelf.timerAcceptVoIPCall.isValid == YES)
    {
        [strongSelf.timerAcceptVoIPCall invalidate];
        strongSelf.timerAcceptVoIPCall = nil;
    }
    
    //
    
    MDLog(@"\nAccepting\n\n");
    
    strongSelf.thisServerState = ACCEPT_VOIP_CONNECTION_STATE;
    
    CFSocketNativeHandle csock = *(CFSocketNativeHandle *)data;
    CFSocketRef sn;
    CFRunLoopSourceRef source;
    
    const CFSocketContext context = {0, NULL, NULL, NULL, NULL};
    
    //CF_EXPORT CFSocketRef	CFSocketCreateWithNative(CFAllocatorRef allocator, CFSocketNativeHandle sock, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context);
    
    sn = CFSocketCreateWithNative (
                                   NULL,                       //  CFAllocatorRef          allocator
                                   csock,                      //  CFSocketNativeHandle    sock
                                   kCFSocketDataCallBack,      //  CFOptionFlags           callBackTypes
                                   receiveDataData,            //  CFSocketCallBack        callout
                                   &context                    //  const CFSocketContext   *context
                                   );
    
    source = CFSocketCreateRunLoopSource (
                                          NULL,
                                          sn,
                                          0
                                          );
    
    CFRunLoopAddSource (
                        CFRunLoopGetCurrent(),
                        source,
                        kCFRunLoopDefaultMode
                        );
    
    CFRelease(source);
    CFRelease(sn);
}





#pragma mark
#pragma mark clean

-(void)dealloc
{
    if (self.sRef != NULL)
    {
        CFSocketInvalidate(self.sRef);
        CFRelease(self.sRef);
        self.sRef = NULL;
    }
}

#pragma mark
#pragma mark   VoIP server type methods

- (void) acceptConnectionToVoIPServer

{
    self.thisServerState = ACCEPT_VOIP_CONNECTION_STATE;
}


@end
