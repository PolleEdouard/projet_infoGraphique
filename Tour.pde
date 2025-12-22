QueasyCam cam;
int decal = 0;

int nbColonnes = 10;
int nbLignes = 38;
int brickW = 10;
int brickH = 5;
int brickD = 5;
int spacingY = 5;
ArrayList<Tour> lesTours; 
ArrayList<Mur> lesMurs;


void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  cam.position.z += e * 20;
}
void setup() {
  size(1280, 720, P3D);
  cam = new QueasyCam(this);
  cam.position.set(0, 0, 300);
  cam.speed = 3;
  cam.sensitivity = 0.8;



  lesTours = new ArrayList<Tour>();
  lesMurs = new ArrayList<Mur>();

  // --- CONFIGURATION DU CHÂTEAU ---
  // Paramètres : x, z, nbColonnes, nbLignes
  int ecart = 250; 
  
  lesTours.add(new Tour(-ecart, -ecart)); // Arrière Gauche
  lesTours.add(new Tour(ecart, -ecart));  // Arrière Droite
  lesTours.add(new Tour(ecart, ecart));   // Avant Droite
  lesTours.add(new Tour(-ecart, ecart));  // Avant Gauche
  
  int longueurMurPixels = (ecart * 2) - 130; 
  
  // Mur Nord (Z = -ecart)
  lesMurs.add(new Mur(0, -ecart, longueurMurPixels, 0)); 
  // Mur Sud (Z = ecart)
  lesMurs.add(new Mur(0, ecart, longueurMurPixels, 180)); 
  // Mur Est (X = ecart)
  lesMurs.add(new Mur(ecart, 0, longueurMurPixels, 90)); 
  // Mur Ouest (X = -ecart)
  lesMurs.add(new Mur(-ecart, 0, longueurMurPixels, -90)); 

}

void draw() {
  background(135, 206, 235);
  lights();

  pushMatrix();
  translate(0, 250, 0); 
  fill(50, 150, 50);
  box(2000, 5, 2000);
  popMatrix();

  for (Tour t : lesTours) {
    t.display();
  }
  for (Mur m : lesMurs) {
    m.display();
  }
}
class Mur {
  float x, z, angle;
  float longueurPixels;
  
  int nbColonnes; 
  int nbLignes = 38; 
  
  int brickW = 10;
  int brickH = 5;
  int brickD = 5;
  int spacingY = 5;
  
  Mur(float x, float z, float longueurPx, float angleDeg) {
    this.x = x;
    this.z = z;
    this.longueurPixels = longueurPx;
    this.angle = radians(angleDeg);
    this.nbColonnes = (int)(longueurPixels / brickW);
  }
  
  void display() {
    pushMatrix();
    translate(x, 0, z);
    rotateY(angle);
    
    // <--- MODIFIÉ : Calcul pour coller le mur au sol
    // Si on réduit la hauteur, le mur a tendance à flotter ou s'enfoncer.
    // On le descend de 40px pour compenser la différence avec les tours.
    float ajustementHauteur = 50; 
    
    translate(-(nbColonnes * brickW) / 2, -(nbLignes * spacingY) / 2 + ajustementHauteur, 0);
    
    // --- DESSIN DES BRIQUES ---
    for (int ligne = 0; ligne < nbLignes; ligne++) {
      pushMatrix();
      translate(0, ligne * spacingY, 0);
      
      boolean isOffsetRow = (ligne % 2 != 0);
      float offset = isOffsetRow ? brickW / 2.0 : 0;
      translate(offset, 0, 0);
      
      for (int col = 0; col < nbColonnes; col++) {
        if (isOffsetRow && col == nbColonnes - 1) continue; 
        
        pushMatrix();
        translate(col * brickW, 0, 0);
        fill(249, 234, 187);
        box(brickW, brickH, brickD);
        popMatrix();
      }
      popMatrix();
    }
    
    drawCreneaux();
    
    popMatrix();
  }
  
  void drawCreneaux() {
    pushMatrix();
    translate(0, -brickH, 0); 
    float gap = brickW * 0.5;
    float step = brickW + gap;
    
    for (float cx = 0; cx < nbColonnes * brickW - brickW; cx += step) {
      pushMatrix();
      translate(cx + brickW/2, 0, 0);
      fill(249, 234, 187);
      box(brickW, brickH, brickD);
      popMatrix();
    }
    popMatrix();
  }
}
// Création de la tour
class Tour {
  float x, z;
  
  // Les variables globales de la tour
  int decal = 0;
  int nbColonnes = 10;
  int nbLignes = 38;
  int brickW = 10;
  int brickH = 5;
  int brickD = 5;
  int spacingY = 5;
  
  // Constructeur
  Tour(float x, float z) {
    this.x = x;
    this.z = z;
  }

  void display() {
    pushMatrix();
    translate(x, 0, z);
    float angleVersLeCentre = atan2(x, z); 
    rotateY(angleVersLeCentre + PI);

    float distance = 50;  
    int nbMurs = 4;

    for (int i = 0; i < nbMurs; i++) {
      pushMatrix();

      rotateY(radians(90 * i));
      translate(2.5, 50, distance);

      // Mur 0 = porte
      boolean aUnePorte = (i == 0); 
      drawWall(aUnePorte);
      
      drawCreneaux();

      popMatrix();
    }

    drawSol();
    
    popMatrix();
  }

