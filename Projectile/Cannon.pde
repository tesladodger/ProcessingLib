class Cannon {
  private static final float posX = 20;
  private final float posY = height - 40;
  private final static float l = 50;  // Lenght
  private final static float t = 16;  // Thickness
  
  /**
   * Renders the cannon in the proper angle using the quadrilateral function.
   * @param a angle of the cannon with the horizon (in radians, ;
   */
  public void render (float a) {
    fill(0);
    noStroke();
    
    // Fixed bottom-left corner.
    float x3 = posX;
    float y3 = posY;
    
    // Bottom-right corner.
    float x2 = posX + (l*cos(a));
    float y2 = posY - (l*sin(a));
    
    // Upper-left corner.
    float x4 = posX - (t*cos( (PI/2) - a ));
    float y4 = posY - (t*sin( (PI/2) - a ));
    
    // Upper-right corner.
    float x1 = x4 + (l*cos(a));
    float y1 = y4 - (l*sin(a));
    
    quad(x1, y1,  x2, y2,  x3, y3,  x4, y4);
    
    fill(200, 100, 0);
    arc(x3, y3, 32, 32, PI, 2*PI, PIE);
  }
}
