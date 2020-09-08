

class Particle {

  float x, y;

  Particle (float x, float y) {
    this.x = x;
    this.y = y;
  }

  void render () {
    pushMatrix();
    translate(x, y);
    fill(130);
    stroke(0);
    strokeWeight(2);
    circle(0, 0, 10);
    popMatrix();
  }
}
