//  WhiteRaccoon
//
//  Created by Valentin Radu on 8/23/11.
//  Copyright 2011 Valentin Radu. All rights reserved.

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.



#ifdef DEBUG
#	define InfoLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define InfoLog(...)
#endif


#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@class WRRequest;
@class WRRequestQueue;
@class WRRequestError;
@class WRRequestListDirectory;

/*======================================================Global Constants, Variables, Structs and Enums============================================================*/

typedef enum {
    kWRUploadRequest,
	kWRDownloadRequest,
    kWRDeleteRequest,
    kWRCreateDirectoryRequest,
	kWRListDirectoryRequest
} WRRequestTypes;


typedef enum {
    kWRFTP
} WRSchemes;


typedef enum {
    kWRDefaultBufferSize = 32768
} WRBufferSizes;


typedef enum {
    kWRDefaultTimeout = 30
} WRTimeouts;


typedef struct WRStreamInfo {
    
    NSOutputStream    *writeStream;    
    NSInputStream     *readStream;
    UInt32            bytesConsumedThisIteration;    
    UInt32            bytesConsumedInTotal;
    SInt64            size;
    UInt8             buffer[kWRDefaultBufferSize];
    
} WRStreamInfo;









/*======================================================WRRequestDelegate============================================================*/

@protocol WRRequestDelegate  <NSObject>

@required
-(void) requestCompleted:(WRRequest *) request;
-(void) requestFailed:(WRRequest *) request;

@optional
-(BOOL) shouldOverwriteFileWithRequest: (WRRequest *) request;


@end












/*======================================================WRQueueDelegate============================================================*/

@protocol WRQueueDelegate  <WRRequestDelegate>

@required
-(void) queueCompleted:(WRRequestQueue *)queue;


@end






/*======================================================WRBase============================================================*/
//Abstract class, do not instantiate
@interface WRBase : NSObject {
@protected 
    NSString * path;
    NSString * hostname;
}

@property (nonatomic, retain) NSString * username;
@property (nonatomic, assign) WRSchemes schemeId;
@property (nonatomic, readonly) NSString * scheme;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * hostname;
@property (nonatomic, readonly) NSString * credentials;
@property (nonatomic, readonly) NSURL * fullURL;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, assign) BOOL passive;
@property (nonatomic, retain) WRRequestError * error;

-(void) start;
-(void) destroy;

+(NSDictionary *) cachedFolders;
+(void) addFoldersToCache:(NSArray *) foldersArray forParentFolderPath:(NSString *) key;

@end









/*======================================================WRRequest============================================================*/

@interface WRRequest : WRBase {
    
}

@property (nonatomic, retain) WRRequest * nextRequest;
@property (nonatomic, retain) WRRequest * prevRequest;
@property (nonatomic, readonly) WRRequestTypes type;
@property (nonatomic, retain) id<WRRequestDelegate> delegate;
@property (nonatomic, readonly) WRStreamInfo * streamInfo;
@property (nonatomic, assign) BOOL didManagedToOpenStream;


@end









/*======================================================WRRequestDownload============================================================*/

@interface WRRequestDownload : WRRequest<NSStreamDelegate> {
  
}

@property (nonatomic, retain) NSData * receivedData;

@end










/*======================================================WRRequestUpload============================================================*/

@interface WRRequestUpload : WRRequest<WRRequestDelegate, NSStreamDelegate> {
    
}

@property (nonatomic, retain) WRRequestListDirectory * listrequest;
@property (nonatomic, retain) NSData * sentData;

@end










/*======================================================WRRequestDelete============================================================*/

@interface WRRequestDelete : WRRequest<NSStreamDelegate> {
    BOOL isDirectory;
}

@end









/*======================================================WRRequestCreateDirectory============================================================*/

@interface WRRequestCreateDirectory : WRRequestUpload<NSStreamDelegate> {
    
}

@end










/*======================================================WRRequestListDir============================================================*/

@interface WRRequestListDirectory : WRRequestDownload<NSStreamDelegate> {
   
}

@property (nonatomic, retain) NSArray * filesInfo;


@end











/*======================================================WRRequestQueue============================================================*/

//  Used to add requests (read, write) to a queue.
//  The request will be sent to the server in the order in which they were added.
//  If an error occures on one of the operations

@interface WRRequestQueue : WRBase<WRRequestDelegate> {
   @private
    WRRequest * headRequest;
    WRRequest * tailRequest;
    
}

@property (nonatomic, retain) id<WRQueueDelegate> delegate;

-(void) addRequest:(WRRequest *) request;
-(void) addRequestInFront:(WRRequest *) request;
-(void) addRequestsFromArray: (NSArray *) array;
-(void) removeRequestFromQueue:(WRRequest *) request;

@end






typedef enum {
    //client errors
    kWRFTPClientHostnameIsNil = 901,
    kWRFTPClientCantOpenStream = 902,
    kWRFTPClientCantWriteStream = 903,
    kWRFTPClientCantReadStream = 904,
    kWRFTPClientSentDataIsNil = 905,    
    kWRFTPClientFileAlreadyExists = 907,
    kWRFTPClientCantOverwriteDirectory = 908,
    kWRFTPClientStreamTimedOut = 909,
    
    // 400 FTP errors
    kWRFTPServerAbortedTransfer = 426,
    kWRFTPServerResourceBusy = 450,
    kWRFTPServerCantOpenDataConnection = 425,
    
    // 500 FTP errors
    kWRFTPServerUserNotLoggedIn = 530,
    kWRFTPServerFileNotAvailable = 550,
    kWRFTPServerStorageAllocationExceeded = 552,
    kWRFTPServerIllegalFileName = 553,
    kWRFTPServerUnknownError
    
} WRErrorCodes;




/*======================================================WRRequestError============================================================*/

@interface WRRequestError : NSObject {
    
}

@property (nonatomic, assign) WRErrorCodes errorCode;
@property (nonatomic, readonly) NSString * message;

-(WRErrorCodes) errorCodeWithError:(NSError *) error;
@end



