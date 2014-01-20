import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.opengl.*;

Minim minim;
AudioInput in;
FFT fft;

public char type = '1';
public int count = 0;
public int bg = 0;
public int fg = 255;
public boolean blinkmode = false;
public int beatFlg = 0;
float rotZ = 0;
boolean sastain = false;
float rot = 0;
float rot2 = 0;
float ThresBass = 0;
float ThresTreble = 0;
float preBand = 0;
  
void setup() {
  size(displayWidth, displayHeight,OPENGL);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  noCursor();
}

void draw() {
  if(blinkmode) {
    bgblink();
  }
  disp();
  count++;
  if(count > 99) {
    count = 0;
  }
}

void disp() {
  switch(type) {
    case '1':
      type = '1';
      vector();
      break;
    case '2':
      type = '2';
      circleLine();
      break;
    case '3':
      type = '3';
      circleNoise();
      break;
    case '4':
      type = '4';
      triangle();
      break;
    case '5':
      type = '5';
      mosaik();
      break;
    case '6':
      type = '6';
      points();
      break;
    case '7':
      type = '7';
      spectrum();
      break;
    case '0':
      type = '0';
      check();
      break;
    default:
      type = '1';
      vector();
      break;
  }
}

void keyPressed() {
  char keyType = key;
  if(keyType == '0' || keyType == '1' || keyType == '2' || keyType == '3' || keyType == '4' || keyType == '5' || keyType == '6' || keyType == '7') {
    type = keyType;
  }else {
    colorChange(keyType);
  }
  disp();
}

void colorChange(char mode) {
  blinkmode = false;
  switch(mode) {
    case ',':
      bg = 0;
      fg = 255;
      break;
    case '.':
      bg = 255;
      fg = 0;
      break;
    case '/':
      blinkmode = true;
      bgblink();
      break;
  }
}

void bgblink() {
  float band = 0;
  float band_r = 0;
  fft.forward(in.mix);
  
  for(int i = 0; i < 3; i++) {
    band = band+fft.getBand(i);
  }
  band_r = band/3;
  if(band > 130) {
    if(sastain != true) {

      if(bg == 255) {
        bg = 0;
        fg = 255;
      }else {
        bg = 255;
        fg = 0;
      }
      sastain = true;
    }
  }else {
    sastain = false;

  }
}

//check
void check() {
  background(0);
  fill(255,125);
  float band = 0;
  fft.forward(in.mix);
  for(int i = 0; i < 5; i++) {
    band = band+fft.getBand(i);
  }
  band = band/5;
  if(band > preBand) {
    preBand = band;
  }
  textSize(120);
  text(preBand,200,200);
  if(band > 40) {
    text(band,200,300);
  }
}

//vector
void vector() {
  background(bg);
  fill(fg,250);
  noStroke();
  smooth();
  int centerW = width/2;
  int centerH = height/2;
  for(int i = 0; i < in.bufferSize()-1; i++) {
    float l1 = map( in.left.get(i), -1, 1, 0-centerW, centerW);
    float r1 = map( in.right.get(i), -1, 1, 0-centerW, centerW );
    ellipseMode(CENTER);
    ellipse(centerW-l1,centerH+r1,1.5,1.5);
    fill(fg,125);
    ellipse(centerW-l1,centerH+r1,2,2);
  }
}

