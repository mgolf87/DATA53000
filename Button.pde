class Button
{
  PVector Pos = new PVector(0,0);
  float Width = 0;
  float Height = 0;
  color Color;
  String Text;
  Boolean Pressed = false;
  Boolean Clicked = false;
  
  // Constructor to create a button
  Button(int x, int y, int w, int h, String t, int r, int g, int b) {
   Pos.x = x;
   Pos.y = y;
   Width = w;
   Height = h;
   Color = color(r, g, b);
   Text = t;
  }
  void update() { // must be in draw() to get clicks
   if (mousePressed == true && mouseButton == LEFT && Pressed == false) {
    Pressed = true;
    // defines the boundary of the buttom
    if(mouseX >= Pos.x && mouseX <= Pos.x + Width && mouseY >= Pos.y && mouseY <= Pos.y + Height) {
      Clicked = true;
    }
   } else {
     Clicked = false;
     Pressed = false;
  }
}
// create a button
  void render() { // put in draw() to render to screen
   fill(Color);
   rect(Pos.x, Pos.y, Width, Height);
   
   fill(0);
   textAlign(CENTER, CENTER);
   text(Text, Pos.x+(Width/2), Pos.y+(Height/2));
  }
  boolean isClicked() { // use in if statement to check if button has been clicked
   return Clicked; 
  }
}
