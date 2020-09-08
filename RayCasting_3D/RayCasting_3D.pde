import java.util.List;

/*
 * Add walls with the mouse. To cancel a point, press backspace.
 * To remove the walls press delete.
 * Move with the arrow keys.
 */

Lamp lamp;
List<Wall> walls;
List<PVector> points;

boolean isLeft, isRight, isUp, isDown; 

void setup () {
  size(1600, 600);

  lamp = new Lamp();

  walls = new ArrayList<Wall>();
  points = new ArrayList<PVector>();

  walls.add(new Wall(-10, -10, width/2, -10));
  walls.add(new Wall(width/2, -10, width/2, height+10));
  walls.add(new Wall(width/2, height+10, -10, height+10));
  walls.add(new Wall(-10, height+10, -10, -10));
}


void draw () {
  background(0);

  for (Wall w : walls) {
    w.render();
  }
  lamp.render();
  lamp.cast(walls);
  lamp.renderScene();
  
  if (isLeft) lamp.rotate(-0.05);
  if (isRight) lamp.rotate(0.05);
  if (isDown) lamp.move(-5);
  if (isUp) lamp.move(5);

  if (points.size() == 1) {
    fill(255, 0, 0);
    stroke(255);
    strokeWeight(1);
    ellipse(points.get(0).x, points.get(0).y, 5, 5);
  } else if (points.size() == 2) {
    PVector a = points.get(0);
    PVector b = points.get(1);
    walls.add(new Wall(a.x, a.y, b.x, b.y));
    points.clear();
  }
}


void mouseClicked () {
  if (mouseX < width/2) {
    points.add(new PVector(mouseX, mouseY));
  }
}

void keyPressed () {
  if (keyCode == BACKSPACE) {
    points.clear();
  } 
  else if (keyCode == DELETE) {
    walls.clear();
    walls.add(new Wall(0, 0, width, 0));
    walls.add(new Wall(width, 0, width, height));
    walls.add(new Wall(width, height, 0, height));
    walls.add(new Wall(0, height, 0, 0));
  } 
  else {
    setMove(keyCode, true);
  }
}


void keyReleased() {
  setMove(keyCode, false);
}


boolean setMove(int k, boolean b) {
  switch (k) {
  case UP:
    return isUp = b;

  case DOWN:
    return isDown = b;

  case LEFT:
    return isLeft = b;

  case RIGHT:
    return isRight = b;

  default:
    return b;
  }
}
