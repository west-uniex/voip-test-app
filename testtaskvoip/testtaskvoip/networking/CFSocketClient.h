//
//  CFSocketClient.h
//  EchoTcpClientCFSocket
//
//  Created by Jon Hoffman on 4/19/13.
//  Copyright (c) 2013 Jon Hoffman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CFNetworkClientErrorCode) {
    NOERRROR,
    SOCKETERROR,
    CONNECTERROR,
    READERROR,
    WRITEERROR
};

#define MAXLINE 4096

@interface CFSocketClient : NSObject

@property (nonatomic) int         errorcde;
@property (nonatomic) CFSocketRef sockfd;

-(id)initWithAddr: (NSString *) addr
          andPort: (int       ) port;

-(ssize_t) sendDataToSocket: (CFSocketRef) lsockfd
                   withData: (NSData    *) data;

@end
