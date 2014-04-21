//
//  ofxiOSFTP.m
//
//  Created by Roy Macdonald on 8/11/12.
//

#include "ofxiOSFTP.h"
//*
ofEvent<ofxiOSFTPEvent>ofxiOSFTPEventDispatcher;
ofxiOSFTP::ofxiOSFTP(string host, string user, string pass){
    this->host = host;
    this->user = user;
    this->pass = pass;
    whiteRaccoon = [[ofxiOSFTPDelegate alloc]init :[NSString stringWithCString:host.c_str()] userName:[NSString stringWithCString:user.c_str()] password:[NSString stringWithCString:pass.c_str()]];
}
ofxiOSFTP::~ofxiOSFTP(){
    [whiteRaccoon release];
}

void ofxiOSFTP::upload(string localFile, string remotePath){
       [whiteRaccoon uploadFile: [NSString stringWithCString:localFile.c_str()] remotePath:[NSString stringWithCString:remotePath.c_str()]];
}
void ofxiOSFTP::list(){
    [whiteRaccoon listDirectoryContents];
}
string ofxiOSFTP::getUserName(){
    return user;
}
string ofxiOSFTP::getPassword(){
    return pass;
}
string ofxiOSFTP::getHostName(){
    return host;
}

void ofxiOSFTP::uploadUIImage(UIImage * img, string remotePath){
    [whiteRaccoon uploadUIImage:img remotePath:[NSString stringWithCString:remotePath.c_str()]];
    
}


//---------------------------------------------------------------------------
//          obj-C implementation
//---------------------------------------------------------------------------
@implementation ofxiOSFTPDelegate 

-(id) init: (NSString *) h userName:(NSString *) u password:(NSString *)p{
    
    if(self = [super init]){			
        
        self->host = [NSString stringWithString:h];
        self->user = [NSString stringWithString:u];
        self->pass = [NSString stringWithString:p];
        [self->host retain];
        [self->user retain];
        [self->pass retain];
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
	ofxiOSFTPEvent event(request.type);
	event.bRequestCompleted = true;
	ofNotifyEvent(ofxiOSFTPEventDispatcher, event);
	
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
-(void) uploadFile:(NSString *)localFilePath  remotePath:(NSString *)remoteFilePath{
	if([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]){
		[self upload: [[NSFileManager defaultManager] contentsAtPath:localFilePath] remotePath:remoteFilePath];		
	}else{
		NSLog(@"File does not exist.");
	}
}
- (void) upload: (NSData *)data remotePath:(NSString *)remote {    
    WRRequestUpload * upload = [[WRRequestUpload alloc] init];
    upload.delegate = self;
    
    //for anonymous login just leave the username and password nil
    // NSLog(@" ftp upload: %@ %@ %@", host, user, pass);          
    // NSLog(@" ftp upload: %@ %@ %@", self->host, self->user, self->pass); 
    
     upload.hostname = self->host;
     upload.username = self->user;
     upload.password = self->pass;
     
     
    //we set our data
    
    upload.sentData = data;
    
    upload.path =  remote;
  // cout   << [ upload.path UTF8String] << endl;
   
    
    //we start the request
    [upload start];
    
}


-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"Request failed! %@", request.error.message);
    
    ofxiOSFTPEvent event(request.type);
    event.bRequestFailed = true;
    ofNotifyEvent(ofxiOSFTPEventDispatcher, event);
    
}

-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
    
    //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten 
    //'request' is the request that intended to create the file
    return YES;
    
}

@end
//*/