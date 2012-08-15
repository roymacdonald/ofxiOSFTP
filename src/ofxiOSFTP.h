//
//  ofxiOSFTP.h
//  registro
//
//  Created by Roy Macdonald on 8/11/12.
//  Copyright (c) 2012 micasa. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "WhiteRaccoon.h"
#include "ofMain.h"

#pragma once
//*
@interface ofxiOSFTPDelegate : NSObject<WRRequestDelegate> 
{
    NSString * host;
    NSString * user;
    NSString * pass;
}    
-(id) init: (NSString *) h userName:(NSString *) u password:(NSString *)p;
-(void) upload:(NSData *)data  remotePath:(NSString *)remote;
-(void) requestCompleted:(WRRequest *) request;
    
-(void) requestFailed:(WRRequest *) request;    
-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request ;
-(void) listDirectoryContents;
-(void) uploadUIImage: (UIImage * )img remotePath:(NSString * )path;

@end
//*/

class ofxiOSFTP {
public:
    ofxiOSFTP(string host, string user ="", string pass ="");
    ~ofxiOSFTP();
    
    void upload(string localFile, string remotePath);
    void uploadUIImage(UIImage * img, string remotePath);
    void list();
    string getUserName();
    string getPassword();
    string getHostName();
private:
    string user, pass, host;
    ofxiOSFTPDelegate * whiteRaccoon;
	

};


class ofxiOSFTPEvent : public ofEventArgs{
public:
	ofxiOSFTPEvent(WRRequestTypes type, bool completed =false, bool failed = false):bRequestCompleted(completed), bRequestFailed(failed), requestType(type){}
	bool bRequestCompleted;
	bool bRequestFailed;
    WRRequestTypes requestType;
};

extern ofEvent<ofxiOSFTPEvent>ofxiOSFTPEventDispatcher;



/*
 
 typedef enum {
 kWRUploadRequest,
 kWRDownloadRequest,
 kWRDeleteRequest,
 kWRCreateDirectoryRequest,
 kWRListDirectoryRequest
 } WRRequestTypes;

//*/



