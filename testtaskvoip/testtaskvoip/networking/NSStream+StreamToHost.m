//
//  NSStream+StreamToHost.m
//  
//
//  Created by Mykola on 6/6/15.
//
//

#import "NSStream+StreamToHost.h"

@implementation NSStream (StreamToHost)

+ (void)readStreamFromHostNamed: (NSString           *) hostName
                           port: (NSInteger           ) port
                     readStream: (out NSInputStream **) readStreamPtr
{
    assert(hostName != nil);
    assert((port > 0) && (port < 65536));
    assert((readStreamPtr != NULL));
    
    CFReadStreamRef readStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(
                                       NULL,
                                       (__bridge CFStringRef) hostName,
                                       (unsigned int)         port,
                                       ((readStreamPtr != NULL) ? &readStream : NULL),
                                       NULL
                                       );
    
    if (readStreamPtr != NULL)
    {
        *readStreamPtr  = CFBridgingRelease(readStream);
    }
}



+ (void)writeStreamFromHostNamed: (NSString           *) hostName
                            port: (NSInteger           ) port
                      readStream: (out NSInputStream **) writeStreamPtr
{
    assert(hostName != nil);
    assert((port > 0) && (port < 65536));
    assert((writeStreamPtr != NULL));
    
    CFWriteStreamRef writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(
                                       NULL,
                                       (__bridge CFStringRef) hostName,
                                       (unsigned int)         port,
                                       NULL,
                                       ((writeStreamPtr != NULL) ? &writeStream : NULL )
                                       );
    
    if (writeStreamPtr != NULL)
    {
        *writeStreamPtr  = CFBridgingRelease(writeStream);
    }
}



//      original from Apple ...

+ (void) createReadAndWriteStreamsToHostNamed: (NSString            *) hostName
                                         port: (NSInteger            ) port
                                  inputStream: (out NSInputStream  **) inputStreamPtr
                                 outputStream: (out NSOutputStream **) outputStreamPtr
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert(hostName != nil);
    assert( (port > 0) && (port < 65536) );
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
    //    void CFStreamCreatePairWithSocketToHost (
    //                                                  CFAllocatorRef      alloc,
    //                                                  CFStringRef         host,
    //                                                  UInt32              port,
    //                                                  CFReadStreamRef     *readStream,
    //                                                  CFWriteStreamRef    *writeStream
    //                                             );
    
    
    CFStreamCreatePairWithSocketToHost (
                                            NULL,
                                            (__bridge CFStringRef)       hostName,
                                            (unsigned         int)       port,
                                            ((inputStreamPtr  != NULL) ? &readStream  : NULL),
                                            ((outputStreamPtr != NULL) ? &writeStream : NULL)
                                       );
    
    if (inputStreamPtr != NULL)
    {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    
    if (outputStreamPtr != NULL)
    {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}





@end
