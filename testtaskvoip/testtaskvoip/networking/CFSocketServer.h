//
//  CFSocketServer.h
//  EchoTcpSvrCFSocket
//
//  Created by Jon Hoffman on 4/19/13.
//  Copyright (c) 2013 Jon Hoffman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CFNetworkServerErrorCode)
{
    NOERROR,
    SOCKETERROR,
    BINDERROR,
    LISTENERROR,
    CFSOCKETCREATEERROR,
    ACCEPTINGERROR
};

typedef  NS_ENUM(NSUInteger, CFNetworkServerType)
{
    SERVERTYPEECHO,
    SERVERTYPEIMAGE,
    SERVERTYPEVOIP
};


#define NOTIFICATIONTEXT  @"posttext"
#define NOTIFICATIONIMAGE @"postimage"


@class CFSocketServer;

@protocol CFSocketServerDelegate <NSObject>

@optional

- (void) needAcceptConnectionVoIPCall: (CFSocketServer *) theCFSocketServer;

@end






@interface CFSocketServer : NSObject

@property (nonatomic)                  int                        errorCode;
@property (nonatomic)                  CFSocketRef                sRef;

@property (nonatomic, weak, readonly) id <CFSocketServerDelegate> delegate;

//- (instancetype)    initOnPort: (int) port
//                 andServerType: (CFNetworkServerType) serverType;

- (instancetype)    initOnPort: (int)                         port
                     delegate : (id <CFSocketServerDelegate>) delegate
                 andServerType: (CFNetworkServerType)         serverType;


#pragma mark   VoIP server type methods

- (void) acceptConnectionToVoIPServer;


@end

/*  hints ...
 
struct CFSocketContext
{
    CFIndex version;
    void *info;
    CFAllocatorRetainCallBack retain;
    CFAllocatorReleaseCallBack release;
    CFAllocatorCopyDescriptionCallBack copyDescription;
};
 
 */