//circle
void circleLine() {
  background(bg,50);
  fill(fg,10);
  stroke(fg, 250);
  strokeWeight(2);
  smooth();
  int centerW = width/2;
  int centerH = height/2;
  float band = 0;
  float band_r = 0;
  
  fft.forward(in.right);
  for(int i = 0; i < 5; i++) {
    band = band+fft.getBand(i);
  }
  band_r = band/5;
  float x_r = map(band_r, 0, 100, centerW, width);
  band = 0;
  
  fft.forward(in.left);
  for(int i = 0; i < 5; i++) {
    band = band+fft.getBand(i);
  }
  band_r = band/5;
  float x_l = map(band_r, 0, 100, 0, width/2);
  band = 0;
  
  fft.forward(in.mix);
  for(int i = 0; i < 5; i++) {
    band = band+fft.getBand(i);
  }
  band_r = band/5;
  float lr = map(band_r, 0, 100, 0, height/2);
  band = 0;
  
  float x = x_r-x_l;
  float y = centerH;
  
  int upper100 = fft.specSize() - 90;
  int count_num = 0;
  for(int i = upper100-100; i < fft.specSize()-100; i++) {
    count_num++;
    float db = map(fft.getBand(i), 0, 100, 0,height/2);
    if(db > 2) {
      stroke(fg, 125);
      strokeWeight(1);
      strokeCap(SQUARE);
      db = db * 10;
      float xp = x + db*cos(radians(count_num*2));
      float yp = y - db*sin(radians(count_num*2));
      float xm = x - db*cos(radians(count_num*2));
      float ym = y + db*sin(radians(count_num*2));
      
      line(xp,yp,xm,ym);
    }
  }
  noFill();
  stroke(fg, 250);
  strokeWeight(2);
  
  ellipseMode(CENTER);
  ellipse(x,y, lr,lr);
  
  //inner circle
  stroke(fg,125);
  ellipse(x,y, lr*0.7,lr*0.7);
  stroke(fg,70);
  ellipse(x,y, lr*0.5,lr*0.5);
  
  //outer circle
  stroke(fg,125);
  ellipse(x,y, lr*1.3,lr*1.3);
  stroke(fg,70);
  ellipse(x,y, lr*1.5,lr*1.5);
}

//circle with noise
void circleNoise() {
  background(bg,50);
  fill(fg,10);
  stroke(fg, 250);
  strokeWeight(2);
  smooth();
  int centerW = width/2;
  int centerH = height/2;
  float band = 0;
  float band_r = 0;
  float[] leftBand;
  leftBand = new float[255];
  float[] rightBand;
  rightBand = new float[255];
  int count_num = 0;
  int upper100;
  
  //right channel
  fft.forward(in.right);
  upper100 = fft.specSize() - 90;
  for(int i = 0; i < 5; i++) {
    band = band+fft.getBand(i);
  }
  band_r = band/5;
  float x_r = map(band_r, 0, 100, centerW, width);
  for(int i = upper100-80; i < fft.specSize()-80; i++) {
    rightBand[count_num] = fft.getBand(i);
    count_num++;
  }
  count_num = 0;
  band = 0;
  
  //left channel
  fft.forward(in.left);
  for(int i = 0; i < 5; i++) {
    band = band+fft.getBand(i);
  }
  band_r = band/5;
  float x_l = map(band_r, 0, 100, 0, width/2);
  for(int i = upper100-80; i < fft.specSize()-80; i++) {
    count_num++;
    leftBand[count_num] = fft.getBand(i);
  }
  count_num = 0;
  band = 0;
  
  //stereo
  fft.forward(in.mix);
  for(int i = 0; i < 5; i++) {
    band = band+fft.getBand(i);
  }
  band_r = band/5;
  float lr = map(band_r, 0, 100, 0, height/2);
  band = 0;
  
  float x = x_r-x_l;
  float y = centerH;
  //stereo high freq
  for(int i = 0; i < rightBand.length; i++) {
    float ypos = map(i, 0, 90, 0, height/2);
    float r_db = map(rightBand[i], 0, 100, 0, width/2);
    float l_db = map(leftBand[i], 0, 100, 0, width/2);
    if(r_db > 2) {
      noStroke();
      fill(fg,220);
      ellipse(x+r_db,y+ypos,2,2);
      ellipse(x+r_db,y-ypos,2,2);
    }
    if(l_db > 2) {
      noStroke();
      fill(fg,220);
      ellipse(x-l_db,y+ypos,2,2);
      ellipse(x-l_db,y-ypos,2,2);
    }
  }
  noFill();
  stroke(fg, 250);
  strokeWeight(2);
  ellipseMode(CENTER);
  ellipse(x,y, lr,lr);
  
  //inner circle
  stroke(fg,125);
  ellipse(x,y, lr*0.7,lr*0.7);
  stroke(fg,70);
  ellipse(x,y, lr*0.5,lr*0.5);
  
  //outer circle
  stroke(fg,125);
  ellipse(x,y, lr*1.3,lr*1.3);
  stroke(fg,70);
  ellipse(x,y, lr*1.5,lr*1.5);
}


