import java.util.List;

/*
 * Add walls with the mouse. To cancel a point, press backspace.
 * To remove the walls press delete.
 */

Lamp lamp;
List<Wall> walls;
List<PVector> points;


void setup () {
  size(900, 600);
  
  lamp = new Lamp();
  
  walls = new ArrayList<Wall>();
  points = new ArrayList<PVector>();
  
  walls.add(new Wall(-10, -10, width+10, -10));
  walls.add(new Wall(width+10, -10, width+10, height+10));
  walls.add(new Wall(width+10, height+10, -10, height+10));
  walls.add(new Wall(-10, height+10, -10, -10));
}


void draw () {
  background(0);
  
  for (Wall w : walls) {
    w.render();
  }
  lamp.render();
  lamp.cast(walls);
  
  
  if (points.size() == 1) {
    fill(255, 0, 0);
    stroke(255);
    strokeWeight(1);
    ellipse(points.get(0).x, points.get(0).y, 5, 5);
  }
  else if (points.size() == 2) {
    PVector a = points.get(0);
    PVector b = points.get(1);
    walls.add(new Wall(a.x, a.y, b.x, b.y));
    points.clear();
  }
  
}


void mouseClicked () {
  points.add(new PVector(mouseX, mouseY));
}

void keyPressed () {
  if (keyCode == BACKSPACE) {
    points.clear();
  }
  if (keyCode == DELETE) {
    walls.clear();
    walls.add(new Wall(0, 0, width, 0));
    walls.add(new Wall(width, 0, width, height));
    walls.add(new Wall(width, height, 0, height));
    walls.add(new Wall(0, height, 0, 0));
  }
}
