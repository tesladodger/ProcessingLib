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
      //vertex(point[0], point[1]);
      curveVertex(point[0], point[1]);
      //ellipse(point[0], point[1], 10, 10);
    }
    endShape();
    
    fill(0, 50, 50);
    beginShape();
    for (int[] point : iC) {
      //vertex(point[0], point[1]);
      curveVertex(point[0], point[1]);
      //ellipse(point[0], point[1], 10, 10);
    }
    endShape();
  }
  
    
}
