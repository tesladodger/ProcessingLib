class ConnectionGene {
  private int inNode;
  private int outNode;
  private float weight;
  private boolean expressed;
  private int innovationNumber;
  
  ConnectionGene (int inNode, int outNode, float weight, boolean expressed, int innovationNumber) {
    this.inNode = inNode;
    this.outNode = outNode;
    this.weight = weight;
    this.expressed = expressed;
    this.innovationNumber = innovationNumber;
  }
  
  void setWeight (float weight) {
    this.weight = weight;
  }
  
  ConnectionGene copy () {
    return new ConnectionGene(inNode, outNode, weight, expressed, innovationNumber);
  }
  
  void disable () {
    expressed = false;
  }
  
  int getInNode () {
    return inNode;
  }
  
  int getOutNode () {
    return outNode;
  }

  public float getWeight () {
    return weight;
  }

  boolean isExpressed () {
    return expressed;
  }

  public int getInnovationNumber () {
    return innovationNumber;
  }
}
