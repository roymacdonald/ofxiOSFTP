#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup(){	
	ofxAccelerometer.setup();
    bSettingsLoaded = false;
	loadSettings();
    
    camera = NULL;
    cameraImg = NULL;
    fotoLista = false;
    
    font.loadFont("verdana.ttf", 21, true, true);
	font.setLineHeight(34.0f);
	font.setLetterSpacing(1.035);

    font2.loadFont("verdana.ttf", 24, true, true);
	font2.setLineHeight(64.0f);
	font2.setLetterSpacing(1.035);

    
    setupButtons();
    
    ftp = new ofxiOSFTP(ftpHost, ftpUser, ftpPass); //here we initialate our ftp client
   // ftp->list(); 

    photoNum= 0;
    
    ofAddListener(ofxiOSFTPEventDispatcher , this, &testApp::ftpRequestListener); // a listener is registeres so we can know when the ftp tasks are completed.
}
//--------------------------------------------------------------
void testApp:: setupButtons(){
    //int x = (ofGetWidth() - anchoTexto)/2.0f;
    int x = ofGetWidth()*0.1;
    anchoTexto = ofGetWidth()*0.8;
    
    buttonFoto.setButton(x, margenesbutton, anchoTexto, int( 4*anchoTexto/3.0f));
    buttonFoto.setFont(&font);
    buttonFoto.setTexto("Touch to\ntake photo",  margenesbutton, false); 

    buttonEnviar.setFont(&font);
    buttonEnviar.setTexto(textobuttonEnviar, margenesbutton,true);
    buttonEnviar.y = buttonFoto.y + buttonFoto.height + margenesbutton;
    
    buttonCancelar.setFont(&font);
    buttonCancelar.setTexto("Cancel", margenesbutton, true);
    buttonCancelar.y = buttonEnviar.y + buttonEnviar.height +espaciadoTexto;
}
//--------------------------------------------------------------
void testApp::loadSettings(){
    bool useDefauls = false;
    if( XML.loadFile(ofxiPhoneGetDocumentsDirectory() + "mySettings.xml") ){
        cout << "mySettings.xml loaded from documents folder!" << endl;
	}else if( XML.loadFile("mySettings.xml") ){
		cout << "mySettings.xml loaded from data folder!" << endl;
	}else{
        useDefauls = true;
		cout << "unable to load mySettings.xml check data/ folder" << endl ;
	}
	if (useDefauls) {
        textobuttonEnviar = TEXTO_button_ENVIAR;
        textoRegistrado = TEXTO_REGISTRADO;
        
        margenesbutton = MARGENES_button;
        
        anchoTexto= ANCHO_TEXTO;
        altoTexto = ALTO_TEXTO;
        espaciadoTexto = ESPACIADO_TEXTO;
        cuantosTextos = CUANTOS_TEXTOS;
        
        ftpHost = FTP_HOST;
        ftpUser = FTP_USER;
        ftpPass = FTP_PASS;
        
        uploadDir =UPLOAD_DIR;
        
    }else{
        XML.pushTag("settings");
        
        margenesbutton = XML.getValue("margenesbutton", MARGENES_button);
        
        anchoTexto = XML.getValue("anchoTexto", ANCHO_TEXTO);
        altoTexto = XML.getValue("altoTexto", ALTO_TEXTO);
        espaciadoTexto = XML.getValue("espaciadoTexto", ESPACIADO_TEXTO);
        cuantosTextos = XML.getValue("cuantosTextos", CUANTOS_TEXTOS);
        
        ftpHost = XML.getValue("ftpHost", FTP_HOST);
        ftpUser = XML.getValue("ftpUser", FTP_USER);
        ftpPass = XML.getValue("ftpPass", FTP_PASS);
        uploadDir = XML.getValue("uploadDir", UPLOAD_DIR);
        XML.popTag();
    }
    bSettingsLoaded = true;

}
//--------------------------------------------------------------
void testApp::saveSettings(){
    if (bSettingsLoaded) {
        if (XML.getNumTags("settings")==0) {
            XML.addTag("settings");
        }
        XML.setValue("settings:textobuttonEnviar", textobuttonEnviar);
        XML.setValue("settings:textoRegistrado", textoRegistrado);
        
        XML.setValue("settings:margenesbutton", margenesbutton);
        
        XML.setValue("settings:anchoTexto", anchoTexto);
        XML.setValue("settings:altoTexto", altoTexto);
        XML.setValue("settings:espaciadoTexto", espaciadoTexto);
        XML.setValue("settings:cuantosTextos", cuantosTextos);
        
        XML.setValue("settings:ftpHost", ftpHost);
        XML.setValue("settings:ftpUser", ftpUser);
        XML.setValue("settings:ftpPass", ftpPass);
        XML.setValue("settings:uploadDir", UPLOAD_DIR);
    }
}
//--------------------------------------------------------------
void testApp::update(){
    if(camera) {
        if(camera->imageUpdated){
            fotoLista = true;
            int cameraW = camera->width;
            int cameraH = camera->height;
            unsigned const char * cameraPixels = camera->pixels;
            
            photo.setFromPixels(cameraPixels, cameraW, cameraH, OF_IMAGE_COLOR_ALPHA);
  
            if (cameraImg !=NULL) {
                [cameraImg release];
                cameraImg = NULL;
            }
            
            UIImage *imageToCopy = camera->getUIImage();
            UIGraphicsBeginImageContext(imageToCopy.size);
            [imageToCopy drawInRect:CGRectMake(0, 0, imageToCopy.size.width, imageToCopy.size.height)];
            cameraImg = [UIGraphicsGetImageFromCurrentImageContext() retain];
            UIGraphicsEndImageContext();  
            camera->close();
            delete camera;
            camera = NULL;   
            
        }/*
        else if(camera->wasCancelled){
            camera->close();
            delete camera;
            camera = NULL;
        }*/
    }
}
//--------------------------------------------------------------
void testApp::ftpRequestListener(ofxiOSFTPEvent &event ){
  	if (event.bRequestCompleted && event.requestType ==  kWRUploadRequest ) {
        ofLog(OF_LOG_NOTICE, "iOS FTP upload request completed successfuly.");
        //do what ever you need to once the upload request has completed.
    }
}
//--------------------------------------------------------------
void testApp::reset(){
    fotoLista = false;
    if(camera != NULL){
        camera->close();
        delete camera;
        camera = NULL;  
    }
    if (cameraImg !=NULL) {
        [cameraImg release];
        cameraImg = NULL;
    }
}
//--------------------------------------------------------------
void testApp::takePhoto(){
    if(!camera) {
        camera = new ofxiOSImagePicker();
        camera->setMaxDimension(MAX(ofGetWidth(), ofGetHeight())); // max the photo taken at the size of the screen.
    }
       camera->openCamera(0); //this line opens the ios device camera. 0 = back camera. 1 = front camera
}
//--------------------------------------------------------------
void testApp::draw(){
    ofBackgroundGradient(ofColor::gray, ofColor::black);
    
    buttonEnviar.draw();
    buttonCancelar.draw();
    buttonFoto.draw();
    
    if (fotoLista) {
        photo.draw(buttonFoto);
    }
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
        if (buttonFoto.inside(touch.x, touch.y)) {
            takePhoto();
        }else if (buttonEnviar.inside(touch.x, touch.y)) {
            if (cameraImg !=NULL) {
                ftp->uploadUIImage(cameraImg, uploadDir +"myPhoto"+ ofToString(photoNum)+".jpg");
                photoNum++;
            }
        }else if (buttonCancelar.inside(touch.x, touch.y)) {
            reset();
        }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){}
//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){}
//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){}
//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){}
//--------------------------------------------------------------
void testApp::exit(){}
//--------------------------------------------------------------
void testApp::lostFocus(){}
//--------------------------------------------------------------
void testApp::gotFocus(){}
//--------------------------------------------------------------
void testApp::gotMemoryWarning(){}
//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){}

