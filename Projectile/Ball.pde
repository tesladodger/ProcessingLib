class Ball {
  private PVector pos;
  private PVector vel;
  
  private static final float r = 8;  // Radius
  
  /**
   * Constructor.
   * @param a initial angle;
   * @param s initial speed (magnitude);
   * @param g gravitational acceleration;
   * @param e restitution coef.;
   * @param ar air resistance;
   * @param M deccelaration while rolling;
   */
  Ball (float a, float s) {
    a *= -1;
    // Note the initial position is dependent on the cannon's origin and size,
    // not just the current angle.
    pos = new PVector(20 + 50*cos(a) - r,
             (height-40) + 50*sin(a) - r);
    vel = new PVector(s*cos(a), s*sin(a));
    
  }
  
  /**
   * Updates the x and y velocity, according to gravity and drag.
   */
  void move () {
    // Apply gravity.
    vel.y += g;
    // Apply air resistance.
    float mag = vel.mag();
    vel.setMag(mag - (ar * mag * mag));
    // Call collision checking.
    checkFloorCollision();
    // Update the position.
    pos.add(vel);
  }
  
  /**
   * When the ball collides with the floor, the y velocity is inverted and
   * decreased, according to the restitution, and the x velocity is decreased
   * according to the friction with the floor.
   */
  void checkFloorCollision () {
    if (pos.y > height - 40 - r) {
      // Reset position.
      pos.y = height - 40 - r;
      // Bounce.
      vel.y = - (vel.y * e);
      // Apply friction.
      vel.x *= M;
    }
  }
  
  /**
   * Applies the formula for partially inelastic collision of circles.
   */
  void checkCollision (Ball other) {
    if (this.pos.dist(other.pos) < r*2) {
      // Decrease the speeds to avoid jittering.
      this.vel.mult(0.95);
      other.vel.mult(0.95);
      
      // Apply elastic collision to this.
      PVector v1mv2 = new PVector(vel.x - other.vel.x, vel.y - other.vel.y);
      PVector x1mx2 = new PVector(pos.x - other.pos.x, pos.y - other.pos.y);
      float magx1x2 = x1mx2.mag() * x1mx2.mag();
      float q = (v1mv2.x * x1mx2.x + v1mv2.y * x1mx2.y) / magx1x2;
      x1mx2.mult(q);
      vel.sub(x1mx2);
      
      // Apply elastic collision to other.
      PVector v2mv1 = new PVector(other.vel.x - vel.x, other.vel.y - vel.y);
      PVector x2mx1 = new PVector(other.pos.x - pos.x, other.pos.y - pos.y);
      float magx2x1 = x2mx1.mag() * x2mx1.mag();
      q = (v2mv1.x * x2mx1.x + v2mv1.y * x2mx1.y) / magx2x1;
      x2mx1.mult(q);
      vel.sub(x2mx1);
      
      // Prevent them from sticking together.
      if (pos.dist(other.pos) < r*2) {
        // The sign of pos1 - pos2 matters, and since I don't know if q was
        // negative, I need to recalculate it.
        x1mx2 = new PVector(pos.x - other.pos.x, pos.y - other.pos.y);
        
        // Set the magnitude of the difference vector to half the overlap
        // distance.
        x1mx2.setMag( ((2*r) -  pos.dist(other.pos)) / 2 );
        
        // Add the difference vector to this position.
        pos.add(x1mx2);
        // Subtract the vector from the other's position.
        other.pos.sub(x1mx2);
      }
    }
  }
  
  void render () {
    fill(0);
    noStroke();
    ellipse(pos.x, pos.y, r*2, r*2);
  }
  
}
