import processing.opengl.*;

QueasyCam cam;
int decal = 0;
int nbColonnes = 10;
int nbLignes = 38;
int brickW = 10;
int brickH = 5;
int brickD = 5;
int spacingY = 5;

// Variables pour les listes
ArrayList<Tour> lesTours; 
ArrayList<Mur> lesMurs;

// Variable pour la Skybox
PShape skybox; 

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  cam.position.z += e * 20;
}

void setup() {
  size(1280, 720, P3D);
  cam = new QueasyCam(this);
  cam.position.set(0, -200, 500); 
  cam.speed = 3;
  cam.sensitivity = 0.8;

  lesTours = new ArrayList<Tour>();
  lesMurs = new ArrayList<Mur>();

  // --- CONFIGURATION DU CHÂTEAU ---
  int ecart = 250; 
  
  lesTours.add(new Tour(-ecart, -ecart, 10, 38)); 
  lesTours.add(new Tour(ecart, -ecart, 10, 38));  
  lesTours.add(new Tour(ecart, ecart, 10, 38));   
  lesTours.add(new Tour(-ecart, ecart, 10, 38));  
  
  int longueurMurPixels = (ecart * 2) - 130; 
  
  lesMurs.add(new Mur(0, -ecart, longueurMurPixels, 0, false)); 
  lesMurs.add(new Mur(0, ecart, longueurMurPixels, 180, true)); 
  lesMurs.add(new Mur(ecart, 0, longueurMurPixels, 90, false)); 
  lesMurs.add(new Mur(-ecart, 0, longueurMurPixels, -90, false));

  // skybox
  PImage textureCiel = loadImage("ciel.jpg"); 
  
  skybox = createShape(SPHERE, 1000); 
  
  if (textureCiel != null) {
    skybox.setTexture(textureCiel);
  }
  skybox.setStroke(false); 
}

