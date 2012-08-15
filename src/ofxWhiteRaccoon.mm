//
//  ofxWhiteRaccoon.m
//  registro
//
//  Created by Roy Macdonald on 8/11/12.
//  Copyright (c) 2012 micasa. All rights reserved.
//

#include "ofxWhiteRaccoon.h"
//*
ofEvent<ofxWhiteRaccoonEvent>ofxWhiteRaccoonEventDispatcher;
ofxWhiteRaccoon::ofxWhiteRaccoon(string host, string user, string pass){
    this->host = host;
    this->user = user;
    this->pass = pass;
    whiteRaccoon = [[ofxWhiteRaccoonDelegate alloc]init :[NSString stringWithCString:host.c_str()] userName:[NSString stringWithCString:user.c_str()] password:[NSString stringWithCString:pass.c_str()]];
}
ofxWhiteRaccoon::~ofxWhiteRaccoon(){
    [whiteRaccoon release];
}

void ofxWhiteRaccoon::upload(string localFile, string remotePath){
 //   [whiteRaccoon upload: [NSString stringWithCString:localFile.c_str()] remotePath:[NSString stringWithCString:remotePath.c_str()]];
}
void ofxWhiteRaccoon::list(){
    [whiteRaccoon listDirectoryContents];
}
string ofxWhiteRaccoon::getUserName(){
    return user;
}
string ofxWhiteRaccoon::getPassword(){
    return pass;
}
string ofxWhiteRaccoon::getHostName(){
    return host;
}

void ofxWhiteRaccoon::uploadUIImage(UIImage * img, string remotePath){
[whiteRaccoon uploadUIImage:img remotePath:[NSString stringWithCString:remotePath.c_str()]];

}


//*/
//*
@implementation ofxWhiteRaccoonDelegate 
     
-(id) init: (NSString *) h userName:(NSString *) u password:(NSString *)p{
    
    if(self = [super init]){			
        
        self->host = [NSString stringWithString:h];
        self->user = [NSString stringWithString:u];
        self->pass = [NSString stringWithString:p];
        NSLog(@" ftp init: %@ %@ %@", self->host, self->user, self->pass); 
	}
	return self;
}

- (void) listDirectoryContents{
    WRRequestListDirectory * listDir = [[WRRequestListDirectory alloc] init];
    listDir.delegate = self;
    
    
    listDir.path = @"/";
    
    listDir.hostname = self->host;
    listDir.username = self->user;
    listDir.password = self->pass;
    
    
    [listDir start];
    
}

-(void) requestCompleted:(WRRequest *) request{
    
    //called after 'request' is completed successfully
	ofxWhiteRaccoonEvent event(request.type);
	event.bRequestCompleted = true;
	ofNotifyEvent(ofxWhiteRaccoonEventDispatcher, event);
	
    NSLog(@"%@ completed!", request);
  /*  
    //we cast the request to list request
    WRRequestListDirectory * listDir = (WRRequestListDirectory *)request;
    
    //we print each of the files name
    for (NSDictionary * file in listDir.filesInfo) {
        NSLog(@"%@", [file objectForKey:(id)kCFFTPResourceName]);            
    }
    //*/
}
-(void) uploadUIImage: (UIImage * )img remotePath:(NSString * )path{
   // UIImage * ourImage = [UIImage imageWithCIImage:img];
    NSData * ourImageData = UIImageJPEGRepresentation(img, 100);
    NSLog(@" %f %f", img.size.width, img.size.height);
    [self upload:ourImageData remotePath:path];   
}
     
     - (void) upload: (NSData *)data remotePath:(NSString *)remote {
         
         WRRequestUpload * upload = [[WRRequestUpload alloc] init];
         upload.delegate = self;
         
         //for anonymous login just leave the username and password nil
        // NSLog(@" ftp upload: %@ %@ %@", host, user, pass);          
          // NSLog(@" ftp upload: %@ %@ %@", self->host, self->user, self->pass); 
         /*
         upload.hostname = self->host;
         upload.username = self->user;
         upload.password = self->pass;
        //*/
         upload.hostname = @"Roy-Macdonalds-MacBook-Pro.local";
         upload.username = @"roy";
         upload.password = @"panopticon";

         //we set our data
         
         upload.sentData = data;
         
         upload.path =  remote;
         cout   << [ upload.path UTF8String] << endl;
         // @"/space.jpg";
         
         //we start the request
         [upload start];
        
     }

     
     -(void) requestFailed:(WRRequest *) request{
         
         //called after 'request' ends in error
         //we can print the error message
         NSLog(@"Request failed! %@", request.error.message);
         
         ofxWhiteRaccoonEvent event(request.type);
         event.bRequestFailed = true;
         ofNotifyEvent(ofxWhiteRaccoonEventDispatcher, event);
         
     }
     
     -(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
         
         //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten 
         //'request' is the request that intended to create the file
         return YES;
         
     }
     
@end
//*/