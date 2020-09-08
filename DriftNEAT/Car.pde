class Car implements Behavior {
  PImage img;

  /* Geometry related values */

  // Width and height of the rectangle.
  private static final int w = 16;
  private static final int h = 30;
  // Arm from the center to the corners
  private static final float d = 17;
  // Angle from the car's centerline its diagonal
  private static final float a = 0.4899573263;


  /* Physics related values */

  private static final float maxVel = 4;  // Maximum velocity
  private static final float fric = 0.95; // Friction (to stop the car)
  // Coefficient for drifting. The lower the coefficient the lower the 
  // friction. 
  // A coef of 1 means the angle is equal to the desired angle, which 
  // means no drifting.
  private static final float coef = 0.2;

  PVector pos;        // Position
  private float vel;  // Velocity
  private float acc;  // Acceleration
  private float ang;  // Angle of movement
  float desAng;       // Desired angle (for drifting)

  // Array with the coordinates of the tips of the 'sensor' lines.
  private float[][] sensorCoords = new float[10][2];


  /* Neuro evolution related values */

  private float fitness;
  private boolean alive;


  private float[] sensors;

  // Total distance covered before it died.
  float distance;
  // Distance to kill it if not moving.
  float dist;
  // Time alive.
  long time;
  // Time to kill it if not moving.
  long t;


  Car () {

    sensors = new float[10];

    alive = true;
    img = loadImage("car.png");
    pos = new PVector(-365, -45);
    vel = 0;
    acc = 0;
    ang = 0;
    desAng = 0;
    distance = 0;
    dist = -20;
    time = t = System.currentTimeMillis();
  }


  public float[][] updateSensors () {
    float[][] car = getCoords();
    float uA, uB;
    float x1, x2, x3, x4, y1, y2, y3, y4;

    /* Collision with the track limits. */
    // Loop the points on the track.
    for (int i = 0; i < 41; i++) {
      x3 = iC[i  ][0];  
      y3 = iC[i  ][1];
      x4 = iC[i+1][0];  
      y4 = iC[i+1][1];
      // Loop the points of the car.
      for (int j = 0; j < 3; j++) {
        x1 = car[j  ][0];  
        y1 = car[j  ][1];
        x2 = car[j+1][0];  
        y2 = car[j+1][1];

        uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / 
          ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
        uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / 
          ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

        if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
          // Collision detected, murder the car.
          alive = false;
          time = System.currentTimeMillis() - time;
        }
      }
    }
    for (int i = 0; i < 41; i++) {
      x3 = oC[i  ][0];  
      y3 = oC[i  ][1];
      x4 = oC[i+1][0];  
      y4 = oC[i+1][1];
      // Loop the points of the car.
      for (int j = 0; j < 3; j++) {
        x1 = car[j  ][0];  
        y1 = car[j  ][1];
        x2 = car[j+1][0];  
        y2 = car[j+1][1];

        uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / 
          ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
        uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / 
          ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

        if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
          // Collision detected, murder the car.
          alive = false;
          time = System.currentTimeMillis() - time;
        }
      }
    }


    /* Update sensor information */
    resetSensors();
    // Check intersections between the sensors and the track limits.
    x1 = pos.x; 
    y1 = pos.y;
    for (int j = 0; j < 10; j++) {
      x2 = sensorCoords[j][0]; 
      y2 = sensorCoords[j][1];
      // Loop the track points.
      for (int i = 0; i < 41; i++) {
        x3 = iC[i  ][0];  
        y3 = iC[i  ][1];
        x4 = iC[i+1][0];  
        y4 = iC[i+1][1];

        uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / 
          ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
        uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / 
          ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

        // If there is a collision and the value is smaller, update it.
        if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1  && uA < sensors[j]) {
          sensors[j] = uA;
        }
      }
      for (int i = 0; i < 41; i++) {
        x3 = oC[i  ][0];  
        y3 = oC[i  ][1];
        x4 = oC[i+1][0];  
        y4 = oC[i+1][1];

        uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / 
          ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
        uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / 
          ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

        // If there is a collision and the value is smaller, update it.
        if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1  && uA < sensors[j]) {
          sensors[j] = uA;
        }
      }
    }
    
    return new float[][] {sensors};
  }


  public void move (float[][] controls) {
    float force;
    if (controls[0][0] > .5) force = -.3f;
    else force = .3f;

    // Kill it if not moving.
    if (System.currentTimeMillis() - t > 2000) {
      if (distance - dist < 20) {
        alive = false;
        return;
      }
      t = System.currentTimeMillis();
      dist = distance;
    }

    // Update the angle.
    // Drift.
    ang += (desAng - ang) * coef;
    // Reset the angle when the car stops.
    if (Math.abs(vel) < 1 && force != 0) {
      ang += desAng - ang;
    }

    // Update the velocity.
    if (vel < maxVel && vel > -maxVel) {
      acc = force;
      vel += acc;
    }
    vel *= fric;

    // Update the distance covered.
    if (vel < 0) {
      distance += Math.sqrt( (vel*cos(ang)*vel*cos(ang)) + (vel*sin(ang)*vel*sin(ang)) );
    } else {
      distance -= Math.sqrt( (vel*cos(ang)*vel*cos(ang)) + (vel*sin(ang)*vel*sin(ang)) );
    }

    // Move.
    pos.y += vel*cos(ang);
    pos.x += vel*sin(ang);

    if (controls[0][1] > .5) turn(.05);
    if (controls[0][2] > .5) turn(-.05);
  }


  private void turn (float steer) {
    desAng -= steer * (vel*.3);
  }


  void render () {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-desAng);
    image(img, -w/2, -h/2, w, h);
    //rect(-w/2, -h/2, w, h);
    popMatrix();
  }



  private float[][] getCoords () {
    float oX = pos.x;
    float oY = pos.y;

    float x1 = oX - d * sin(a+desAng);
    float y1 = oY - d * cos(a+desAng);

    float x2 = oX + d * sin(a-desAng);
    float y2 = oY - d * cos(a-desAng);

    float x3 = oX - d * sin(a-desAng);
    float y3 = oY + d * cos(a-desAng);

    float x4 = oX - d * sin(-a-desAng);
    float y4 = oY + d * cos(-a-desAng);

    return new float[][] { {x1, y1}, {x2, y2}, {x3, y3}, {x4, y4} };
  }


  private void resetSensors () {
    sensorCoords[0][0] = pos.x + 240 * sin(-desAng     );  // Front
    sensorCoords[0][1] = pos.y - 240 * cos( desAng     );
    sensorCoords[1][0] = pos.x + 150 * sin( desAng     );  // Back
    sensorCoords[1][1] = pos.y + 150 * cos( desAng     );

    sensorCoords[2][0] = pos.x +  80 * cos( desAng     );  // Right
    sensorCoords[2][1] = pos.y -  80 * sin( desAng     );
    sensorCoords[3][0] = pos.x -  80 * cos( desAng     );  // Left
    sensorCoords[3][1] = pos.y -  80 * sin(-desAng     );

    sensorCoords[4][0] = pos.x + 220 * sin(-desAng+0.25);  // FFront-Right
    sensorCoords[4][1] = pos.y - 220 * cos( desAng-0.25);
    sensorCoords[5][0] = pos.x + 220 * sin(-desAng-0.25);  // FFront-Left
    sensorCoords[5][1] = pos.y - 220 * cos( desAng+0.25);

    sensorCoords[6][0] = pos.x + 180 * sin(-desAng+0.6 );  // Front-RRight
    sensorCoords[6][1] = pos.y - 180 * cos( desAng-0.6 );
    sensorCoords[7][0] = pos.x + 180 * sin(-desAng-0.6 );  // Front-LLeft
    sensorCoords[7][1] = pos.y - 180 * cos( desAng+0.6 );

    sensorCoords[8][0] = pos.x + 120 * sin( desAng+0.6 );  // Back-Right
    sensorCoords[8][1] = pos.y + 120 * cos( desAng+0.6 );
    sensorCoords[9][0] = pos.x + 120 * sin( desAng-0.6 );  // Back-Left
    sensorCoords[9][1] = pos.y + 120 * cos( desAng-0.6 );

    for (int i = 0; i < 10; i++) sensors[i] = 1f;
  }


  public float fitnessFunction () {
    return distance;
  }
  
  public Car copy () {
    return new Car();
  }
  
  public Car copyForReplay () {
    return new Car();
  }

  void calculateFitness () {
    fitness = fitnessFunction();
  }
  
  public boolean solutionFound () {
    return false;
  }

  float getFitness () {
    return fitness;
  }

  void setFitness (float fitness) {
    this.fitness = fitness;
  }

  boolean isAlive () {
    return alive;
  }


}
