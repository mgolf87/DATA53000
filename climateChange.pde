
// This function is required, this is called once, and used to setup your 
// visualization environment
int mode = 0;
int modeCount = 0;
float dataMin;
float dataMax;

int columnCount = 0;
int[] years;
int yearMin;
int yearMax;
FloatTable data;
float plotX1, plotY1;
float plotX2, plotY2;

float labelX, labelY;

// Smooth transition
Integrator[] interpolators;

Button gridToggle;

// Small tick line
int volumeIntervalMinor = 5;

// Big tick line
int volumeInterval = 10;

// data parameter selected
int currentColumn;
// x axis interval
int yearInterval = 2;

int rowCount;


// Tab variables for the menus
float[] tabLeft, tabRight; // Add above setup() 
float tabTop, tabBottom;
float tabPad = 10;


void setup() {
   // This is your screen resolution, width, height
   //  upper left starts at 0, bottom right is max width,height
   size(1500,1000);

  
  // This calls the class FloatTable - java class and imports our data
  data = new FloatTable("climate.txt");
  gridToggle = new Button(0, 0, 50, 25, "Grid", 0, 200, 200);

  // Retrieve number of columns in the dataset
  columnCount = data.getColumnCount();
  dataMin = 0;
  dataMax = data.getTableMax();
  years = int(data.getRowNames());  
  yearMin = years[0];
  yearMax = years[years.length - 1];
  
  // Corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;

    // set the data entries or rows and create an instance of the integrator
    rowCount = data.getRowCount();
    interpolators = new Integrator[rowCount];

    for (int row = 0; row < rowCount; row++) {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = 0.05; // Set lower than the default
    }  
  
 
  
  
}

//Require function that outputs the visualization specified in this function
// for every frame. 
void draw() {
  
  
  // Filling the screen white (FFFF) -- all ones, black (0000)
  background(255);
  


  drawVisualizationWindow();
  drawGraphLabels();


  //drawDataBars(0); // for bar graph 
  
  // this gives line graph - bubbles possible if we use the commented out code
  stroke(#5679c1); noFill(); // make sure no weird background
  strokeWeight(2);
  drawDataCurve(currentColumn); // calls then draws a smooth line graph with curves instead of sharpness
  drawDataHighlight(currentColumn); // calls the function for bubbles when roll over
  
  //stroke(#5679c1);
  //strokeWeight(10); // comment these out for bubbles on line graph
  //drawDataPoints(currentColumn);
  
  // hold grid button to display grids
  if (gridToggle.isClicked()) {
    for (int row = 0; row < rowCount; row++) {
      if (years[row] % 2 == 0) { // plot all even years or every second year
        float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
    
        stroke(#C4C2C1);
        strokeWeight(2);
        // Long verticle line over each year interval
        line(x, plotY1, x, plotY2);
  }
    }
  }
  
  // sets the button up
  gridToggle.update();
  gridToggle.render();
  
   // These functions contain the labels along with the tick marks
  drawYTickMarks();
  drawXTickMarks();
  drawTitleTabs();
  
  // ensures smooth transition
  for (int row = 0; row < rowCount; row++) { 
    interpolators[row].update( );
 
  }
}

// function to draw the title tabs are the top which enables data switching
void drawTitleTabs() { 
  rectMode(CORNERS); 
  noStroke( ); 
  textSize(20); 
  textAlign(LEFT);
  // On first use of this method, allocate space for an array
  // to store the values for the left and right edges of the tabs.
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15; 
  tabBottom = plotY1;
  for (int col = 0; col < columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    // If the current tab, set its background white; otherwise use pale gray.
    fill(col == currentColumn ? 255 : 224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    // If the current tab, use black for the text; otherwise use dark gray.
    fill(col == currentColumn ? 0 : 64);
    text(title, runningX + tabPad, plotY1 - 10);
    runningX = tabRight[col];
  }
}

// ensures when we click on the tabs it transitions
void mousePressed() {
  
  // This is modulating from 1 to 3
  //  currentColumn = columnCount % 3;
  //  columnCount += 1;
   if (mouseY > tabTop && mouseY < tabBottom) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]) {
        setColumn(col);
      }
    }
  }
}


// needed to set the column or which set of data we are using
void setColumn(int col) {
       if (col != currentColumn) {
         currentColumn = col;
          for (int row = 0; row < rowCount; row++) {
            interpolators[row].target(data.getFloat(row, col));
          }
       }  
}

// Draws a curved edge line graph
void drawDataCurve(int col) {
  beginShape( );
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1); curveVertex(x,y);
      // Double the curve points for the start and stop
      if ((row == 0) || (row == rowCount-1)) {
        curveVertex(x,y);
    }
   }
 }
  endShape( );
}


// Function for highlighting the data point on the graph that the mouse is over
void drawDataHighlight(int col) {
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      if (dist(mouseX, mouseY, x, y) < 3) {
        strokeWeight(10);
        point(x, y);
        fill(0);
        textSize(10);
        textAlign(CENTER);
        text(nf(value, 0, 2) + " (" + years[row] + ")", x, y-8);
      }
    }
  }
}

// sets the y ticks both major and minor as well as their interval
void drawYTickMarks() {
  
  textSize(10);

  fill(0);
  stroke(0);
  strokeWeight(1);
  for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor) { 
    if (v % volumeIntervalMinor == 0) { // If a tick mark
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v % volumeInterval == 0) { // If a major tick mark
        if (v == dataMin) {
          textAlign(RIGHT); // Align by the bottom
        } else if (v == dataMax) {
          textAlign(RIGHT, TOP); // Align by the top
        } else {
          textAlign(RIGHT, CENTER); // Center vertically
        }
        text(floor(v), plotX1 - 10, y);
        line(plotX1 - 4, y, plotX1, y); // Draw major tick
      } else {
        line(plotX1 - 2, y, plotX1, y); // Draw minor tick
      }
    }
  }  
  
}

// sets X axis ticks and which years are displayed
void drawXTickMarks() {
  
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);


  for (int row = 0; row < rowCount; row++) {
    if (years[row] % 2 == 0) { // plot all even years or every second year
      stroke(0);
      strokeWeight(5);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + 10);
      
      
      //stroke(#C4C2C1);
      //strokeWeight(.5);
      //// Long verticle line over each year interval
      //line(x, plotY1, x, plotY2);
    }
  } 
  
}

void drawVisualizationWindow() {
    fill(255);
  rectMode(CORNERS);
  //noStroke( );
  rect(plotX1, plotY1, plotX2, plotY2);
  
}

// Sets the labels for the axis dependent on the dataset selected
void drawGraphLabels() {
  fill(0);
  textSize(15);
  textAlign(CENTER, CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
  if ( currentColumn == 0) {
    text("Millions\nSquare km", labelX, (plotY1+plotY2)/2);
  } else if (currentColumn == 1) {
      text("Celsius", labelX, (plotY1+plotY2)/2);
  } else if (currentColumn == 2) {
    text("CO2\nPPM", labelX, (plotY1+plotY2)/2);
  }
  
}
