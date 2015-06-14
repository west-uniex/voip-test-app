//
//  CFSocketClient.m
//  EchoTcpClientCFSocket
//
//  Created by Jon Hoffman on 4/19/13.
//  Copyright (c) 2013 Jon Hoffman. All rights reserved.
//

#import "CFSocketClient.h"
#import <CoreFoundation/CFSocket.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define LISTENQ 1024

@implementation CFSocketClient
@synthesize errorcde;

-(id)initWithAddr: (NSString *) addr
          andPort: (int       ) port
{
    
    self.sockfd = CFSocketCreate (
                                    NULL,
                                    AF_INET,
                                    SOCK_STREAM,
                                    IPPROTO_TCP,
                                    0,
                                    NULL,
                                    NULL
                                 );
    if (self.sockfd == NULL)
    {
        errorcde = SOCKETERROR;
    }
    else
    {
        /* Set the port and address we want to listen on */
        struct sockaddr_in servaddr;
        memset (
                    &servaddr,
                    0,
                    sizeof(servaddr)
               );
        
        servaddr.sin_len    = sizeof(servaddr);
        servaddr.sin_family = AF_INET;
        servaddr.sin_port   = htons(port);
        
        inet_pton (
                    AF_INET,
                    [addr cStringUsingEncoding: NSUTF8StringEncoding],
                    &servaddr.sin_addr
                  );
        
        CFDataRef connectAddr = CFDataCreate (
                                                NULL,
                                                (unsigned char *)&servaddr,
                                                sizeof(servaddr)
                                             );
     
        if (connectAddr == NULL)
        {
            errorcde = CONNECTERROR;
        }
        else
        {
            CFSocketConnectToAddress (
                                        self.sockfd,
                                        connectAddr,
                                        30
                                     );
        }
    }
    
    return self;
}

-(ssize_t) writtenToSocket: (CFSocketRef) sockfdNum
                  withChar: (NSString  *) vptr
{
    
    UInt8 buffer[MAXLINE];
    
    CFSocketNativeHandle sock = CFSocketGetNative (self.sockfd);
    const char *mess          = [vptr cStringUsingEncoding: NSUTF8StringEncoding];
    
    NSLog(@"%s\n\n", mess);
    send (
            sock,
            mess,
            strlen(mess) + 1,
            0
         );
    
    recv (
            sock,
            buffer,
            sizeof(buffer),
            0
         );
    
    NSLog(@"%s", buffer);
    return sizeof(buffer);
}

-(ssize_t) sendDataToSocket: (CFSocketRef) lsockfd
                   withData: (NSData    *) data;
{
    
    NSLog(@"sending");
    ssize_t n;
    const UInt8 *buf          = (const UInt8 *)[data bytes];
    CFSocketNativeHandle sock = CFSocketGetNative(lsockfd);
    
    //  ssize_t	send(int, const void *, size_t, int) __DARWIN_ALIAS_C(send);
    size_t length_data = [data length];
    n = send (
                sock,
                buf,
                length_data,
                0
              );
    
    if ( n <= 0)
    {
        errorcde = WRITEERROR;
        // ???
        n = n - 1;
    }
    else
    {
        errorcde = NOERRROR;
    }

    NSLog(@"sent to server: %zu byte Done \n\n", length_data);  //   size_t ~ unsigned long
    CFSocketInvalidate(lsockfd);
    CFRelease(lsockfd);
    lsockfd = NULL;
    return n;
    
}

-(void)dealloc
{
    if (self.sockfd != nil)
    {
        //CFSocketInvalidate(self.sockfd);
        //CFRelease(self.sockfd);
        self.sockfd = NULL;
    }
}


@end
