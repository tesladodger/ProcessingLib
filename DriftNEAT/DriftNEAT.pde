import java.util.Random; //<>//
import java.util.List;
import java.util.Map;


Random r;
Track track;
Innovation innov;
Car car;
Population population;

void setup () {
  size(1000, 800);

  r = new Random();
  track = new Track();
  innov = new Innovation();
  car = new Car();
  population = new Population(10, 3, 3000, r, innov, car, 6);
}


void draw () {
  background(0, 50, 50);
  translate(width/2-100, height/2-30);
  //System.out.println((mouseX - width/2 +100) + " " + (mouseY - height/2 + 30));

  track.render();

  if (!population.areAllDead()) {
    fill(100, 0, 0);
    population.multithreadedUpdate();
  } else {
    population.naturalSelection(r, innov);
    System.out.printf("Generation: %5d   Species: %3d   Fitness: %2f \n",
                    population.getGeneration(), population.getNumberSpecies(), population.getBestScore());
  }
}


// Points for the inside of the track.
final int[][] iC = {
  {-100, 80 }, 
  {-50, 90 }, 
  {-15, 90 }, 
  { 20, 50 }, 
  { 30, 0  }, 
  { 40, -70 }, 
  { 70, -110}, 
  { 150, -115}, 
  { 250, -100}, 
  { 320, -40 }, 
  { 320, 40 }, 
  { 300, 100}, 
  { 250, 200}, 
  { 200, 255}, 
  { 150, 260}, 
  { 0, 240}, 
  {-150, 250}, 
  {-220, 260}, 
  {-320, 280}, 
  {-345, 283}, 
  {-340, 260}, 
  {-310, 180}, 
  {-300, 100}, 
  {-340, -60 }, 
  {-300, -220}, 
  {-150, -290}, 
  { 0, -300}, 
  { 150, -310}, 
  { 340, -320}, 
  { 400, -300}, 
  { 400, -260}, 
  { 350, -240}, 
  { 150, -260}, 
  { 0, -250}, 
  {-175, -175}, 
  {-250, -90 }, 
  {-250, -20 }, 
  {-220, 30 }, 
  {-160, 60 }, 
  {-100, 80 }, 
  {-50, 90 }, 
  {-15, 90 }
};

// Points for the outside of the track.

final int[][] oC = {
  {-40, 15 }, 
  {-15, -100}, 
  { 20, -150}, 
  { 100, -170}, 
  { 300, -150}, 
  { 380, -90 }, 
  { 390, 30 }, 
  { 340, 170}, 
  { 275, 265}, 
  { 205, 305}, 
  { 150, 310}, 
  { 50, 290}, 
  { 0, 280}, 
  {-145, 300}, 
  {-290, 350}, 
  {-340, 360}, 
  {-375, 340}, 
  {-400, 240}, 
  {-360, 165}, 
  {-345, 100}, 
  {-380, -25 }, 
  {-380, -170}, 
  {-345, -260}, 
  {-235, -310}, 
  {-120, -340}, 
  {-0, -345}, 
  { 150, -355}, 
  { 330, -365}, 
  { 410, -350}, 
  { 445, -305}, 
  { 440, -230}, 
  { 385, -185}, 
  { 320, -200}, 
  { 250, -210}, 
  { 150, -215}, 
  { 0, -200}, 
  {-150, -130}, 
  {-190, -80 }, 
  {-185, -35 }, 
  {-120, 5  }, 
  {-40, 15 }, 
  {-15, -100}, 
  { 20, -150}
};
