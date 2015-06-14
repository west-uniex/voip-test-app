//
//  KMP_NetworkingController.h
//  testtaskvoip
//
//  Created by Mykola on 6/6/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef  NS_ENUM(NSUInteger, KMP_NetworkingControllerType)
{
    SERVER,
    CLIENT
};


@interface KMP_NetworkingController : NSObject

@property(nonatomic, strong, readonly)	NSString    		         *urlString;

@property(nonatomic, readonly)          KMP_NetworkingControllerType  controllerType;

//@property(nonatomic,         readonly)	NSInteger			         portNumber;

- (id)initWithURLString: (NSString                    *) newUrlString
         controllerType: (KMP_NetworkingControllerType ) theControllerType;

- (void) start;

- (void) stop;

- (void) loadCurrentStatusForConnectingWithURL: (NSURL    *) url;

//- (LLNNetworkingResult *) parseResultString: (NSString *) resultString;



@end
