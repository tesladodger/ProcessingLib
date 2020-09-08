import controlP5.*;
import processing.sound.*;

ControlP5 cp5;

ArrayList<Ball> balls = new ArrayList();
Cannon cannon;
SoundFile boom;

// Values for the ball.
float angle;
float speed;
float g;
float e;
float d;
float m;
float ar;
float M;


void setup () {
  size(1300, 600);
  cp5 = new ControlP5(this);
  cp5.addSlider("Speed")
    .setPosition(10, 10).setSize(100, 20).setRange(0, 30).setValue(15)
    .setColorCaptionLabel(color(0));
  cp5.addSlider("Gravity")
    .setPosition(10, 40).setSize(100, 20).setRange(1, 30).setValue(9.81)
    .setColorCaptionLabel(color(0));
  cp5.addSlider("Restitution Coefficient")
    .setPosition(10, 70).setSize(100, 20).setRange(0, 1).setValue(0.5)
    .setColorCaptionLabel(color(0));
  cp5.addSlider("Drag")
    .setPosition(10, 100).setSize(100, 20).setRange(0, 1).setValue(0.15)
    .setColorCaptionLabel(color(0));
  cp5.addSlider("Friction")
    .setPosition(10, 130).setSize(100, 20).setRange(0, 1).setValue(0.2)
    .setColorCaptionLabel(color(0));
  
  cannon = new Cannon();
  boom = new SoundFile(this, "186925__readeonly__cannon-boom1.wav");
}

void draw () {
  background(230, 240, 250);
  
  // Get current slider values.
  speed = cp5.getController("Speed").getValue();
  g = cp5.getController("Gravity").getValue() * 0.01;
  e = cp5.getController("Restitution Coefficient").getValue();
  ar = cp5.getController("Drag").getValue() * 0.01;
  M = 1 - cp5.getController("Friction").getValue();
  
  // Render the floor.
  fill(0, 153, 0);
  stroke(0, 255, 128);
  strokeWeight(3);
  rect(-5, height-40, width+10, 45);
  
  // Get the current angle.
  if (mouseX > 20 && mouseY < height - 40) {
    float m = (mouseY - height + (float) 40) / (mouseX - (float) 20);
    angle = -atan(m);
  }
  
  // Render the cannon.
  cannon.render(angle);
  
  // Move and render the balls.
  for (int i = 0; i < balls.size(); i++) {
    balls.get(i).move();
    balls.get(i).render();
    // Since fixing a collision may introduce another earlier in the array,
    // I still need to check every ball with every other ball twice.
    for (int j = 0; j < balls.size(); j++) {
      if (j != i) {
        balls.get(i).checkCollision(balls.get(j));
      }
    }
  }
  
}


void mouseClicked () {
  //boom.play();
  balls.add(new Ball(angle, speed));
}