//triangle
void triangle() {
  float band = 0;
  float bass = 0;
  float treble = 0;
  boolean boostBass = false;
  boolean boostTreble = false;

  background(bg);

  fft.forward(in.mix);
  for(int i = 0; i < 3; i++) {
    band = band+fft.getBand(i);
  }
  band = band/3;
  for(int i=0; i<300; i++) {
    stroke(fg,random(125,245));
    point(random(width), random(height));
  }
  if(band > 25) {
    bass = map(band, 0, 50, 0, height/8);
    for(int i=0; i<500; i++) {
      stroke(fg,random(125,245));
      point(random(width), random(height));
    }
  }
  if(band > 40) {
    boostBass = true;
  }
  band = 0;
  //treble
  for(int i = 100; i < 200; i++) {
    band = band+fft.getBand(i);
  }
  band = band/10;
  if(band > 2) {
    treble = map(band, 0, 50, 0, height/5);
  }
  if(band > 5){
    boostTreble = true;
  }

  translate(width/2, height/2);
  float size = (height/5)+bass;
  noFill();
  rot += PI/90;
  if(boostBass) {
    rot -= PI/180;
  }
  rotateX(1.0);
  rotateZ(rot);
  stroke(fg);
  strokeWeight(1);
  beginShape(TRIANGLES);
    vertex(size,size,size);
    vertex(size,-size,-size);
    vertex(-size,size,-size);
    
    vertex(size,size,size);
    vertex(size,-size,-size);
    vertex(-size,-size,size);
    
    vertex(size,size,size);
    vertex(-size,size,-size);
    vertex(-size,-size,size);
    
    vertex(size,-size,-size);
    vertex(-size,size,-size);
    vertex(-size,-size,size);
  endShape();

  size = (height/10)+treble;
  rot2 += PI/80;
  if(boostTreble) {
    rot2 += PI/40;
  }else if(boostBass) {
    rot2 -= PI/40;
  }
  rotateX(1.2);
  rotateZ(rot2);
  beginShape(TRIANGLES);
    vertex(size/2,size/2,size/2);
    vertex(size/2,-size/2,-size/2);
    vertex(-size/2,size/2,-size/2);
    
    vertex(size/2,size/2,size/2);
    vertex(size/2,-size/2,-size/2);
    vertex(-size/2,-size/2,size/2);
    
    vertex(size/2,size/2,size/2);
    vertex(-size/2,size/2,-size/2);
    vertex(-size/2,-size/2,size/2);
    
    vertex(size/2,-size/2,-size/2);
    vertex(-size/2,size/2,-size/2);
    vertex(-size/2,-size/2,size/2);
  endShape();
}

