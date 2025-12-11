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

    // MODIFICATION : On dit au mur 0 d'avoir une porte, les autres non
    boolean aUnePorte = (i == 0); 
    drawWall(aUnePorte);
    
    // On dessine les créneaux normalement
    drawCreneaux();

    popMatrix();
  }

  drawSol();
}

void drawWall(boolean hasDoor) {
  pushMatrix();

  rotateY(radians(decal));
  translate(-(nbColonnes * brickW) / 2,
    -(nbLignes   * spacingY) / 2,
    0);

  // --- REGLAGES ---
  float fente = 2.5; 
  int colCible = 4;

  // --- PARAMÈTRES DE LA PORTE ---
  int doorHeightIdx = 12; 
  int doorStartCol = 3;   
  int doorWidth = 4;      
  // ------------------------------

  for (int ligne = 0; ligne < nbLignes; ligne++) {
    pushMatrix();
    translate(0, ligne * spacingY, 0);

    // --- 1. CONFIGURATION DE LA LIGNE ---
    boolean isOffsetRow = (ligne % 2 != 0); // Correction : le décalage est sur les lignes impaires
    float offset = isOffsetRow ? brickW / 2.0 : 0;
    translate(offset, 0, 0);

    // Zones
    boolean inDoorZoneY = hasDoor && (ligne >= nbLignes - doorHeightIdx);
    
    boolean slotBas    = (ligne >= 5  && ligne < 9);
    boolean slotMilieu = (ligne >= 16 && ligne < 20);
    boolean slotHaut   = (ligne >= 27 && ligne < 31);
    boolean isMeurtriere = slotBas || slotMilieu || slotHaut;

    // --- 2. BOUCLE DES COLONNES ---
    for (int col = 0; col < nbColonnes; col++) {
      
      // Flags
      boolean skipBrick = false;      
      boolean drawHalfRight = false;  
      boolean drawHalfLeft = false;   
      boolean brickDrawn = false;     

      // --- LOGIQUE PORTE ---
      if (inDoorZoneY) {
        // Ligne PAIRE (non décalée) : On met des demi-briques pour faire le bord net
        if (!isOffsetRow) {
           if (col >= doorStartCol && col < doorStartCol + doorWidth) {
             skipBrick = true; 
           }
           // Bord GAUCHE de la porte
           if (col == doorStartCol - 1) { 
             drawHalfRight = true; 
           }
           // Bord DROIT de la porte
           if (col == doorStartCol + doorWidth) {
             skipBrick = true; 
             drawHalfLeft = true; 
           }
        }
        // Ligne IMPAIRE (décalée) : Les briques s'alignent naturellement sur le bord
        else {
           if (col >= doorStartCol && col < doorStartCol + doorWidth) {
             skipBrick = true; 
           }
        }
      }

      // Sauter le tour si c'est un trou de porte
      if (skipBrick && !drawHalfLeft) { 
          continue; 
      }

      // --- DESSIN ---
      pushMatrix();      
      // A. CAS : Demi-brique de DROITE (Bord GAUCHE de la porte)
      // C'est ici qu'était le bug : on doit dessiner la rustine ET la brique normale.
      if (drawHalfRight) {
          // 1. La "rustine" (le petit bout pour combler le trou vers la porte)
          pushMatrix();
          translate(col * brickW + brickW * 0.75, 0, 0); 
          fill(249, 234, 187);
          box(brickW / 2.0, brickH, brickD);
          popMatrix();
          
          // 2. ET on dessine la brique normale de la colonne (pour ne pas avoir de trou derrière)
          pushMatrix();
          translate(col * brickW, 0, 0);
          fill(249, 234, 187);
          box(brickW, brickH, brickD);
          popMatrix();

          brickDrawn = true;
      }
      
      // B. CAS : Demi-brique de GAUCHE (Bord DROIT de la porte)
      // Ici c'est un remplacement (on coupe ce qui dépasse), donc on ne dessine QUE la demi.
      else if (drawHalfLeft) {
          pushMatrix();
          translate(col * brickW + brickW * 0.25, 0, 0); 
          fill(249, 234, 187);
          box(brickW / 2.0, brickH, brickD); 
          popMatrix();
          brickDrawn = true;
      }

      // C. CAS : MEURTRIÈRES
      else if (isMeurtriere && !brickDrawn && !inDoorZoneY) {
          
          // C1. Ligne Impaire (Décalée)
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

          // C2. Ligne Paire (Alignée)
          else if (!isOffsetRow && col == colCible) { // Brique gauche du trou
            float w = brickW - fente/2.0;
            pushMatrix(); 
            translate(col * brickW - fente/4.0, 0, 0);
            fill(249, 234, 187);
            box(w, brickH, brickD);
            popMatrix();
            brickDrawn = true;
          }
          else if (!isOffsetRow && col == colCible + 1) { // Brique droite du trou
            float w = brickW - fente/2.0;
            pushMatrix(); 
            translate(col * brickW + fente/4.0, 0, 0);
            fill(249, 234, 187);
            box(w, brickH, brickD);
            popMatrix();
            brickDrawn = true;
          }
      }

      // D. CAS STANDARD (Brique normale)
      if (!brickDrawn) {
          pushMatrix();
          translate(col * brickW, 0, 0);
          fill(249, 234, 187);
          box(brickW, brickH, brickD);
          popMatrix();
      }
      popMatrix(); // Fin du dessin de la brique courante
    } // Fin boucle colonnes

    popMatrix(); // Fin ligne
  } // Fin boucle lignes

  popMatrix(); // Fin mur
}

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
