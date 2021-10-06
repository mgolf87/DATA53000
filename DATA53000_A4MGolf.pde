PFont font; 
PImage mapImage;

      
FloatTable locationTable;
FloatTable dataTable;
float dataMin = MAX_FLOAT;
float dataMax = MIN_FLOAT;
int rowCount;
int currentColumn = 0;
int toggleCount = 0;



void setup() {
//   font = loadFont("Univers-Bold-12.vlw");
//   textFont(font);
  // Display size
   size(650,400);

   dataTable = new FloatTable("statesCovid.txt"); // covid 3 variables - active, total, deaths
   mapImage = loadImage("map.png");  // map of USA
   locationTable = new FloatTable("locations.tsv"); // state locations (x,y) 
   rowCount = locationTable.getRowCount();
   
   // Read the data table
   for (int row = 0; row < rowCount; row++) { // first index is 0
     float value = dataTable.getFloat(row, 0);
    
     if (value > dataMax) { // checking values as we iterate
       dataMax = value;
     }
     if (value < dataMin) {
       dataMin = value;
     } 
   } 
}

void draw() {
   background(255); // sets white background color
   image(mapImage,0,0); // load image at its predefined size
  
   noStroke(); // pulling the state locations from the file
   for (int row = 0 ; row < rowCount; row++ ) {
      float x = locationTable.getFloat(row,0);
      float y = locationTable.getFloat(row,1);
      drawColorData(x,y,row);
     
   }
   // Draw a scale bar by calling the function
   drawColorScale();
}

void drawColorScale() {
 
   // Generating a color scale legend from #FF0000 (Red) to #FFCC00 (Orange) that maps with the data

  int colorWidth = 20;
  if (currentColumn == 0 ) {       // first column of datatable - Active Cases
      textSize(18);
      text("Active COVID19 Cases", 225, 20); // set title
      textSize(12);
      text(" Active",20,260);               // set scalebar title
  } else if (currentColumn == 1) {           // second column of datatable - Total Cases
      textSize(18);
      text("State Total COVID19 Cases", 225, 20);
      textSize(12);
      text(" Total",20,260);
  } else {
      textSize(18);
      text("State Deaths from COVID19", 225, 20);  // third column of datatable - Total Deaths
      textSize(12);
      text(" Deaths",20,260);
  }
  text(dataMin, 20, 280); // scalebar limits
  text(dataMax, 9* colorWidth + colorWidth, 280);
  
  for ( int i = 0;  i < 10; i = i + 1) {
    
      // Draw the rectangle for scalebar
      int x1 =  50 + i*colorWidth;
      int y1 =  260;
      int x2 =   i * colorWidth + colorWidth;
      int y2 =   265;
      
      float percent =  norm(i,1,10);
      color squareColor = lerpColor(#FF0000,#FFCC00,percent);
      rectMode(CORNERS);
      fill(squareColor);
      rect(x1,y1,x2,y2);
  }
}

void mousePressed() {
  // toggles data when pressed
  toggleCount += 1;
  
  // This ranges from 0 - 2
  currentColumn = toggleCount % 3; // ensures we loop back to first column
  
  // update the dataMin and dataMax with the currentColumn
  dataMin = dataTable.getColumnMin(currentColumn);
  dataMax = dataTable.getColumnMax(currentColumn);
  
}

void mouseMoved() {
  
    for (int row = 0 ; row < rowCount; row++ ) {
      float x = locationTable.getFloat(row,0);
      float y = locationTable.getFloat(row,1);
      
     
   }
}

void keyPressed() {
  
  // once we click the mouse, we can also toggle data displayed with spacebar
  
  if (key == ' ') {
  toggleCount += 1;
  
  // This ranges from 0 - 2
  currentColumn = toggleCount % 3;
  
  // update the dataMin and dataMax
  dataMin = dataTable.getColumnMin(currentColumn);
  dataMax = dataTable.getColumnMax(currentColumn);
}
}

void drawColorData(float x, float y, int row) {
  
   // sets the bubble color relative to the max/min values
   float value = dataTable.getFloat(row,currentColumn); 
   float percent = norm(value,dataMin,dataMax);
   color bubbleColor = lerpColor(#FF0000,#FFCC00,percent);
   
   float radius = percent * 20; // sets the size of bubbles relative to their percent representation of the min/max
   
   // when bubbles are moused over we display the numeric value for the current toggled data
   if ( dist(mouseX,mouseY,x,y) < 2*radius * .45) {
        //  Specify the value over the bubble
        noStroke();
        fill(0);
        textSize(12);
        text(value,x,y-5);
       
   }
   // fills the bubbles with the intensity of color and relative size
   fill(bubbleColor);
   ellipse(x,y,radius,radius);
   
   
}
