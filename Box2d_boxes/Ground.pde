import org.jbox2d.collision.shapes.PolygonShape;


class Ground {
  float w, h;
  float x, y;

  Body body;

  Ground (float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));

    body = box2d.createBody(bd);

    PolygonShape ps = new PolygonShape();
    float b2dw = box2d.scalarPixelsToWorld(w/2);
    float b2dh = box2d.scalarPixelsToWorld(h/2);
    ps.setAsBox(b2dw, b2dh);

    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.density = 1;
    fd.friction = .3;
    fd.restitution = .5;

    body.createFixture(fd);
  }


  void render () {
    pushMatrix();
    translate(x, y);
    fill(0);
    strokeWeight(0);
    rectMode(CENTER);
    rect(0, 0, w, h);
    popMatrix();
  }
}
