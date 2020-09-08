

class Cloth {

  Particle[][] particles;

  int qX = 20;
  int qY = 24;
  
  int oX = width / 4;
  int wX = width / (2 * qX);

  Cloth () {
    particles = new Particle[qX][qY];
    for (int i = 0; i < qX; i++) {
      for (int j = 0; j < qY; j++) {
        particles[i][j] = new Particle(oX + i*wX, 10+j*wX);
      }
    }
  }

  void render () {
    for (Particle[] pa : particles) {
      for (Particle p : pa) {
        p.render();
      }
    }
    stroke(50, 150, 50);
    strokeWeight(2);
    for (int i = 1; i < qX; i++) {
      Particle p1 = particles[i][0];
      Particle p2 = particles[i-1][0];
      line(p1.x, p1.y, p2.x, p2.y);
    }
    for (int j = 1; j < qY; j++) {
      Particle p1 = particles[0][j];
      Particle p2 = particles[0][j-1];
      line(p1.x, p1.y, p2.x, p2.y);
    }
    for (int i = 1; i < qX; i++) {
      for (int j = 1; j < qY; j++) {
        Particle p1 = particles[i][j];
        Particle p2 = particles[i][j-1];
        Particle p3 = particles[i-1][j];
        line(p1.x, p1.y, p2.x, p2.y);
        line(p1.x, p1.y, p3.x, p3.y);
      }
    }
  }
}
