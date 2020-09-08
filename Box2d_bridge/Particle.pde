import org.jbox2d.collision.shapes.CircleShape;

class Particle {

  float x, y, r;
  
  Body body;

  Particle (float x, float y, float r, BodyType type) {
    this.x = x;
    this.y = y;
    this.r = r;
    
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.setPosition(box2d.coordPixelsToWorld(x, y));
    
    body = box2d.createBody(bd);
    
    CircleShape cs = new CircleShape();
    float b2dr = box2d.scalarPixelsToWorld(r);
    cs.setRadius(b2dr);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1;
    fd.friction = .3;
    fd.restitution = .5;
    
    body.createFixture(fd);
  }

  void render () {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
    translate(pos.x, pos.y);
    fill(150, 50, 50);
    stroke(0);
    strokeWeight(2);
    circle(0, 0, r*2);
    popMatrix();
  }
}
