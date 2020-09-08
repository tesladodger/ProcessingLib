import org.jbox2d.dynamics.joints.*;


class Bridge {

  ArrayList<Particle> particles;

  Bridge () {
    particles = new ArrayList();

    particles.add(new Particle(0, 250, 5, BodyType.STATIC));
    for (int i = 1; i < 90; i++) {
      particles.add(new Particle(i*10, 250, 5, BodyType.DYNAMIC));
    }
    particles.add(new Particle(900, 250, 5, BodyType.STATIC));
    
    for (int i = 0; i < particles.size()-1; i++) {
      DistanceJointDef djd = new DistanceJointDef();
      djd.bodyA = particles.get(i).body;
      djd.bodyB = particles.get(i+1).body;
      djd.length = box2d.scalarPixelsToWorld(10);
      djd.frequencyHz = 0;
      djd.dampingRatio = 4;
      box2d.world.createJoint(djd);
    }
  }

  void render () {
    for (Particle p : particles) {
      p.render();
    }
  }
}
