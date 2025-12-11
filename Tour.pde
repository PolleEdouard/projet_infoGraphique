QueasyCam cam; 
int decal = 0;

int nbColonnes = 10;     
int nbLignes = 38;       
int brickW = 10;         
int brickH = 5;          
int brickD = 5;         
int spacingY = 5;        

void setup() {
  size(1280, 720, P3D);

  cam = new QueasyCam(this);
  cam.position.set(0, 0, 300);
  cam.speed = 3;
  cam.sensitivity = 0.8;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  cam.position.z += e * 20;  
}

void draw() {
  background(135, 206, 235);
  lights();

  float distance = 50;  
  
  int nbMurs = 4;

  for (int i = 0; i < nbMurs; i++) {
    pushMatrix();

    rotateY(radians(90 * i));

    translate(2.5, 50, distance);

    drawWall();
    drawCreneaux();
    
    popMatrix();
  }
  
  drawSol();
}

void drawWall() {
  pushMatrix();
  
  rotateY(radians(decal));
  translate(-(nbColonnes * brickW) / 2,
            -(nbLignes   * spacingY) / 2,
            0);

  for (int ligne = 0; ligne < nbLignes; ligne++) {
    pushMatrix();
    translate(0, ligne * spacingY, 0);

    float offset = (ligne % 2 == 0) ? brickW / 2.0 : 0;
    translate(offset, 0, 0);

    for (int col = 0; col < nbColonnes; col++) {
      pushMatrix();
      translate(col * brickW, 0, 0);
      fill(235, 230, 207);
      box(brickW, brickH, brickD);
      popMatrix();
    }
    popMatrix();
  }
  popMatrix();
}

void drawSol(){
  pushMatrix();
  float solY = (nbLignes * spacingY) / 2 + brickH/2 + 45.5;
  translate(0, solY, 0);

  rotateX(HALF_PI);

  fill(235, 230, 207);

  float solSize = nbColonnes * brickW + brickW * 0.50;

  rectMode(CENTER);
  rect(0, 0, solSize, solSize);         
  popMatrix();
}

/*void drawCreneaux() {
  pushMatrix();

  rotateY(radians(decal));
  translate(-(nbColonnes * brickW) / 2, 
            -(nbLignes * spacingY) / 2 - brickH*1.5,  
            0);

  float step = brickW * 1.5; 
  for (float x = 0; x < nbColonnes * brickW; x += step) {
    pushMatrix();
    translate(x, 0, 0);
    fill(210, 200, 180);
    box(brickW, brickH * 2, brickD); 
    popMatrix();
  }

  popMatrix();
}*/

void drawCreneaux() {
  pushMatrix();

  rotateY(radians(decal));
  translate(-(nbColonnes * brickW) / 2,
            -(nbLignes * spacingY) / 2 - brickH, 
            0);

  float gap = brickW * 0.5;
  float step = brickW + gap;

  for (float x = 0; x < nbColonnes * brickW; x += step) {
    pushMatrix();
    translate(x + brickW/2, 0, 0);

    fill(235, 230, 207);

    box(brickW, brickH, brickD);

    translate(0, -brickH, 0);
    box(brickW, brickH, brickD);

    popMatrix();
  }

  popMatrix();
}
