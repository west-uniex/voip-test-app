//
//  CFNetworkUtilities.h
//  CFHostTest
//
//  Created by Jon Hoffman on 4/18/13.
//  Copyright (c) 2013 Jon Hoffman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CFNetworkingErrorCode) {
    NOERROR,
    HOSTRESOLUTIONERROR,
    ADDRESSRESOLUTIONERROR
};

@interface CFNetworkUtilities : NSObject


@property int errorCode;

-(NSArray *)addressesForHostname:(NSString *)hostname;
-(NSArray *)hostnamesForAddress:(NSString *)address;


@end