void draw() {  
  background(135, 206, 235);
  pushMatrix();
  translate(cam.position.x, cam.position.y, cam.position.z);
  noLights(); 
  shape(skybox);
  popMatrix();
  lights(); 

  pushMatrix();
  translate(0, 250, 0); 
  fill(50, 150, 50);
  noStroke(); 
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
  PShape formeMur;
  float x, z, angle;
  
  Mur(float x, float z, float longueurPx, float angleDeg, boolean aUnPortail) {
    this.x = x;
    this.z = z;
    this.angle = radians(angleDeg);
    
    // Calculs initiaux
    int cols = (int)(longueurPx / brickW);
    int rows = 34; // Hauteur par défaut
    int gateW = 8;
    int gateH = 18;
    int gateStart = (cols - gateW) / 2;
    
    // CONSTRUCTION UNIQUE DE LA FORME
    construireMur(cols, rows, aUnPortail, gateStart, gateW, gateH);
  }
  
  void construireMur(int nbColonnes, int nbLignes, boolean hasGate, int gateStartCol, int gateWidthCols, int gateHeightRows) {
    formeMur = createShape(GROUP);
    
    // Ajustement hauteur pour eviter que le mur vole
    float ajustementHauteur = 60; 
    float startY = -(nbLignes * spacingY) / 2 + ajustementHauteur;
    float startX = -(nbColonnes * brickW) / 2;

    for (int ligne = 0; ligne < nbLignes; ligne++) {
      boolean isOffsetRow = (ligne % 2 != 0);
      float offset = isOffsetRow ? brickW / 2.0 : 0;
      float currentY = startY + (ligne * spacingY);
      
      boolean inGateZoneY = hasGate && (ligne >= nbLignes - gateHeightRows);
      
      for (int col = 0; col < nbColonnes; col++) {
        boolean skipBrick = false;        
        boolean drawHalfRight = false;  
        boolean drawHalfLeft = false;    
        
        // Gestion de la porte du mur
        if (inGateZoneY) {
          if (!isOffsetRow) {
             if (col >= gateStartCol && col < gateStartCol + gateWidthCols) skipBrick = true; 
             if (col == gateStartCol - 1) drawHalfRight = true; 
             if (col == gateStartCol + gateWidthCols) { skipBrick = true; drawHalfLeft = true; }
          } else {
             if (col >= gateStartCol && col < gateStartCol + gateWidthCols) skipBrick = true; 
          }
        }

        if (skipBrick && !drawHalfLeft) continue;

        float currentX = startX + (col * brickW) + offset;
        
        // A. Demi-brique Droite
        if (drawHalfRight) {
           ajouterBrique(currentX + brickW * 0.75, currentY, brickW / 2.0, brickH, brickD);
           ajouterBrique(currentX, currentY, brickW, brickH, brickD);
        }
        // B. Demi-brique Gauche
        else if (drawHalfLeft) {
           ajouterBrique(currentX + brickW * 0.25, currentY, brickW / 2.0, brickH, brickD);
        }
        // C. Brique standard
        else {
           ajouterBrique(currentX, currentY, brickW, brickH, brickD);
        }
      }
    }
    
    // Ajout de la porte en bois
    if (hasGate) {
      float gateCenterX = startX + (gateStartCol * brickW) + (gateWidthCols * brickW / 2.0);
      float gateCenterY = (nbLignes * spacingY) / 2.0 + startY - (gateHeightRows * spacingY / 2.0) - (brickH/2.0) + (nbLignes*spacingY/2); 
      gateCenterY = startY + (nbLignes * spacingY) - (gateHeightRows * spacingY / 2.0) - (brickH/2.0);

      PShape porte = createShape(BOX, gateWidthCols * brickW, gateHeightRows * spacingY, 2);
      porte.setFill(color(101, 67, 33));
      porte.setStroke(false);
      porte.translate(gateCenterX, gateCenterY, -2);
      formeMur.addChild(porte);
    }
    
    // Créneaux
    ajouterCreneaux(nbColonnes, startX, startY);
  }

  void ajouterBrique(float x, float y, float w, float h, float d) {
    PShape b = createShape(BOX, w, h, d);
    b.setFill(color(249, 234, 187));
    b.setStroke(true);
    b.setStroke(color(0));
    b.translate(x, y, 0);
    formeMur.addChild(b);
  }
  void ajouterCreneaux(int cols, float startX, float startY) {
    float y = startY - brickH; // Au dessus du mur
    float gap = brickW * 0.5;
    float step = brickW + gap;
    for (float cx = 0; cx < cols * brickW - brickW; cx += step) {
      ajouterBrique(startX + cx + brickW/2, y, brickW, brickH, brickD);
      ajouterBrique(startX + cx + brickW/2, y - brickH, brickW, brickH, brickD);
    }
   
  }
  void display() {
    pushMatrix();
    translate(x, 0, z);
    rotateY(angle);
    shape(formeMur);
    popMatrix();
  }
}
class Tour {
  PShape formeTour;
  float x, z;
  
  // Config
  int nbColonnes; 
  int nbLignes;   
  int brickW = 10;
  int brickH = 5;
  int brickD = 5;
  int spacingY = 5;

  // Variables internes
  float fente = 2.5; 
  int colCible = 4;
  int doorHeightIdx = 12; 
  int doorStartCol = 3;   
  int doorWidth = 4; 
  
  Tour(float x, float z, int cols, int rows) {
    this.x = x;
    this.z = z;
    this.nbColonnes = cols; 
    this.nbLignes = rows;   
    
    construireTour(); 
  }
  
  void construireTour() {
    formeTour = createShape(GROUP);
    
    float distance = 50;  
    int nbMurs = 4;

    for (int i = 0; i < nbMurs; i++) {
      // le pivot sert a avoir une tour coherente 
      PShape pivot = createShape(GROUP);
      
      pivot.rotateY(radians(90 * i));
      
      PShape murGeometrie = createShape(GROUP);
      boolean aUnePorte = (i == 0); 
      genererBriquesMur(murGeometrie, aUnePorte);
      genererCreneaux(murGeometrie);
      
      murGeometrie.translate(2.5, 50, distance);
      
      pivot.addChild(murGeometrie);
      formeTour.addChild(pivot);
    }
    
    genererSol();
  }

