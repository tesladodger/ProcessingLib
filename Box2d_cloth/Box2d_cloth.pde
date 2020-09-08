import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import shiffman.box2d.*;

Cloth cloth;

void setup () {
  size(900, 600);
  cloth = new Cloth();
}


void draw () {
  background(200);
  cloth.render();  
}
