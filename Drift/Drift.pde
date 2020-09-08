import java.util.Random;

Random ran;

Car[] cars;
private static final int populationSize = 500;
Evolution evo;
Track track;


void setup () {
  ran = new Random();
  size(1000, 800);
  
  cars = new Car[populationSize];
  evo = new Evolution(populationSize);
  
  for (int i = 0; i < populationSize; i++) {
    
    float[] initialWeights1 = new float[78];
    for (int w = 0; w < 78; w++) {
      initialWeights1[w] = ran.nextFloat()*2 - 1;
    }
    
    float[] initialWeights2 = new float[14];
    for (int w = 0; w < 14; w++) {
      initialWeights2[w] = ran.nextFloat()*2 - 1;
    }
  
    cars[i] = new Car(initialWeights1, initialWeights2);
  }
  
  track = new Track();
}


void draw () {
  background(0, 100, 50);
  translate(width/2-100, height/2-30);
  
  track.render();
  
  int deadCount = 0;
  for (Car car : cars) {
    if (car.isAlive) {
      car.think();
      car.checkCollision(track.getCoords());
      car.render();
    }
    else deadCount++;
  }
  
  if (deadCount == populationSize) {
    System.out.print("Evolving...  ");
    cars = evo.nextGen(cars);
  }
  
  evo.drawBest();
  //System.out.println((mouseX - width/2) + " " + (mouseY - height/2));
  
}
