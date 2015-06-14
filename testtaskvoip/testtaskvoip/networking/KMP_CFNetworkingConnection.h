//
//  KMP_CFNetworkingConnection.h
//  testtaskvoip
//
//  Created by Mykola on 6/1/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Connection <NSObject>

- (BOOL) isConnect ;
- (void) connect ;
- (void) closeConnection ;
- (void) sendData: (NSData *) packet; //(KMP_Packet *)packet ;

@end

@protocol ConnectionDelegate <NSObject>

@required

- (NSString *) ipAddress ;

- (uint16_t  ) port ;

- (void)dataReceived: (NSData *) packet; //(KMP_Packet *) packet ;

@optional

- (void) connectionDidConnect ;

- (void) connectionDidDisconnect ;

- (void) connectionFailWithError:(int)error ;

@end



@interface KMP_CFNetworkingConnection : NSObject <
                                                    Connection,
                                                    NSStreamDelegate
                                                 >

#pragma mark
#pragma mark  designated initializer

@property (nonatomic, weak, readonly) id<ConnectionDelegate> delegate ;

- (id)initWithDelegate: (id<ConnectionDelegate>)aDelegate ;





@end






