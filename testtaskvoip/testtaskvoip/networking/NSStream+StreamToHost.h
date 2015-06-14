//
//  NSStream+StreamToHost.h
//  
//
//  Created by Mykola on 6/6/15.
//
//

#import <Foundation/Foundation.h>

@interface NSStream (StreamToHost)


+ (void) readStreamFromHostNamed: (NSString *)hostName
                            port: (NSInteger)port
                      readStream: (out NSInputStream **)readStreamPtr;

+ (void) writeStreamFromHostNamed: (NSString           *) hostName
                             port: (NSInteger           ) port
                       readStream: (out NSInputStream **) writeStreamPtr;


+ (void) createReadAndWriteStreamsToHostNamed: (NSString            *) hostName
                                         port: (NSInteger            ) port
                                  inputStream: (out NSInputStream  **) inputStreamPtr
                                 outputStream: (out NSOutputStream **) outputStreamPtr;



@end

/*
 
 NSString *urlStr = @"http://192.168.0.108";
 NSURL *website = [NSURL URLWithString:urlStr];
 CFReadStreamRef readStream;
 CFWriteStreamRef writeStream;
 CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)[website host], 1234, &readStream, &writeStream);
 
 CFReadStreamSetProperty(readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
 CFWriteStreamSetProperty(writeStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
 
 NSInputStream *inputStream = (NSInputStream *)readStream;
 NSOutputStream *outputStream = (NSOutputStream *)writeStream;
 [inputStream setDelegate:self];
 [inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType] ;
 [outputStream setDelegate:self];
 [outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType] ;
 [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
 [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
 [inputStream open];
 [outputStream open];
 
 */