//
//  KMP_NetworkingController.m
//  testtaskvoip
//
//  Created by Mykola on 6/6/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import "KMP_NetworkingController.h"

@interface KMP_NetworkingController ()

#pragma mark
#pragma mark    make readonly properties writeable in class implementation

@property(nonatomic, strong, readwrite)	NSString	*urlString;
@property(nonatomic,         readwrite)	NSInteger	portNumberOfDestinationURL;

@end


@implementation KMP_NetworkingController


#pragma mark
#pragma mark    designated initializer

//- (id)initWithURLString: (NSString *) newUrlString
//                   port: (NSInteger ) newPortNumber
//{
//    self = [super init];
//    
//    if (self != nil)
//    {
//        _urlString  = newUrlString;
//        _portNumber = newPortNumber;
//    }
//    
//    return self;
//}

- (id)initWithURLString: (NSString                    *) newUrlString
         controllerType: (KMP_NetworkingControllerType ) theControllerType
{
    self = [super init];
    
    if (self != nil)
    {
        _urlString      = newUrlString;
        _controllerType = theControllerType;
        
        if (theControllerType == CLIENT)
        {
            _portNumberOfDestinationURL = 5060;
        }
    }
    
    return self;
}

- (void)start
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%li", self.urlString, (long)self.portNumberOfDestinationURL]];
    
    NSThread *backgroundThread = [[NSThread alloc] initWithTarget: self
                                                         selector: @selector( loadCurrentStatusForConnectingWithURL: )
                                                           object: url];
    [backgroundThread start];
}




- (void) loadCurrentStatusForConnectingWithURL: (NSURL *) url
{
    MDLog(@"Warning: this loadCurrentStatus: implementation doesn't do anything, please use a subclass.\n\n\n");
}


- (void) stop

{
    MDLog(@"Warning: this loadCurrentStatus: implementation doesn't do anything, please use a subclass.\n\n\n");
}



@end
