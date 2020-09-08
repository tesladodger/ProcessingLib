class Lamp {

  PVector pos;
  List<PVector> rays;

  Lamp () {
    pos = new PVector(width/2, height/2);
    rays = new ArrayList<PVector>();

    for (float i = 0; i < 2*PI; i+=.01) {
      rays.add(PVector.fromAngle(i));
    }
    for (PVector ray : rays) {
      ray.setMag(16);
    }
  }

  void render () {
    fill(255);
    noStroke();
    ellipse(pos.x, pos.y, 10, 10);
  }

  void cast (List<Wall> walls) {
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
            minDist = PVector.dist(pos, new PVector(tempX, tempY));
            line = new PVector(tempX, tempY);
          }
        }
      }
      if (line != null) {
        stroke(255, 100);
        strokeWeight(.8);
        line(pos.x, pos.y, line.x, line.y);
      }
    }
  }
}
