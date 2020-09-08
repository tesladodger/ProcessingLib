class NodeGene {
  private TYPE type;
  private int id;
  private int layer;
  
  private float input;
  
  NodeGene (TYPE type, int id, int layer) {
    this.type = type;
    this.id = id;
    this.layer = layer;
    
    input = 0;
  }
  
  void engage (List<ConnectionGene> connections, Map<Integer, NodeGene> nodes) {
    for (ConnectionGene con : connections) {
      if (con.isExpressed()) {
        float output = sigmoidTF(input) * con.getWeight();
        nodes.get(con.getOutNode()).addToInput(output);
      }
    }
  }
  
  private float sigmoidTF (float x) {
    return 1f / (1f + (float) Math.pow(Math.E, -4.9f * x));
  }
  
  void addToInput (float value) {
    input += value;
  }
  
  float getOutput () {
    return sigmoidTF(input);
  }
  
  void reset () {
    input = 0;
  }
  
  NodeGene copy () {
    return new NodeGene(type, id, layer);
  }
  
  TYPE getType () {
    return type;
  }
  
  int getId () {
    return id;
  }
  
  int getLayer () {
    return layer;
  }
  
  void incrementLayer () {
    layer++;
  }
  
}


enum TYPE {
  INPUT,
  HIDDEN,
  OUTPUT,
  ;
}
