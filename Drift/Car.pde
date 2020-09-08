class Car {
  
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


  /* Neural Network related values */
  
  /* Inputs:
   *   - Velocity;
   *   - Angle;
   *   - All 10 sensor values;
   *   - Bias = 1;
   * Layer 1:
   *   - 6 hidden nodes;
   * Outputs:
   *   - Forwards or backwards;
   *   - Turn left, right or go straight;
   */
  
  // Contain the relative distance of every sensor to the track limit.
  private float[] sensors = new float[10];;
  // Array with the coordinates of the tips of the 'sensor' lines.
  private float[][] sensorCoords = new float[10][2];
  // Connections between the 15 inputs and 4 first layer neurons.
  float[] weights1;
  // Connections between the 4 first layer neurons and 2 outputs (plus 2 bias weights).
  float[] weights2;
  
  
  /* Evolution related values */
  
  // Boolean set to false when the car hits the track limit.
  boolean isAlive;
  // Total distance covered before it died.
  float distance;
  // Distance to kill it if not moving.
  float dist;
  // Time alive.
  long time;
  // Time to kill it if not moving.
  long t;


  // Constructor.
  Car (float[] weights1, float[] weights2) {
    img = loadImage("car.png");
    pos = new PVector(-365, -45);
    vel = 0;
    acc = 0;
    ang = 0;
    desAng = 0;
    
    this.weights1 = weights1;
    this.weights2 = weights2;
    
    isAlive = true;
    distance = 0;
    dist = -20;
    time = t = System.currentTimeMillis();
  }


  /**
   * Moves the car backwards and forwards and changes the current angle.
   *
   * @param force applied to move the car;
   */
  private void move (float force) {
    // Kill it if not moving.
    if (System.currentTimeMillis() - t > 2000) {
      if (distance - dist < 20) {
        isAlive = false;
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
    }
    else {
      distance -= Math.sqrt( (vel*cos(ang)*vel*cos(ang)) + (vel*sin(ang)*vel*sin(ang)) );
    }

    // Move.
    pos.y += vel*cos(ang);
    pos.x += vel*sin(ang);
  }


  /**
   * Turns the car.
   *
   * @param steer angle;
   */
  private void turn (float steer) {
    // Turning radius is proportional to speed.
    desAng -= steer * (vel*.3);
  }


  /**
   * Calculates the coordenates of the corners of the car.
   *
   * @return 4*2 array with coordinates;
   */
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


  /**
   * Implements line/line collision to check if the car hits the limits
   * of the track.
   * If not, calculates the distance of every sensor to the track limits.
   * http://www.jeffreythompson.org/collision-detection/line-line.php
   *
   * @param car coordinates of the corners of the car track[0] is the inner
   *            curve and [1] is the outer;
   */
  private void checkCollision (int[][][] track) {
    float[][] car = getCoords();
    float uA, uB;
    float x1, x2, x3, x4, y1, y2, y3, y4;
    
    /* Collision with the track limits. */
    // Loop the points on the track.
    for (int[][] t : track) {
      for (int i = 0; i < 40; i++) {
        x3 = t[i  ][0];  y3 = t[i  ][1];
        x4 = t[i+1][0];  y4 = t[i+1][1];
        // Loop the points of the car.
        for (int j = 0; j < 3; j++) {
          x1 = car[j  ][0];  y1 = car[j  ][1];
          x2 = car[j+1][0];  y2 = car[j+1][1];

          uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / 
               ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
          uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / 
               ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

          if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
            // Collision detected, murder the car.
            isAlive = false;
            time = System.currentTimeMillis() - time;
            return;
          }
        }
      }
    }
    
    /* Update sensor information */
    resetSensors();
    // Check intersections between the sensors and the track limits.
    x1 = pos.x; y1 = pos.y;
    for (int j = 0; j < 10; j++) {
      x2 = sensorCoords[j][0]; y2 = sensorCoords[j][1];
      // Loop the track points.
      for (int[][] t : track) {
        for (int i = 0; i < 40; i++) {
          x3 = t[i  ][0];  y3 = t[i  ][1];
          x4 = t[i+1][0];  y4 = t[i+1][1];
          
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
    }
  }
  
  
  /**
   * Method for the neural network.
   * Calculates the values of the outputs and calls the move() and turn()
   * methods with the appropriate parameters.
   */
  private void think () {
    float[] middleLayer = {
      calculateNeuronValue(0),
      calculateNeuronValue(13),
      calculateNeuronValue(26),
      calculateNeuronValue(39),
      calculateNeuronValue(52),
      calculateNeuronValue(65)
    };
    
    // Calculate the Gas/Break output.
    float gas_break = 0;
    for (int i = 0; i < 6; i++) {
      gas_break += middleLayer[i] * weights2[i];
    }
    gas_break += weights2[12]; // Bias weight.
    // Move accordingly.
    if (gas_break <= 0) move(.3);
    else move(-.3);
    
    // Calculate the Left/Right output.
    float left_right = 0;
    for (int i = 0; i < 6; i++) {
      left_right += middleLayer[i] * weights2[i+6];
    }
    left_right += weights2[13]; // Bias.
    // Turn accordingly.
    if (left_right < -.3) turn(.05);
    else if (left_right > .3) turn(-.05);
  }
  
  
  /**
   * Calculates the weighted sum for the a given layer 1 neuron and
   * calls the activation function.
   *
   * @param startI index of the first weight of that neuron;
   *
   * @return the activation value of that neuron;
   */
  private float calculateNeuronValue (int startI) {
    float sum = 0;
    sum += vel * weights1[startI++];
    sum += ang * weights1[startI++];
    for (int i = 0; i < 10; i++) {
      sum += sensors[i] * weights1[startI++];
    }
    sum += weights1[startI]; // Bias
    return activate(sum);
  }
  
  
  /**
   * Activation function.
   *
   * @param val value of the neuron;
   *
   * @return -1 if inactive and 1 if active;
   */
  private int activate (float val) {
    if (val <= 0) return -1;
    else return 1;
  }
  
  
  /**
   * Updates the coordenates of the sensors and resets the sensor values.
   */
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
    
    for (int i = 0; i < 10; i++) sensors[i] = 1.1;
  }


  /**
   * Renders the car.
   * Note the car is always at the origin, it's the camera that translates
   * and rotates.
   */
  void render () {
    pushMatrix();
      translate(pos.x, pos.y);
      rotate(-desAng);
      image(img, -w/2, -h/2, w, h);
    popMatrix();
  }
}
