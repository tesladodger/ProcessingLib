import java.util.Random;

class Evolution {
  
  /* Number of elements in a generation. */
  private final int populationSize;
  
  /* Contains the fitness of the element in the population with the same index. */
  private float[] fitness;
  
  /* Random generator used for selection and mutation */
  private Random ran;
  
  /* Counter for number of generations. */
  private int counter;
  
  /* Records */
  Car bestCar;
  float record;
  
  
  /**
   * Constructor.
   *
   * @param populationSize number of cars in a generation;
   */
  Evolution (int populationSize) {
    this.populationSize = populationSize;
    fitness = new float[populationSize];
    ran = new Random();
    counter = 0;
    record = 0;
  }
  
  
  /**
   * Create the next generation.
   *
   * @param gen current generation;
   *
   * @return next generation;
   */
  Car[] nextGen (Car[] gen) {
    calculateFitness(gen);
    normalizeFitness();
    Car[] nextGen = new Car[populationSize];
    
    for (int i = 0; i < populationSize; i++) {
      nextGen[i] = mutate(crossover(gen[pickElem()], gen[pickElem()]));
    }
    
    System.out.print("   Generation: " + 
      ++counter + "  Record: " + record + "\n");
    return nextGen;
  }
  
  
  /**
   * Calculates the fitness value of a car.
   * The fitness is the distance covered plus the distance over time.
   *
   * @param gen generation being evaluated;
   */
  private void calculateFitness (Car[] gen) {
    for (int i = 0; i < populationSize; i++) {
      if (gen[i].distance > record) {
        record = gen[i].distance;
        bestCar = gen[i];
      }
      fitness[i] = gen[i].distance;
    }
    saveBest();
    drawBest();
  }
  
  
  /**
   * Normalizes the fitness values to a percentage (0-1);
   */
  private void normalizeFitness () {
    float sum = 0;
    for (int i = 0; i < populationSize; i++) {
      sum += fitness[i];
    }
    for (int i = 0; i < populationSize; i++) {
      fitness[i] /= sum;
    }
  }
  
  
  /**
   * Picks an element given the probability distribution.
   *
   * @return index of the picked element;
   */
   private int pickElem () {
     int i = 0;
     double r = ran.nextDouble();
     while (r > 0) {
       r -= fitness[i];
       i++;
      }
      return --i;
    }
    
    
    /**
     * Randomly change the value of some weights.
     *
     * @param car to mutate;
     *
     * @return mutated car;
     */
    private Car mutate (Car car) {
      // Normal mutation, 90% of the population with mutation rate.
      if (ran.nextFloat() < .9) {
        for (int i = 0; i < 78; i++) {
          if (ran.nextFloat() <= .1) {
            car.weights1[i] = ran.nextFloat()*2 - 1;
          }
          else {
            car.weights1[i] += ran.nextGaussian() /50f;
          }
        }
        for (int i = 0; i < 14; i++) {
          if (ran.nextFloat() <= .1) {
            car.weights2[i] = ran.nextFloat()*2 - 1;
          }
          else {
            car.weights1[i] += ran.nextGaussian() /50f;
          }
        }
      }
      
      return car;
    }
    
    
    /**
     * Performs crossover between two cars.
     *
     * @param a first car;
     * @param b second car;
     *
     * @return new child car;
     */
    private Car crossover (Car a, Car b) {
      float[] w1 = new float[78];
      float[] w2 = new float[14];
      
      int r1 = ran.nextInt(2);
      if (r1 == 0) for (int i = 0; i < 13; i++)  w1[i] = a.weights1[i];
      else         for (int i = 0; i < 13; i++)  w1[i] = b.weights1[i];
      
      int r2 = ran.nextInt(2);
      if (r2 == 0) for (int i = 13; i < 26; i++)  w1[i] = a.weights1[i];
      else         for (int i = 13; i < 26; i++)  w1[i] = b.weights1[i];
      
      int r3 = ran.nextInt(2);
      if (r3 == 0) for (int i = 26; i < 39; i++)  w1[i] = a.weights1[i];
      else         for (int i = 26; i < 39; i++)  w1[i] = b.weights1[i];
      
      int r4 = ran.nextInt(2);
      if (r4 == 0) for (int i = 39; i < 52; i++)  w1[i] = a.weights1[i];
      else         for (int i = 39; i < 52; i++)  w1[i] = b.weights1[i];
      
      int r5 = ran.nextInt(2);
      if (r5 == 0) for (int i = 52; i < 65; i++)  w1[i] = a.weights1[i];
      else         for (int i = 52; i < 65; i++)  w1[i] = b.weights1[i];
      
      int r6 = ran.nextInt(2);
      if (r6 == 0) for (int i = 65; i < 78; i++)  w1[i] = a.weights1[i];
      else         for (int i = 65; i < 78; i++)  w1[i] = b.weights1[i];
      
      int r7 = ran.nextInt(2);
      if (r7 == 0) for (int i = 0; i < 6; i++)  w2[i] = a.weights2[i];
      else         for (int i = 0; i < 6; i++)  w1[i] = b.weights2[i];
      
      int r8 = ran.nextInt(2);
      if (r8 == 0) for (int i = 6; i < 12; i++)  w2[i] = a.weights2[i];
      else         for (int i = 6; i < 12; i++)  w1[i] = b.weights2[i];
      
      int r9 = ran.nextInt(2);
      if (r9 == 0)  w2[12] = a.weights2[12];
      else          w2[12] = b.weights2[12];
      
      int r10 = ran.nextInt(2);
      if (r10 == 0)  w2[13] = a.weights2[13];
      else           w2[13] = b.weights2[13];
      return new Car(w1, w2);
      
    }
    
    
    /**
     * Draws the neural network of the current best car.
     */
    void drawBest () {
      if (counter == 0) return;
      int ox = 280, oy = 60;
      
      fill(255);
      textSize(14);
      textAlign(RIGHT);
      text("vel",  ox, oy);
      text("ang",  ox, oy + 30);
      text("F",    ox, oy + 60);
      text("B",    ox, oy + 90);
      text("R",    ox, oy + 120);
      text("L",    ox, oy + 150);
      text("FFR",  ox, oy + 180);
      text("FFL",  ox, oy + 210);
      text("FRR",  ox, oy + 240);
      text("FLL",  ox, oy + 270);
      text("BR",   ox, oy + 300);
      text("BL",   ox, oy + 330);
      text("Bias", ox, oy + 360);
      
      for (int i = 0; i < 13; i++) {
        noStroke();
        fill(0);
        ellipse(ox+10, oy + i*30 - 6, 6, 6);
      }
      
      for (int i = 0; i < 6; i++) {
        ellipse(ox + 210, oy - 40 + i * 82, 6, 6);
      }
      
      ellipse(ox + 300, oy + 120, 6, 6);
      ellipse(ox + 300, oy + 220, 6, 6);
      
      for (int i = 0; i < 13; i++) {
        for (int j = 0; j < 6; j++) {
          if (bestCar.weights1[j*13+i] > 0) stroke(255, 0, 0);
          else if (bestCar.weights1[j*13+i] == 0) continue;
          else stroke(0, 0, 255);
          
          strokeWeight(map( abs(bestCar.weights1[j*13+i]), 0, 1, 0, 3));
          line(ox+10, oy + i*30-6, ox+210, oy - 40 + j * 82);
        }
      }
      for (int i = 0; i < 6; i++) {
        if (bestCar.weights2[i] < 0) stroke(255, 0, 0);
        else if (bestCar.weights2[i] == 0) stroke(0, 100, 50);
        else stroke(0, 0, 255);
        
        strokeWeight(map( abs(bestCar.weights2[i]), 0, 1, 0, 3));
        line(ox+210, oy-40+i*82, ox+300, oy+120);
        
        if (bestCar.weights2[i+6] < 0) stroke(255, 0, 0);
        else if (bestCar.weights2[i+6] == 0) stroke(0, 100, 50);
        else stroke(0, 0, 255);
        
        strokeWeight(map( abs(bestCar.weights2[i+6]), 0, 1, 0, 3));
        line(ox+210, oy-40+i*82, ox+300, oy+220);
      }

    }
    
    
    /**
     * Writes the weights of the best car to a file.
     */
    private void saveBest () {
      
        PrintWriter writer = createWriter("bestCar");
      
        writer.println("First Layer");
        for (float w : bestCar.weights1) {
          writer.println(w);
        }
        
        writer.println("\nSecond Layer");
        for (float w : bestCar.weights2) {
          writer.println(w);
        }
        writer.flush();
        writer.close();
      
    }
  
}
