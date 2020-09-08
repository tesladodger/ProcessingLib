/**
 * Implements Gradient Descent to calculate a linear regression from a list of points.
 * Note, since the y axis is inverted, the m value of the function is the inverse.
 */

ArrayList<PVector> points = new ArrayList();

// Radius of the points.
int r = 10;

// Function values.
float m = 0;
float b = 0.5;
float rate = 0.1;


void setup () {
  size(600, 600);
}


void draw () {
  background(60);
  
  fill(100, 200, 0);
  stroke(0, 100, 230);
  strokeWeight(2);
  
  // Draw the points and correct the function.
  for (PVector point : points) {
    ellipse(point.x*600, point.y*600, r, r);
    
    float fX = m * point.x + b;
    float error = point.y - fX;
    
    m += error * point.x * rate;
    b += error * rate;
  }
  
  System.out.println(m + "x + " + b);
  
  // Draw the function.
  float x1 = 0;
  float y1 = b * 600;
  float x2 = 600;
  float y2 = (m * 1 + b) * 600;
  line(x1, y1, x2, y2);
}


void mouseClicked () {
  points.add(new PVector(mouseX/600f, mouseY/600f));
}