//points
void points() {
  background(bg,50);
  int center_w = width/2;
  float[] leftBand;
  leftBand = new float[258];
  float[] rightBand;
  rightBand = new float[258];
  int reso = 0;
  float tmp_db = 0;
  int counter = 0;
  int dens = 10;
  
  int x_max = (width - (width%dens))/dens;
  int y_max = (height - (height%dens))/dens;

  //right channel
  fft.forward(in.right);
  reso = fft.specSize()/x_max/2;
  for(int i = 0; i < fft.specSize(); i++) {
    if(reso > 0 && i%reso == 0) {
      rightBand[counter] = map((tmp_db + fft.getBand(i))/reso, 0, 100, 0, y_max);
      counter++;
    }else {
      tmp_db = tmp_db + fft.getBand(i);
    }
  }
  counter = 0;tmp_db = 0;

  //left channel
  fft.forward(in.left);
  reso = fft.specSize()/x_max/2;
  for(int i = 0; i < fft.specSize(); i++) {
    if(reso > 0 && i%reso == 0) {
      leftBand[counter] = map((tmp_db + fft.getBand(i))/reso, 0, 100, 0, y_max);
      counter++;
    }else {
      tmp_db = tmp_db + fft.getBand(i);
    }
  }
  counter = 0;tmp_db = 0;
  
  //right
  for(int x = 5; x < width/2; x=x+dens) {
    for(int y = 0; y < height; y=y+dens) {
      noStroke();
      if(rightBand[y/dens] > 3 && y < height/2) {
        fill(fg,172);
        ellipse(center_w+x,height-y, 3,3);
      }else if(rightBand[y/dens] > 2 && y >= height/2){
        fill(fg,220);
        ellipse(center_w+x,height-y, 2,2);
      }else {
        fill(fg,64);
        ellipse(center_w+x,height-y, 2,2);
      }
    }
  }
  //right
  for(int x = 5; x < width/2; x=x+dens) {
    for(int y = 0; y < height; y=y+dens) {
      noStroke();
      if(leftBand[y/dens] > 3 && y < height/2) {
        fill(fg,172);
        ellipse(center_w-x,height-y, 3,3);
      }else if(leftBand[y/dens] > 2 && y >= height/2){
        fill(fg,220);
        ellipse(center_w-x,height-y, 2,2);
      }else {
        fill(fg,64);
        ellipse(center_w-x,height-y, 2,2);
      }
    }
  }
}

//mosaik
void mosaik() {
  background(bg);
  noStroke();
  rectMode(CENTER);
  float bass = 0;
  float treble = 0;
  float band = 0;
  
  fft.forward(in.mix);
  for(int i = 0; i < 3; i++) {
    band = band+fft.getBand(i);
  }
  band = band/3;
  if(band > 25) {
    bass = map(band,0,150,25,255);
  }
  band = 0;
  //treble
  for(int i = 80; i < 200; i++) {
    band = band+fft.getBand(i);
  }
  treble = floor(map(band, 0, 150, 6, 40));

  float mosaicSize = treble;
  stroke(fg,bass);
  if(treble > bass && treble > 8) {
    stroke(fg,map(treble,0,50,5,255));
  }

  for(int j = 0; j < height; j+=mosaicSize) {  
    for(int i = 0; i < width; i+=mosaicSize) {  
      float c = floor(random(treble,treble+100));
      if(c < 1) c = 1;
      pushMatrix();
      translate(i, j);
      rotate(c);
      strokeWeight(1);
      line(0, 0, c, 2);
      popMatrix();
    }
  } 
}

//simple spectrum
void spectrum() {
  background(bg,50);
  stroke(fg, 70);
  strokeWeight(2);
  smooth();
  int centerH = height/2;
  int centerW = width/2;

  fft.forward(in.left);
  int specSize = fft.specSize();
  for (int i = 0; i < specSize; i++) {
    float x = map(i, 0, specSize, 0, centerW);
    for(int j = 0; j<3;j++) {
      line(centerW-x-j, centerH, centerW-x, centerH - fft.getBand(i) * 4);
      line(centerW+x-j, centerH, centerW+x, centerH - fft.getBand(i) * 4);
    }
  }
  fft.forward(in.right);
  specSize = fft.specSize();
  for (int i = 0; i < specSize; i++) {
    float x = map(i, 0, specSize, 0, centerW);
    for(int j = 0; j<3;j++) {
      line(centerW+x-j, centerH, centerW+x, centerH + fft.getBand(i) * 4);
      line(centerW-x-j, centerH, centerW-x, centerH + fft.getBand(i) * 4);
    }
  }
}

void stop() {
  in.close();
  minim.stop();
 
  super.stop();
}
