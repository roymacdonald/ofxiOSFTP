//
//  simpleButton.h
//  registroDuckhunt
//
//  Created by Roy Macdonald on 8/12/12.
//  Copyright (c) 2012 micasa. All rights reserved.
//

#pragma once

#include "ofMain.h"


class SimpleButton :public ofRectangle {
public:
    ofImage img;
    bool bHasImage;
    string texto;
    ofTrueTypeFont *font;
    int margin;
    //--------------------------------------------------------------
    SimpleButton(){
        ofRectangle::ofRectangle();
        texto = "";
        bHasImage = false;
        margin =0;
        font = NULL;
    }
    //--------------------------------------------------------------
    bool setImage(string imgPath, bool bSetSize = false){
        if(img.loadImage(imgPath)) {
            if (bSetSize) {
                this->width = img.getWidth();
                this->height = img.getHeight();                    
            }
            bHasImage = true;
            return true;
        }else{
            if(bSetSize)
                setButton(0,0, 320, 62);
            return false;
        }
    }
    //--------------------------------------------------------------
    void setButton(ofRectangle r){
        setButton(r.x, r.y, r.width, r.height);
    }
    //--------------------------------------------------------------
    void setButton(float x, float y, float w, float h, int m = 0, string texto = ""){
        bHasImage =false;
        this->x = x;
        this->y = y; 
        this->width = w;
        this->height = h;
        this->texto = texto;
        margin = m;
    }
    //--------------------------------------------------------------
    void setFont(ofTrueTypeFont * f){
        font = f;
    }
    //--------------------------------------------------------------
    void setTexto(string t, int m, bool bSetSize = true){
        if (font != NULL) {
        
        this->texto = t;
        this->margin = m;
            if (bSetSize) {
            
        setButton(font->getStringBoundingBox(t, 0, 0));
                 this->texto = t;
                 this->margin = m;
            
        this->width += (margin*2);
        this->x = (ofGetWidth() - this->width)/2.0f;
        this->height += (margin*2);
                
            }
        }
    }
    //--------------------------------------------------------------
    void draw(){
        
        bool up =  inside(ofGetMouseX(), ofGetMouseY()) && ofGetMousePressed();
        if (bHasImage) {
            if (up) {
                ofSetColor(255, 255);
            }else{
                ofSetColor(255, 175);
            }
            img.draw(x, y, width, height);
        }else{
            
            ofPushStyle();
            ofSetColor(50, 10);
            ofFill();
            ofRect(*this);
            
            ofSetColor(100, 150);
            ofNoFill();
            ofRect(*this);
            if(up){
                ofSetColor(200, 230,0, 255);
            }else{
                ofSetColor(200, 20, 0, 255);
            }
            if (font!=NULL) {
                font->drawString(texto, x + margin, y + height- margin);
            }
            ofPopStyle();
            
        }
    }
};