/*QueasyCam cam; 
int decal = 0;

int iterations = 10;
float size = 20; 
float thickness = 5;


void setup() {
  size(1280, 720, P3D);
  cam = new QueasyCam(this);
  cam.position.x = width/2.2;
  cam.position.y = height/2.4;
  cam.position.z = 200;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  cam.position.z += e * 20;  // zoom / dézoom
}

void draw() {
  background(150, 200, 255);
  frameRate(60);
  background(135, 206, 235); 
  translate(width / 2, height / 2);
  //Cam
  pushMatrix();
  if (mousePressed && mouseButton == RIGHT) {
    decal += 1;
    rotateY(radians(decal));
  }
  translate(-5 * 10, 0, 0);
  
  for(int i=0; i<10; i++){
    pushMatrix();
    translate(i*10, 0, 0);
    fill(235, 230, 207);
    box(10, 5, 5);
    popMatrix();
  }
  popMatrix();
}

QueasyCam cam;

void setup() {
  size(800, 600, P3D);
  
  cam = new QueasyCam(this);
  cam.position.set(0, 0, 300);  // Position de la caméra
  cam.speed = 3;
  cam.sensitivity = 0.8;
}
int nbLignes = 38;       
int nbColonnes = 10;          
int spacingY = 5;

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  cam.position.z += e * 20;  // zoom / dézoom
}

void draw() {
  background(200);
  lights();

  // On centre un peu le tout
  translate(50, height/2, 0);

  for (int ligne = 0; ligne < nbLignes; ligne++) {
    pushMatrix();
    translate(0, (ligne - nbLignes/2.0) * spacingY, 0); 
    // ↑ Décale chaque ligne verticalement

    for (int col = 0; col < nbColonnes; col++) {
      pushMatrix();
      translate(col * 10, 0, 0); 
      fill(235, 230, 207);
      box(10, 5, 5);
      popMatrix();
    }

    popMatrix();
  }
}*/

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

  /*if (mousePressed && mouseButton == RIGHT) {
    decal++;
  }*/
  
  float distance = 50;  // distance du centre (épaisseur de la tour)
  int nbMurs = 4;

  for (int i = 0; i < nbMurs; i++) {
    pushMatrix();

    // rotation : un côté du carré = 90° 
    rotateY(radians(90 * i));

    // on déplace le mur vers l'extérieur pour former la tour
    translate(2.5, 50, distance);

    // dessine le mur
    drawWall();
    
    popMatrix();
  }
}

void drawWall() {
  pushMatrix();
  
  // alignement interne du mur
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
