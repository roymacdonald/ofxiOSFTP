#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxiOSFTP.h"
#include "simpleButton.h"
#include "ofxXmlSettings.h"

#define MARGENES_button 10
#define TEXTO_button_ENVIAR "Finalizar"
#define TEXTO_REGISTRADO "Gracias por\nparticipar."

#define ANCHO_TEXTO 100
#define ALTO_TEXTO 40
#define ESPACIADO_TEXTO 25
#define CUANTOS_TEXTOS 3
#define FTP_HOST "192.168.0.10"
#define FTP_USER "user"
#define FTP_PASS "pass" 

#define UPLOAD_DIR "/" //this is the default path where files are uploaded. This is relative to the home dir

class testApp : public ofxiPhoneApp{
	
public:
    void setup();
    void update();
    void draw();
    void exit();
	
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
	
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    ofxiOSFTP *ftp;
    
    void setupButtons();
    SimpleButton buttonFoto;
    SimpleButton buttonEnviar;
    SimpleButton buttonCancelar;
    ofTrueTypeFont font, font2;
    
    void takePhoto();
    void ftpRequestListener(ofxiOSFTPEvent &event );
    bool checkIfIsEmail(string s);
    
    
    void reset();
    
    bool fotoLista;
    ofxiOSImagePicker * camera;
    UIImage * cameraImg;
    ofImage	photo;
    
    void mostrarPantallaRegistrado(bool mostrar = true);
    bool bMostrarPantallaRegistrado;
	
    
    ofImage fondo;
    
    ofxXmlSettings XML;
    //vars to load xmlsettings
    bool bSettingsLoaded;
    string textobuttonEnviar;
    string textoRegistrado;
    
    string ftpHost, ftpUser, ftpPass;
    
    int margenesbutton;
    
    int anchoTexto, altoTexto, espaciadoTexto, cuantosTextos;
    string uploadDir;
    int photoNum;
    
    void loadSettings();
    void saveSettings();
    
    
};

