class TwoDeeLayer {
  int w, h;
  int[][] grid;
  int[][] gridBuffer;
  int[][][] rules;
  float ox, oy;
  PShape[][] cells;
  color[] colors;
  int cellSize;
  int[] selection = new int[3]; // {key, type, neighbors}
  boolean selected = false;
  boolean empty = false;
  int emptyCell = 0;
  
  //////////////////////////////// INITIALIZATION
  TwoDeeLayer(int wi, int hi, int ci) {
    w = wi; h = hi;
    cellSize = ci;
    ox = 0; oy = 0;
    grid = new int[w][h];
    gridBuffer = new int[w][h];
    cells = new PShape[w][h];
    rules = new int[26][cellTypes][9];
    for(int q=0; q<rules.length; q++) {
      for(int w=0; w<rules[q].length; w++) {
        for(int e=0; e<rules[q][w].length; e++) {
          rules[q][w][e] = w;
          rules[q][w][e] = int(random(0, cellTypes));
        }
      }
    }
    // set colors
    colors = new color[rules.length];
    //float c = random(0, 360);

    for(int q=0; q<colors.length; q++) {
      float c = random(0, 360);
      colors[q] = color(c, 100, 100, 1/float(fpf));
      //c += 135;
      //if(c > 360) {c -= 360;}
    }
    // fill grid & create cell shapes
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        grid[x][y] = 0;
        gridBuffer[x][y] = 0;
        cells[x][y] = createShape(RECT, x * cellSize, y * cellSize, cellSize, cellSize);
        cells[x][y].setStroke(false);
        cells[x][y].setFill(colors[grid[x][y]]);
      }
    }
  }
  
  //////////////////////////// SEED LAYER
  void seed(float p) {
    grid[int(random(0, w - 1))][int(random(0, h - 1))] = 1;
    //for (int x = 0; x < w; x++) {
    //  for (int y = 0; y < h; y++) {
    //  if(random(0, 1) < p) {grid[x][y] = int(random(cellTypes));} else {grid[x][y] = 0;}
    //  cells[x][y].setFill(colors[grid[x][y]]);
    //  }  
    //}
  }
  
  //////////////////////////// STEP
  void step(int n) {
    for(int q = 0; q < n; q++) {
      for(int x = 0; x < w; x++) {
        for(int y = 0; y < h; y++) {
          int cellState = grid[x][y];
          // get neighbors
          int neighbors = getNeighborsWrap(x, y);
          // update grid
          gridBuffer[x][y] = rules[cK][cellState][neighbors];
        }
      }
      // push full grid
      empty = true;
      emptyCell = grid[0][0];
      for (int x = 0; x < w; x++) {
        for (int y = 0; y < h; y++) {
          if(grid[x][y] != emptyCell && empty == true) {
            empty = false;
          }
          grid[x][y] = gridBuffer[x][y];
          cells[x][y].setFill(colors[grid[x][y]]);
        }
      }
      if (empty) {
        seed(0.002);
      }
    }
  }
  
  ///////////////////////////// SET SPEED OF CHANGE
  void setSpeed(int fpf) {
    for(int q=0; q<colors.length; q++) {
      colors[q] = color(hue(colors[q]), saturation(colors[q]), brightness(colors[q]), (1/float(fpf)) + 0.05);
    }
  }
  
  //////////////////////////////// SYNAPSE
  void synapse(int[][] otherGrid, int xOffset, int yOffset, boolean stamp) {
    xOffset = -xOffset;
    yOffset = -yOffset;
    int otherW = otherGrid.length;
    int otherH = otherGrid[0].length;
    for(int x = 0; x < w; x++) {
       for(int y = 0; y < h; y++) {
        // if the offset fits
        if(x + xOffset >= 0 && x + xOffset < w && y + yOffset >= 0 && y + yOffset < h
          && x + xOffset < otherW && y + yOffset < otherH) {
          // if this cell type exists in the receiving layer
          if(otherGrid[x + xOffset][y + yOffset] < rules.length) {
            if(stamp == false) {
              // replace grid
              grid[x][y] = otherGrid[x + xOffset][y + yOffset];
              cells[x][y].setFill(colors[grid[x][y]]);
            } else if(otherGrid[x + xOffset][y + yOffset] != 0) {
              // stamp grid
              grid[x][y] = otherGrid[x + xOffset][y + yOffset];
              cells[x][y].setFill(colors[grid[x][y]]);
            }
          }
        } 
      }
    }
  }
  
  ////////////////////////////////// MUTATE RULES
  void mutate(int m) {
    for(int q=0; q<m; q++) {
      int t = int(random(0, cellTypes));
      int n = int(random(0, 9));
      rules[cK][t][n] = int(random(0, cellTypes));
    }
    //for(int q=0; q<m; q++) {
    //  int t = int(random(0, rules.length));
    //  float h = hue(colors[t]) + random(-10, 10);
    //  if(h < 0) {h += 360;}
    //  if(h > 360) {h -= 360;}
    //  float s = saturation(colors[t]);
    //  float b = brightness(colors[t]);
    //  colors[t] = color(h, s, b, (1/float(fpf)) + 0.1);
    //}
  }
  
  //////////////////////////// SET OFFSET
  void setOffset(float xOffset, float yOffset) {
    ox = xOffset;
    oy = yOffset;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        cells[x][y] = createShape(RECT, x * cellSize + ox, y * cellSize + oy, cellSize, cellSize);
        cells[x][y].setStroke(false);
        cells[x][y].setFill(colors[grid[x][y]]);
      }
    }
  }
  
  ////////////////////////////////// DRAW GRID
  void drawGrid() {
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        shape(cells[x][y]);
      }
    }
  }
  
  ////////////////////////////////// DRAW RULES
  //void drawRules() {
  //  float sw = (width - w*cellSize) / rules.length;
  //  float sh = height / (rules[0].length - 1);
  //  for(int i = 0; i < rules.length; i++) {
  //    for(int j = 0; j < rules[0].length; j++) {
  //      stroke(0, 0, 100, 1);
  //      strokeWeight(1);
  //      //fill(colors[rules[q][w]]);
  //      fill(hue(colors[rules[i][j]]), saturation(colors[rules[i][j]]), brightness(colors[rules[i][j]]), 1);
  //      rect((j*sw)+(w*cellSize), (i*sh), sw, sh);
  //    }
  //  }
  //}
  
  /////////////////////////////////////// DRAW RULES
  void drawRules() {
    float oX = w*cellSize;
    float sw = (width - (oX+1)) / cellTypes;
    float sh = height / 9;
    for(int i=0; i<cellTypes; i++){
      for(int j=0; j<9; j++){
        strokeWeight(1);
        stroke(0, 0, 100, 1);
        if(controlKey != '*') {
          fill(hue(colors[rules[cK][i][j]]), saturation(colors[rules[cK][i][j]]), brightness(colors[rules[cK][i][j]]), 1);
        } else {
          fill(0, 0, 20, 1);
        }
        rect(i*sw + oX, j*sh, sw, sh + 7);
        if(mouseOver(i*sw + oX, j*sh, sw, sh + 7) && controlKey != '*') {
          fill(0, 0, 100, 0.5);
          rect(i*sw + oX, j*sh, sw, sh + 7);
          selection[0] = cK;
          selection[1] = i;
          selection[2] = j;
        }
      }
    }
  }
  
  //////////////////////// MOUSE CLICKED
  void click() {
    if(rules[selection[0]][selection[1]][selection[2]] == cellTypes - 1) {
      rules[selection[0]][selection[1]][selection[2]] = 0;
    } else {
      rules[selection[0]][selection[1]][selection[2]]++;
    }
  }
      
    
  
  //////////////////////// GET RULES
  //void become(int[][] r, color[] c) {
  //  for(int t=0; t<rules.length; t++) {
  //    colors[t] = c[t];
  //    for(int n=0; n<rules[0].length; n++) {
  //      rules[t][n] = r[t][n];
  //    }
  //  }
  //}
  
  /////////////////// FLASH
  //void flash() {
  //  fill(0, 0, 100, 1);
  //  noStroke();
  //  rect(ox, oy, w*cellSize, h*cellSize);
  //}
  
  ///////////////////////////////// COUNTING NEIGHBORING CELLS, WRAPPING AROUND THE SCREEN
  int getNeighborsWrap(int x, int y) {
    int neighbors = 0;
    // NORTH
    if (y < h - 1) {
      if (grid[x][y + 1] != 0) {neighbors++;}
      // NORTHWEST
      if (x > 0) {if (grid[x - 1][y + 1] != 0) {neighbors++;}}
      else {if (grid[w - 1][y + 1] != 0) {neighbors++;}}
      // NORTHEAST
      if (x < w - 1) {if (grid[x + 1][y + 1] != 0) {neighbors++;}}
      else {if (grid[0][y + 1] != 0) {neighbors++;}}
    } else {
      // NORTH WRAP
      if (grid[x][0] != 0) {neighbors++;}
      // NORTHWEST WRAP
      if (x > 0) {if (grid[x - 1][0] != 0) {neighbors++;}}
      else {if (grid[w - 1][0] != 0) {neighbors++;}}
      // NORTHEAST WRAP
      if (x < w - 1) {if (grid[x + 1][0] != 0) {neighbors++;}}
      else {if (grid[0][0] != 0) {neighbors++;}}
    }
    // SOUTH
    if (y > 0) {
      if (grid[x][y - 1] != 0) {neighbors++;}
      // SOUTHWEST
      if (x > 0) {if (grid[x - 1][y - 1] != 0) {neighbors++;}}
      else {if (grid[w - 1][y - 1] != 0) {neighbors++;}}
      // SOUTHEAST
      if (x < w - 1) {if (grid[x + 1][y - 1] != 0) {neighbors++;}}
      else {if (grid[0][y - 1] != 0) {neighbors++;}}
    } else {
      // SOUTH WRAP
      if (grid[x][h - 1] != 0) {neighbors++;}
      // SOUTHWEST WRAP
      if (x > 0) {if (grid[x - 1][h - 1] != 0) {neighbors++;}}
      else {if (grid[w - 1][h - 1] != 0) {neighbors++;}}
      // SOUTHEAST WRAP
      if (x < w - 1) {if (grid[x + 1][h - 1] != 0) {neighbors++;}}
      else {if (grid[0][h - 1] != 0) {neighbors++;}}
    }
    // EAST
    if (x < w - 1) {
      if (grid[x + 1][y] != 0) {neighbors++;}
    } else {
      // EAST WRAP
      if (grid[0][y] != 0) {neighbors++;}
    }
    // WEST
    if (x > 0) {
      if (grid[x - 1][y] != 0) {neighbors++;}
    } else {
      // EAST WRAP
      if (grid[w - 1][y] != 0) {neighbors++;}
    }
    
    return neighbors;
  }
  
  ////////////////////////////// MOUSE OVER??
  //boolean mouseOver(float mx, float my) {
  //  if(mx > ox && mx < w*cellSize + ox) {
  //    if(my > oy && my < h*cellSize + oy) {
  //      fill(0, 0, 100, 0.3);
  //      noStroke();
  //      rect(ox, oy, w*cellSize, h*cellSize);
  //      return true;
  //    }
  //  }
  //  return false;
  //}
}
