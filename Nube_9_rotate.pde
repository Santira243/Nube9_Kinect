/*
Thomas Sanchez Lengeling.
 http://codigogenerativo.com/
 
 KinectPV2, Kinect for Windows v2 library for processing
 
 How to record Point Cloud Data and store it in several obj files.
 Record with 'r'
 */
import nervoussystem.obj.*;
import java.util.ArrayList;
import java.nio.*;
import KinectPV2.*;

KinectPV2 kinect;

PGL pgl;
PShader sh;

int scalex = 1000;
int scaley = 1000;
int scalez = 550;

int  vertLoc;

//transformations
float a = 7;


//Distance Threashold
int maxD = 2000; // 4.5 m
int minD = 500;  //  50 cm

int gir_y;
int numFrames =  30; // 30 frames  = 1s of recording
int frameCounter = 0; // frame counter

boolean congelar = false;
boolean recordFrame = false;  //recording flag
boolean doneRecording = false;
boolean camara1 = false;
boolean camara2 = false;
//Array where all the frames are allocated
ArrayList<FrameBuffer> mFrames;

boolean record;
//VBO buffer location in the GPU
int vertexVboId;
FloatBuffer pointCloudBuffer2;
PImage rgbcolor2;
PVector[] realWorldMap; 
int angle = 0; 
//PShader blur;
boolean disminuir;
void setup() {
  size(1920, 1080, P3D);

  kinect = new KinectPV2(this);

  //create arrayList
  mFrames = new ArrayList<FrameBuffer>();

  //Enable point cloud
  kinect.enableDepthImg(true);
  kinect.enablePointCloud(true);
  kinect.enableColorImg(true);
  kinect.init();

  sh = loadShader("frag.glsl", "vert.glsl");
 // blur = loadShader("str.glsl", "frag2.glsl"); 
  PGL pgl = beginPGL();

  IntBuffer intBuffer = IntBuffer.allocate(1);
  pgl.genBuffers(1, intBuffer);

  //memory location of the VBO
  vertexVboId = intBuffer.get(0);
  
  endPGL();

  //set framerate to 30
  frameRate(30);
}

void draw(){
  
   if (record) {
    beginRecord("nervoussystem.obj.OBJExport", "mirada.obj");
  }
 if (!disminuir)
 {angle +=1;}
 else
 {
   angle-=1;
 } 
 if (angle<0)
 {disminuir=false;}
 if (angle>70)
 {disminuir=true;}
 
  background(0);
  // Threahold of the point Cloud.
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
  if(congelar == false)
  {
      
      float [] mapDCT = kinect.getMapDepthToColor();
      FloatBuffer pointCloudBuffer1 = kinect.getPointCloudDepthPos();
      PImage rgbcolor1 = kinect.getColorImage();
      realWorldMap =new PVector[KinectPV2.WIDTHDepth*KinectPV2.HEIGHTDepth];
      int     count;
      count = 0;
      for (int i = 0; i < KinectPV2.WIDTHDepth; i++) {
        for (int j = 0; j < KinectPV2.HEIGHTDepth; j++) {
                  float valX = mapDCT[count * 2 + 0];
                  float valY = mapDCT[count * 2 + 1];
    
            realWorldMap[count]= new PVector(valX, valY);
            count ++;
          }
       }
      pointCloudBuffer2 = pointCloudBuffer1;
      rgbcolor2 = rgbcolor1;
  }
  
        float cameraY = (height)*1.8;
        float fov =PI/6;
       // println(fov);
        float cameraZ = (1430+cameraY) / tan(fov / 1.0);
        float aspect = float(width)/float(height);// Threahold of the point Cloud.
        perspective(fov, aspect, cameraZ/10.0, cameraZ*5.0);
        
    if (camara1 == true)
    {
       //filter(blur);
    }
    if(camara2 == true)
        {
         float xrot = map( mouseX, 0, width, 0, 2000);
         float yrot = map( mouseY, 0, height, 0, 1000);
         camera(xrot, (height/2.0)+yrot, (height/2.0) / tan(PI*30.0 / 180.0)+xrot/2, width/2.0, height/2.0, 0, 0, 1, 0);
        }
  translate(width/2, height/2-100);
  strokeWeight(1.5);
  color   pixelColor;
  beginShape(POINTS);
 // rotateX(radians(angle));
  rotateY(radians(167+angle));
  println(angle);
  //rotateZ(radians(angle*1.2));
  
  int index;
  for(int y=0;y < KinectPV2.HEIGHTDepth;y++)
  {
    for(int x=0;x <  KinectPV2.WIDTHDepth;x++)
    {
      index = x + y * KinectPV2.WIDTHDepth;
      pixelColor = rgbcolor2.get(int(realWorldMap[index].x),int(realWorldMap[index].y));
       if(  brightness(pixelColor)>10)
       {
         // get the color of the point
        //pixelColor = rgbImage.pixels[index];
         
         stroke(pixelColor);
         
        // draw the projected point
        //realWorldPoint = realWorldMap[index];
        float xf = pointCloudBuffer2.get(index*3 + 0)*scalex;
        float yf = pointCloudBuffer2.get(index*3 + 1)*scaley;
        float zf = pointCloudBuffer2.get(index*3 + 2)*scalez;
        vertex(int(xf),-int(yf),int(zf));  // make realworld z negative, in the 3d drawing coordsystem +z points in the direction of the eye
        //  point(int(xf),-int(yf),int(zf));  // make realworld z negative, in the 3d drawing coordsystem +z points in the direction of the eye
       }
     }
  } 
  endShape();
  
   if (record) {
    endRecord();
    record = false;
  }
}


public void keyPressed() {

//  //start recording 30 frames with 'r'
  if (key == 'r') {
     record = true;
  }
  if (key == 'a') {
 camara1 = true;
  camara2 = false;
   }
  if (key == 's') {
 camara1 = false;
 camara2 = true;
   }

  if (key == 'e') {
    exit();
  }
//  if (key == 'x') {
//    scaleVal -= 0.1;
//    println(scaleVal);
//  }

//  if (key == 'q') {
//    a += 0.1;
//    println(a);
//  }
//  if (key == 'w') {
//    a -= 0.1;
//    println(a);
//  }

//  if (key == '1') {
//    minD += 10;
//    println("Change min: "+minD);
//  }

//  if (key == '2') {
//    minD -= 10;
//    println("Change min: "+minD);
//  }

//  if (key == '3') {
//    maxD += 10;
//    println("Change max: "+maxD);
//  }

//  if (key == '4') {
//    maxD -= 10;
//    println("Change max: "+maxD);
//  }
}
