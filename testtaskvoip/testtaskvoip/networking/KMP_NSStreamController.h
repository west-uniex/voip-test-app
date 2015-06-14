//
//  KMP_NSStreamController.h
//  testtaskvoip
//
//  Created by Mykola on 6/6/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import "KMP_NetworkingController.h"

@interface KMP_NSStreamController : KMP_NetworkingController

@property (nonatomic, strong) NSInputStream    *inputStream ;

@property (nonatomic, strong) NSOutputStream   *outputStream ;


- (void) sendData: (NSData *) packet;


@end



