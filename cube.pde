/*QueasyCam cam;

void setup() {
  size(800, 600, P3D);
  
  cam = new QueasyCam(this);
  cam.position.set(0, 0, 300);  // Position de la caméra
  cam.speed = 3;
  cam.sensitivity = 0.8;
}
int nbLignes = 3;       
int nbColonnes = 5;     
int spacingX = 200;     
int spacingY = 80;
void draw() {
  background(200);
  lights();
  translate(0,0, 0);

  for (int ligne = 0; ligne < nbLignes; ligne++) {
    pushMatrix();
    translate(0, (ligne - nbLignes/2.0) * spacingY, 0); 
    // ↑ Décale chaque ligne verticalement

    for (int col = 0; col < nbColonnes; col++) {
      pushMatrix();
      translate(col * spacingX, 0, 0); 
      box(200, 80, 80);
      popMatrix();
    }

    popMatrix();
  }
}
