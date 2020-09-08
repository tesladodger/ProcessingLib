import org.jbox2d.collision.shapes.PolygonShape;


class Box {
  float w, h;
  float x, y;

  Body body;

  Box (float x, float y) {
    this.x = x;
    this.y = y;
    w = random(4, 16);
    h = random(4, 16);

    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));

    body = box2d.createBody(bd);

    PolygonShape ps = new PolygonShape();
    float b2dw = box2d.scalarPixelsToWorld(w/2);
    float b2dh = box2d.scalarPixelsToWorld(h/2);
    ps.setAsBox(b2dw, b2dh);

    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.density = .4;
    fd.friction = .3;
    fd.restitution = .5;

    body.createFixture(fd);
  }


  void render () {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(50, 50, 150);
    stroke(0);
    strokeWeight(2);
    rectMode(CENTER);
    rect(0, 0, w, h);
    popMatrix();
  }
}
