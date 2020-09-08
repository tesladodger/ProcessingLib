class Track {
  
  /*  
   *  iC -> inside curve of the track;
   *  oC -> outside curve;
   */
  
  /**
   * Loops the outer and inner coordinate arrays and draws a curve shape.
   */
  void render () {
    strokeWeight(1);
    stroke(255);
    
    fill(30);
    beginShape();
    for (int[] point : oC) {
      curveVertex(point[0], point[1]);
    }
    endShape();
    
    fill(0, 100, 50);
    beginShape();
    for (int[] point : iC) {
      curveVertex(point[0], point[1]);
    }
    endShape();
  }
  
  
  /**
   * Getter method for the coordinates of the track.
   *
   * @return 3d array: [0] is the inner limit, [1] is the outer;
   */
  int[][][] getCoords () {
    return new int[][][] {iC, oC};
  }
  
  
  // Points for the inside of the track.
  private final int[][] iC = {
    {-65,   90 },
    {-20,   100},
    { 20,   90 },
    { 50,   50 },
    { 50,   0  },
    { 50,  -50 },
    { 55,  -72 },
    { 90,  -80 },
    { 250, -70 },
    { 320, -40 },
    { 320,  40 },
    { 300,  100},
    { 250,  200},
    { 200,  255},
    { 150,  260},
    { 0,    240},
    {-150,  250},
    {-220,  260},
    {-320,  280},
    {-345,  283},
    {-340,  260},
    {-300,  100},
    {-340, -60 },
    {-300, -220},
    {-150, -290},
    { 0,   -300},
    { 150, -310},
    { 340, -320},
    { 400, -300},
    {400,  -260},
    { 350, -240},
    { 150, -260},
    { 0,   -250},
    {-110, -215},
    {-155, -170},
    {-160, -100},
    {-140,  0  },
    {-100,  70 },
    {-65,   90 },
    {-20,   100},
    { 20,   90 }
  };
  
  // Points for the outside of the track.
  private final int[][] oC = {
    {-30,   10 },
    {-30,  -100},
    { 20,  -150},
    { 100, -170},
    { 300, -150},
    { 380, -90 },
    { 390,  30 },
    { 340,  170},
    { 275,  265},
    { 205,  305},
    { 150,  310},
    { 50,   290},
    { 0,    280},
    {-145,  300},
    {-290,  350},
    {-340,  360},
    {-375,  340},
    {-400,  240},
    {-360,  165},
    {-345,  100},
    {-380, -25 },
    {-380, -170},
    {-345, -260},
    {-235, -310},
    {-120, -340},
    {-0,   -345},
    { 150, -355},
    { 330, -365},
    { 410, -350},
    { 445, -305},
    { 440, -230},
    { 385, -185},
    { 320, -200},
    { 250, -210},
    { 150, -215},
    { 0,   -200},
    {-90,  -150},
    {-85,  -70 },
    {-30,   10 },
    {-30,  -100},
    { 20,  -150}
  };
  
}
