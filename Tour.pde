QueasyCam cam; 
int nbColonnes = 10;      
int nbLignes = 38;        
int brickW = 10;          
int brickH = 5;           
int brickD = 5;          
int spacingY = 5;        
float decal = 0; 

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

    // MODIFICATION : On dit au mur 0 d'avoir une porte, les autres non
    boolean aUnePorte = (i == 0); 
    drawWall(aUnePorte);
    
    // On dessine les créneaux normalement
    drawCreneaux();
    
    popMatrix();
  }
  
  drawSol();
}

// MODIFICATION : La fonction prend maintenant un paramètre
void drawWall(boolean hasDoor) {
  pushMatrix();
  
  rotateY(radians(decal));
  translate(-(nbColonnes * brickW) / 2,
            -(nbLignes   * spacingY) / 2,
            0);

  // --- PARAMÈTRES DE LA PORTE ---
  int doorHeightIdx = 12; // Hauteur de la porte en nombre de briques
  int doorStartCol = 3;   // Colonne où commence la porte
  int doorWidth = 4;      // Largeur de la porte en briques (doit être pair pour centrer facilement)
  // ------------------------------

  for (int ligne = 0; ligne < nbLignes; ligne++) {
    pushMatrix();
    translate(0, ligne * spacingY, 0);

    // Vérifie si la ligne actuelle a un décalage (offset)
    boolean isOffsetRow = (ligne % 2 == 0);
    float offset = isOffsetRow ? brickW / 2.0 : 0;
    translate(offset, 0, 0);

    // Vérifie si nous sommes dans les lignes du bas (zone de la porte)
    boolean inDoorZoneY = hasDoor && (ligne >= nbLignes - doorHeightIdx);

    for (int col = 0; col < nbColonnes; col++) {
      
      // Logique pour savoir si on dessine, si on coupe, ou si on saute
      boolean skipBrick = false;
      boolean drawHalfRight = false; // Demi-brique à droite de la position actuelle
      boolean drawHalfLeft = false;  // Demi-brique à gauche (remplace la brique actuelle)

      if (inDoorZoneY) {
        // Indices des colonnes de la porte
        if (col >= doorStartCol && col < doorStartCol + doorWidth) {
          skipBrick = true; // On ne dessine pas les briques DANS la porte
        }

        // GESTION DES BORDS DROITS (Demi-briques)
        // Le décalage crée des trous sur une ligne sur deux.
        if (!isOffsetRow) {
           // Cas : Ligne SANS offset (les briques sont alignées sur la grille 0, 10, 20...)
           // Le trou de la porte (30 à 70) crée un vide après la col 2 et avant la col 7
           
           if (col == doorStartCol - 1) { 
             // Juste à GAUCHE de la porte : on ajoute une demi-brique pour combler le trou
             drawHalfRight = true; 
           }
           
           if (col == doorStartCol + doorWidth) {
             // Juste à DROITE de la porte : Cette brique dépasse dans la porte, 
             // on la remplace par une demi-brique décalée pour faire le bord droit.
             skipBrick = true; 
             drawHalfLeft = true;
           }
        }
        // Note : Si isOffsetRow est vrai, les briques s'alignent naturellement avec notre porte de largeur 4
        // (car 4 briques = 40px, et l'offset est de 5px, ça tombe juste sur les bords 30 et 70).
      }

      pushMatrix();
      translate(col * brickW, 0, 0);
      fill(249, 234, 187);

      // 1. Dessiner la brique normale si on ne doit pas la sauter
      if (!skipBrick) {
        box(brickW, brickH, brickD);
      }

      // 2. Dessiner une demi-brique ajoutée à droite (pour combler un trou)
      if (drawHalfRight) {
        pushMatrix();
        translate(brickW * 0.75, 0, 0); // Décalage pour centrer la demi-brique dans le vide
        box(brickW / 2.0, brickH, brickD);
        popMatrix();
      }

      // 3. Dessiner une demi-brique de remplacement (pour ne pas dépasser dans la porte)
      if (drawHalfLeft) {
         pushMatrix();
         translate(brickW * 0.25, 0, 0); // Légèrement décalé pour s'aligner au bord de la porte
         box(brickW / 2.0, brickH, brickD);
         popMatrix();
      }

      popMatrix();
    }
    popMatrix();
  }
  popMatrix();
}

// ... RESTE DU CODE (drawSol, drawCreneaux) INCHANGÉ ...
void drawSol(){
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
