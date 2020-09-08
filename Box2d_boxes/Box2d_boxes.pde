import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import shiffman.box2d.*;


Box2DProcessing box2d;

ArrayList<Box> boxes;
ArrayList<Box> boxesToRemove;
Ground g0;
Ground g1;


void setup () {
  size(900, 600);
  boxes = new ArrayList();
  boxesToRemove = new ArrayList();
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  
  g0 = new Ground(160f, 500f, 300f, 10f);
  g1 = new Ground(600f, 400f, 500f, 10f);
}


void draw () {
  background(255);
  
  box2d.step();

  if (mousePressed) {
    boxes.add(new Box(mouseX, mouseY));
  }

  for (Box b : boxes) {
    b.render();
  }
  
  for (Box b : boxesToRemove) {
    boxes.remove(b);
  }
  boxesToRemove.clear();
  
  
  g0.render();
  g1.render();
  
  System.out.println(frameRate);
}