  void genererBriquesMur(PShape groupeMur, boolean hasDoor) {
    float startX = -(nbColonnes * brickW) / 2.0;
    float startY = -(nbLignes * spacingY) / 2.0;

    for (int ligne = 0; ligne < nbLignes; ligne++) {
      float currentY = startY + (ligne * spacingY);
      boolean isOffsetRow = (ligne % 2 != 0); 
      float offset = isOffsetRow ? brickW / 2.0 : 0;
      
      boolean inDoorZoneY = hasDoor && (ligne >= nbLignes - doorHeightIdx);
      boolean isMeurtriere = (ligne >= 5 && ligne < 9) || (ligne >= 16 && ligne < 20) || (ligne >= 27 && ligne < 31);

      for (int col = 0; col < nbColonnes; col++) {
        boolean skipBrick = false;      
        boolean drawHalfRight = false;  
        boolean drawHalfLeft = false;   
        
        if (inDoorZoneY) {
          if (!isOffsetRow) {
             if (col >= doorStartCol && col < doorStartCol + doorWidth) skipBrick = true; 
             if (col == doorStartCol - 1) drawHalfRight = true; 
             if (col == doorStartCol + doorWidth) { skipBrick = true; drawHalfLeft = true; }
          } else {
             if (col >= doorStartCol && col < doorStartCol + doorWidth) skipBrick = true; 
          }
        }
        if (skipBrick && !drawHalfLeft) continue; 

        float currentX = startX + (col * brickW) + offset;
        
        if (drawHalfRight) {
           ajoutB(groupeMur, currentX + brickW * 0.75, currentY, brickW/2.0);
           ajoutB(groupeMur, currentX, currentY, brickW);
        }
        else if (drawHalfLeft) {
           ajoutB(groupeMur, currentX + brickW * 0.25, currentY, brickW/2.0);
        }
        else if (isMeurtriere && !inDoorZoneY) {
           if (isOffsetRow && col == colCible) {
             float w = (brickW - fente) / 2.0;
             ajoutB(groupeMur, currentX - (fente/2 + w/2), currentY, w);
             ajoutB(groupeMur, currentX + (fente/2 + w/2), currentY, w);
           }
           else if (!isOffsetRow && col == colCible) { 
             ajoutB(groupeMur, currentX - fente/4.0, currentY, brickW - fente/2.0);
           }
           else if (!isOffsetRow && col == colCible + 1) { 
             ajoutB(groupeMur, currentX + fente/4.0, currentY, brickW - fente/2.0);
           } 
           else {
             ajoutB(groupeMur, currentX, currentY, brickW);
           }
        }
        else {
           ajoutB(groupeMur, currentX, currentY, brickW);
        }
      } 
    } 
  }

  void ajoutB(PShape grp, float x, float y, float w) {
    PShape b = createShape(BOX, w, brickH, brickD);
    b.setFill(color(249, 234, 187));
    b.setStroke(true);
    b.setStroke(color(0)); 
    b.translate(x, y, 0);
    grp.addChild(b);
  }

  void genererSol() {
    float solY = (nbLignes * spacingY) / 2 + brickH/2 + 45.5;
    float solSize = nbColonnes * brickW + brickW * 0.50;
    
    PShape sol = createShape(RECT, 0, 0, solSize, solSize);
    sol.setFill(color(249, 234, 187));
    sol.translate(-solSize/2, -solSize/2); // Centrage manuel
    
    PShape supportSol = createShape(GROUP);
    supportSol.addChild(sol);
    supportSol.rotateX(HALF_PI);
    supportSol.translate(0, solY, 0);
    
    formeTour.addChild(supportSol);
  }

  void genererCreneaux(PShape grp) {
    float startX = -(nbColonnes * brickW) / 2.0;
    float startY = -(nbLignes * spacingY) / 2.0 - brickH;
    float gap = brickW * 0.5;
    float step = brickW + gap;
    
    for (float x = 0; x < nbColonnes * brickW; x += step) {
      ajoutB(grp, startX + x + brickW/2, startY, brickW);
      ajoutB(grp, startX + x + brickW/2, startY - brickH, brickW);
    }
  }

  void display() {
    pushMatrix();
    translate(x, 0, z);
    float angleVersLeCentre = atan2(x, z); 
    rotateY(angleVersLeCentre + PI);
    
    shape(formeTour); 
    
    popMatrix();
  }
}
