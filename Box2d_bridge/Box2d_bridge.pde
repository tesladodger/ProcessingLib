import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import shiffman.box2d.*;

Box2DProcessing box2d;

Bridge bridge;
ArrayList<Box> boxes;

long prevTime;

void setup () {
  size(900, 600);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  bridge = new Bridge();
  boxes = new ArrayList();
  prevTime = System.currentTimeMillis();
}


void draw () {
  background(190);

  if (mousePressed) {
    boxes.add(new Box(mouseX, mouseY));
  }

  long currentTime = System.currentTimeMillis();
  float delta = (float) (currentTime - prevTime) * .001;
  prevTime = currentTime;
  box2d.step(delta, 8, 3);

  for (Box b : boxes) {
    b.render();
  }

  bridge.render();
}
