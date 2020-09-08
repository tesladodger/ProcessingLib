class Lamp {

  PVector pos;
  PVector heading;
  List<PVector> rays;
  float[] scene;


  Lamp () {
    pos = new PVector(width/4, height/2);
    heading = new PVector(1, -1);
    rays = new ArrayList<PVector>();
    
    for (float i = -PI/8; i < PI/8; i+=.004) {
      rays.add(PVector.fromAngle(i+heading.heading()));
    }
    
    scene = new float[rays.size()];
  }
  
  
  void move (int f) {
    PVector force = PVector.fromAngle(heading.heading());
    force.setMag(f);
    pos.add(force);
  }
  
  
  void rotate (float a) {
    heading.rotate(a);
    for (PVector ray : rays) {
      ray.rotate(a);
    }
  }


  void render () {
    fill(255);
    noStroke();
    ellipse(pos.x, pos.y, 10, 10);
  }


  void cast (List<Wall> walls) {
    int index = 0;
    for (PVector ray : rays) {
      float x3 = pos.x;
      float y3 = pos.y;
      float x4 = pos.x + ray.x;
      float y4 = pos.y + ray.y;

      Float minDist = Float.POSITIVE_INFINITY;
      PVector line = null;

      for (Wall wall : walls) {
        float x1 = wall.a.x;
        float y1 = wall.a.y;
        float x2 = wall.b.x;
        float y2 = wall.b.y;

        float den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);

        if (den == 0) continue;

        float t =  ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den;
        float u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den;

        if (t > 0 && t < 1 && u > 0) {
          float tempX = x1 + t*(x2 - x1);
          float tempY = y1 + t*(y2 - y1);

          if (PVector.dist(pos, new PVector(tempX, tempY)) < minDist) {
            line = new PVector(tempX, tempY);
            PVector temp = PVector.sub(line, pos);
            minDist = PVector.dist(pos, line);
            float a = temp.heading() - heading.heading();
            scene[index] = minDist * cos(a);
          }
        }
      }
      if (line != null) {
        stroke(255, 50);
        strokeWeight(.8);
        line(pos.x, pos.y, line.x, line.y);
      }
      index++;
    }
  }
  
  
  void renderScene () {
    fill(50);
    rectMode(CORNER);
    rect(width/2, height/2, width/2, height/2);
    
    float w = (width/2) / (float) scene.length;
    int i = 1;
    for (float f : scene) {
      float brightness = map(f, 0, width/2, 255, 20);
      float size = 56000f / f;
      fill(brightness);
      noStroke();
      pushMatrix();
        translate(width/2, 0);
        rectMode(CENTER);
        rect(i*w, height/2, w, size);
      popMatrix();
      i++;
    }
  }
  
}
