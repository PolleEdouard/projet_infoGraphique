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
    
    popMatrix();
  }
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
