import processing.sound.*;
TwoDeeLayer zippy;
int fpf = 2;
int cellTypes = 8;
char[][] keys = new char[][] {{'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'},
                              {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'},
                              {'z', 'x', 'c', 'v', 'b', 'n', 'm'},};
char controlKey = '*';
int cK;
//int[][] controls = new int[3][9];
PFont font;

FFT fft;
AudioIn in;
int bands = 256;
float[] spectrum = new float[bands];

void setup() {
  //size(800, 800);
  fullScreen();
  colorMode(HSB, 360, 100, 100, 1);
  background(0, 0, 20, 1);
  font = createFont("data/neoletters.ttf", 32);
  textFont(font);
  // set up cell layer
  zippy = new TwoDeeLayer(118, 66, 16);
  //zippy = new TwoDeeLayer(236, 132, 8);
  //zippy = new TwoDeeLayer(236*2, 132*2, 4);
  //zippy = new TwoDeeLayer(160, 160, 4);
  //zippy = new TwoDeeLayer(320, 320, 2);
  zippy.setOffset(0, 0);
  zippy.seed(0.8);
  // set up rule-control grid
  //for(int q=0; q<cellTypes; q++) {
  //  for(int w=0; w<controls[0].length; w++) {
  //    controls[q][w] = 0;
  //  }
  //}
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  // start the Audio Input
  in.start();
  // patch the AudioIn
  fft.input(in);
}

void draw() {
  fft.analyze(spectrum);
  cK = int(controlKey) - 97;
  zippy.drawGrid();
  //zippy.become(controls, zippy.colors);
  drawKeys();
  zippy.drawRules();
  if(controlKey != '*') {
    if(frameCount % fpf == 0) {
      zippy.step(1);
    }
  } else {
    zippy.seed(0.5); 
  }
  //println(highestBeat(spectrum));
  controlKey = char(highestBeat(spectrum) + 97);
}

void keyPressed() {
  // switching control keys
  if(int(key) >= 97 && int(key) <= 122)
    if(controlKey == key) {
      controlKey = '*';
    } else {
      controlKey = key;
    }
  // changing the frame per frame value
  if(key == '=') {
    fpf++;
    println("fpf = "+fpf);
    zippy.setSpeed(fpf);
  } else if(key == '-') {
    if(fpf > 1) {
      fpf--;
      println("fpf = "+fpf);
      zippy.setSpeed(fpf);
    }
  } else if(key == '/' && controlKey != '*') {
    zippy.mutate(2);
  }
  if(key == ' ') {
    saveFrame("synapsi_instrumental_######.png");
  }
  
  // updating rules based on keys pressed
  //for(int q=0; q<controls.length; q++) {
  //  for(int w=0; w<controls[0].length; w++) {
  //    if(q < keys.length) {
  //      if(key == keys[q][w]) {
  //        controls[q][w] = 1;
  //      }
  //    }
  //  }
  //}
}

void keyReleased() {
  // if no other key is pressed & lowercase key is pressed
  //if(controlKey == key && int(key) >= 97 && int(key) <= 122) {
  //  controlKey = '*';
  //}
  // updating rules based on keys pressed
  //for(int q=0; q<controls.length; q++) {
  //  for(int w=0; w<controls[0].length; w++) {
  //    if(q < keys.length) {
  //      if(key == keys[q][w]) {
  //        controls[q][w] = 0;
  //      }
  //    }
  //  }
  //}
}

void mouseClicked() {
  zippy.click();
}

void drawKeys() {
  float oY = zippy.h * zippy.cellSize;
  float sw = (zippy.w * zippy.cellSize) / keys[0].length;
  float sh = (height - (oY+1)) / keys.length;
  for(int i=0; i<keys.length; i++) {
    for(int j=0; j<keys[i].length; j++) {
      strokeWeight(1);
      stroke(0, 0, 100, 1);
      if(controlKey == keys[i][j]) {
        fill(color(hue(zippy.colors[0]), saturation(zippy.colors[0]), brightness(zippy.colors[0]), 1));
      } else {
        fill(0, 0, 20, 1);
      }
      rect(j*sw, i*sh + oY, sw, sh);
      fill(0, 0, 100, 1);
      text(keys[i][j], j*sw + 16, i*sh + oY + 40);
    }
  }
}

int highestBeat(float s[]) {
  int highestIndex = 0;
  float highest = s[0];
  for(int i=0; i<26; i++) {
    if(s[i] > highest + 0.06) {
      highestIndex = i;
    }
  }
  //println(s[16]);
  return highestIndex;
}

boolean mouseOver(float x1, float y1, float ww, float hh) {
  if(mouseX >= x1 && mouseX <= x1+ww && mouseY >= y1 && mouseY <= y1+hh) {
    return true;
  } else {
    return false;
  }
}
      
      