  // Fonction qui gère les murs
  void drawWall(boolean hasDoor) {
    pushMatrix();

    rotateY(radians(decal));
    translate(-(nbColonnes * brickW) / 2,
      -(nbLignes    * spacingY) / 2,
      0);

    // Gestions des meutrières
    float fente = 2.5; 
    int colCible = 4;

    // Paramètre de la porte
    int doorHeightIdx = 12; 
    int doorStartCol = 3;   
    int doorWidth = 4;      

    for (int ligne = 0; ligne < nbLignes; ligne++) {
      pushMatrix();
      translate(0, ligne * spacingY, 0);

      boolean isOffsetRow = (ligne % 2 != 0); 
      float offset = isOffsetRow ? brickW / 2.0 : 0;
      translate(offset, 0, 0);

      boolean inDoorZoneY = hasDoor && (ligne >= nbLignes - doorHeightIdx);
      
      boolean slotBas    = (ligne >= 5  && ligne < 9);
      boolean slotMilieu = (ligne >= 16 && ligne < 20);
      boolean slotHaut   = (ligne >= 27 && ligne < 31);
      boolean isMeurtriere = slotBas || slotMilieu || slotHaut;

      for (int col = 0; col < nbColonnes; col++) {
        
        boolean skipBrick = false;      
        boolean drawHalfRight = false;  
        boolean drawHalfLeft = false;   
        boolean brickDrawn = false;     

        if (inDoorZoneY) {
          if (!isOffsetRow) {
             if (col >= doorStartCol && col < doorStartCol + doorWidth) {
               skipBrick = true; 
             }
             if (col == doorStartCol - 1) { 
               drawHalfRight = true; 
             }
             if (col == doorStartCol + doorWidth) {
               skipBrick = true; 
               drawHalfLeft = true; 
             }
          }
          else {
             if (col >= doorStartCol && col < doorStartCol + doorWidth) {
               skipBrick = true; 
             }
          }
        }

        if (skipBrick && !drawHalfLeft) { 
           continue; 
        }

        pushMatrix();       
        
        if (drawHalfRight) {
           pushMatrix();
           translate(col * brickW + brickW * 0.75, 0, 0); 
           fill(249, 234, 187);
           box(brickW / 2.0, brickH, brickD);
           popMatrix();
           
           pushMatrix();
           translate(col * brickW, 0, 0);
           fill(249, 234, 187);
           box(brickW, brickH, brickD);
           popMatrix();

           brickDrawn = true;
        }
        
        else if (drawHalfLeft) {
           pushMatrix();
           translate(col * brickW + brickW * 0.25, 0, 0); 
           fill(249, 234, 187);
           box(brickW / 2.0, brickH, brickD); 
           popMatrix();
           brickDrawn = true;
        }

        else if (isMeurtriere && !brickDrawn && !inDoorZoneY) {
           
           if (isOffsetRow && col == colCible) {
             float w = (brickW - fente) / 2.0;
             
             pushMatrix();
             translate(col * brickW - (fente/2 + w/2), 0, 0); 
             fill(249, 234, 187);
             box(w, brickH, brickD);
             popMatrix();

             pushMatrix();
             translate(col * brickW + (fente/2 + w/2), 0, 0);
             fill(249, 234, 187);
             box(w, brickH, brickD);
             popMatrix();
             
             brickDrawn = true;
           }

           else if (!isOffsetRow && col == colCible) { 
             float w = brickW - fente/2.0;
             pushMatrix(); 
             translate(col * brickW - fente/4.0, 0, 0);
             fill(249, 234, 187);
             box(w, brickH, brickD);
             popMatrix();
             brickDrawn = true;
           }
           else if (!isOffsetRow && col == colCible + 1) { 
             float w = brickW - fente/2.0;
             pushMatrix(); 
             translate(col * brickW + fente/4.0, 0, 0);
             fill(249, 234, 187);
             box(w, brickH, brickD);
             popMatrix();
             brickDrawn = true;
           }
        }

        if (!brickDrawn) {
           pushMatrix();
           translate(col * brickW, 0, 0);
           fill(249, 234, 187);
           box(brickW, brickH, brickD);
           popMatrix();
        }
        popMatrix(); 
      } 
      popMatrix(); 
    } 
    popMatrix(); 
  }

  // Fonction pour le sol
  void drawSol() {
    pushMatrix();
    float solY = (nbLignes * spacingY) / 2 + brickH/2 + 45.5;
    translate(0, solY, 0);
    rotateX(HALF_PI);
    fill(249, 234, 187);
    float solSize = nbColonnes * brickW + brickW * 0.50;
    rectMode(CENTER);
    rect(0, 0, solSize, solSize);
    popMatrix();
  }

  // Fonction pour les créneaux
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
      fill(249, 234, 187);
      box(brickW, brickH, brickD);
      translate(0, -brickH, 0);
      box(brickW, brickH, brickD);
      popMatrix();
    }
    popMatrix();
  }
}
