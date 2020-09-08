class Genome {
  /* Probability of mutating the weight of all connections. */
  private static final float WEIGHT_MUTATION_PROBABILITY = 0.8f;

  /* Probability of mutating a connection to a new random number. */
  private static final float NEW_RANDOM_WEIGHT_PROBABILITY = 0.1f;

  /* Probability of adding a new node. */
  private static final float NEW_NODE_PROBABILITY = 0.05f;

  /* Probability of adding a new connection. */
  private static final float NEW_CONNECTION_PROBABILITY = 0.05f;

  /* Maps from innovation number to connections and nodes, and lists of all the keys
   * for random selection. */
  private Map<Integer, ConnectionGene> connections;
  private List<Integer> connectionKeys;
  private Map<Integer, NodeGene> nodes;
  private List<Integer> nodeKeys;

  private int biasNode;

  /* How many inputs, outputs and layers in this network. */
  private int inputNumber;
  private int outputNumber;
  private int layers;


  Genome (int inputNumber, int outputNumber, boolean fromCrossover) {
    if (inputNumber < 1 || outputNumber < 1) throw new
      IllegalArgumentException("Number of inputs and outputs must be natural numbers.");

    connections = new HashMap<Integer, ConnectionGene>();
    connectionKeys = new ArrayList<Integer>();
    nodes = new HashMap<Integer, NodeGene>();
    nodeKeys = new ArrayList<Integer>();

    this.inputNumber = inputNumber;
    this.outputNumber = outputNumber;
    layers = 2;

    if (fromCrossover) return;

    // Create the input nodes.
    for (int i = 0; i < inputNumber; i++) {
      addNodeGene(new NodeGene(TYPE.INPUT, nodes.size(), 0));
    }

    // Create the output nodes.
    for (int j = 0; j < outputNumber; j++) {
      addNodeGene(new NodeGene(TYPE.OUTPUT, nodes.size(), 1));
    }

    // Create the bias node.
    biasNode = nodes.size();
    addNodeGene(new NodeGene(TYPE.INPUT, nodes.size(), 0));
  }


  Genome copy () {
    Genome clone = new Genome(inputNumber, outputNumber, true);

    // Add copies of the nodes to the copy genome.
    for (NodeGene nodeGene : nodes.values()) {
      clone.nodes.put(nodeGene.getId(), nodeGene.copy());
      clone.nodeKeys.add(nodeGene.getId());
    }

    // Add copies of the connections to the copy genome.
    for (ConnectionGene connectionGene : connections.values()) {
      clone.connections.put(connectionGene.getInnovationNumber(), connectionGene.copy());
      clone.connectionKeys.add(connectionGene.getInnovationNumber());
    }

    clone.biasNode = biasNode;
    clone.layers = layers;

    return clone;
  }


  void mutate (Random r, Innovation innovation) {
    // If there are no connections, connect all the inputs to the outputs.
    if (connections.size() == 0) {
      for (int i = 0; i < (inputNumber + 1) * outputNumber; i++) {
        addConnectionMutation(r, innovation);
      }
      return;
    }

    if (r.nextFloat() < WEIGHT_MUTATION_PROBABILITY) {
      weightMutation(r);
    }
    if (r.nextFloat() < NEW_CONNECTION_PROBABILITY) {
      addConnectionMutation(r, innovation);
    }
    if (r.nextFloat() < NEW_NODE_PROBABILITY) {
      addNodeMutation(r, innovation);
    }
  }


  void weightMutation (Random r) {
    for (ConnectionGene con : connections.values()) {
      if (r.nextFloat() < NEW_RANDOM_WEIGHT_PROBABILITY) {
        con.setWeight(r.nextFloat() * 2f - 1f);
      } else {
        float newWeight = con.getWeight() + (float) (r.nextGaussian() / 50f);
        con.setWeight(newWeight);
      }
    }
  }


  void addConnectionMutation (Random r, Innovation innovation) {
    // No connections can be added to a fully connected network.
    if (isFullyConnected()) return;

    NodeGene node1 = nodes.get(nodeKeys.get(r.nextInt(nodeKeys.size())));
    NodeGene node2 = nodes.get(nodeKeys.get(r.nextInt(nodeKeys.size())));

    // Keep picking nodes until they are good for connecting.
    while (randomConnectionNodesAreShit(node1, node2)) {
      node1 = nodes.get(nodeKeys.get(r.nextInt(nodeKeys.size())));
      node2 = nodes.get(nodeKeys.get(r.nextInt(nodeKeys.size())));
    }

    // Check if the connection is reversed and swap the nodes.
    if (node1.getLayer() > node2.getLayer()) {
      NodeGene temp = node1;
      node1 = node2;
      node2 = temp;
    }

    // Random weight for the new connection.
    float weight = r.nextFloat()*2f - 1f;

    // Get the innovation number.
    int number = innovation.getInnovationNumber(node1.getId(), node2.getId());

    // Create the connection.
    ConnectionGene newConnection = new ConnectionGene(node1.getId(), node2.getId(), 
      weight, true, number);
    connections.put(newConnection.getInnovationNumber(), newConnection);
    connectionKeys.add(newConnection.getInnovationNumber());
  }


  private boolean randomConnectionNodesAreShit (NodeGene n1, NodeGene n2) {
    // Check if the connection exists.
    boolean connectionExists = false;
    for (ConnectionGene con : connections.values()) {
      if (con.getInNode() == n1.getId() && con.getOutNode() == n2.getId()) {
        connectionExists = true;
        break;
      } else if (con.getInNode() == n2.getId() && con.getOutNode() == n1.getId()) {
        connectionExists = true;
        break;
      }
    }
    if (connectionExists) return true;

    // Check if the nodes are in the same layer.
    return (n1.getLayer() == n2.getLayer()) ;
  }


  void addNodeMutation (Random r, Innovation innovation) {
    // Pick a random connection.
    ConnectionGene con = connections.get(connectionKeys.get(r.nextInt(connectionKeys.size())));

    // Try not to separate the bias node.
    while (con.getInNode() == biasNode && connections.size() != 1) {
      con = connections.get(connectionKeys.get(r.nextInt(connectionKeys.size())));
    }

    // Get the nodes from that connection.
    NodeGene inNode = nodes.get(con.getInNode());
    NodeGene outNode = nodes.get(con.getOutNode());

    // Disable the connection.
    con.disable();

    // Create a new hidden node. The layer is the inNode's layer + 1.
    NodeGene newNode = new NodeGene(TYPE.HIDDEN, nodes.size(), inNode.getLayer()+1);

    // If the layer of the new node is equal to the layer of the outNode, a new layer needs to
    // be created and all the nodes on the layer greater or equal to the output need to change
    // layer.
    if (newNode.getLayer() == outNode.getLayer()) {
      for (NodeGene n : nodes.values()) {
        if (n.getLayer() >= newNode.getLayer()) {
          n.incrementLayer();
        }
      }
      layers++;
    }

    // The connection to the new node has a weight of 1 and the connection from it has the
    // weight of the previous connection.
    int number = innovation.getInnovationNumber(inNode.getId(), newNode.getId());
    ConnectionGene toNew = new ConnectionGene(inNode.getId(), newNode.getId(), 
      1f, true, number);
    number = innovation.getInnovationNumber(newNode.getId(), outNode.getId());
    ConnectionGene fromNew = new ConnectionGene(newNode.getId(), outNode.getId(), 
      con.getWeight(), true, number);

    // Put the new node and new connections in the maps.
    addNodeGene(newNode);
    addConnectionGene(toNew);
    addConnectionGene(fromNew);
  }


  private boolean isFullyConnected () {
    // Each index contains the number of nodes the layer.
    int[] nodesInLayers = new int[layers];

    for (NodeGene n : nodes.values()) {
      nodesInLayers[n.getLayer()] += 1;
    }

    // The total number of connections is the sum of the product of the number of nodes in the
    // layers and the number of nodes in subsequent layers.
    int totalConnections = 0;
    for (int i = 0; i < layers-1; i++) {
      int nodesInFront = 0;
      for (int j = i+1; j < layers; j++) {
        nodesInFront += nodesInLayers[j];
      }
      totalConnections += nodesInLayers[i] * nodesInFront;
    }

    // If the number of connections is already the total number possible, return true.
    return connections.size() == totalConnections;
  }


  float[] feedForward (float[] inputs) {
    if (inputs.length != inputNumber) throw new IllegalArgumentException("" +
      "The input array must match the number of inputs of the network.");

    // Order the nodes in an array by layer.
    NodeGene[] orderedNodes = new NodeGene[nodes.size()];
    int index = 0;
    for (int l = 0; l < layers; l++) {
      for (NodeGene n : nodes.values()) {
        if (n.getLayer() == l) {
          // Reset the values of the node.
          n.reset();
          // Add it to the array.
          orderedNodes[index++] = n;
        }
      }
    }

    // Set the values of the input nodes.
    for (int i = 0; i < inputNumber; i++) {
      // Use nodeKeys because they are ordered like the inputs.
      nodes.get(nodeKeys.get(i)).addToInput(inputs[i]);
    }

    // Set the value of the bias node.
    nodes.get(biasNode).addToInput(1);

    // Create the list of connections for every node and engage it.
    for (NodeGene n : orderedNodes) {
      List<ConnectionGene> connectionsFromCurrentNode = new ArrayList<ConnectionGene>();
      for (ConnectionGene con : connections.values()) {
        if (nodes.get(con.getInNode()) == n) {
          connectionsFromCurrentNode.add(con);
        }
      }
      if (n.getType() != TYPE.OUTPUT) {
        n.engage(connectionsFromCurrentNode, nodes);
      }
    }

    // Get the values of the output nodes.
    float[] output = new float[outputNumber];
    index = 0;
    for (int i = inputNumber; i < inputNumber + outputNumber; i++) {
      // Again, use the keys.
      output[index++] = nodes.get(nodeKeys.get(i)).getOutput();
    }

    return output;
  }


  void addNodeGene (NodeGene node) {
    nodes.put(node.getId(), node);
    nodeKeys.add(node.getId());
  }

  void addConnectionGene (ConnectionGene connection) {
    connections.put(connection.getInnovationNumber(), connection);
    connectionKeys.add(connection.getInnovationNumber());
  }

  private Map<Integer, NodeGene> getNodes () {
    return nodes;
  }

  Map<Integer, ConnectionGene> getConnections () {
    return connections;
  }

  List<Integer> getConnectionKeys () {
    return connectionKeys;
  }


  void drawGenome () {
    int ox = 180;   // origin x
    int oy = -40;   // origin y
    int h = 400;    // height
    int w = 400;    // width
    
    List<PVector> nodeCoords = new ArrayList<PVector>();
    List<Integer> nodeIds = new ArrayList<Integer>();

    // Loop all the layers.
    for (int i = 0; i < layers; i++) {
      // Find all the nodes in the current layer and add them to a list.
      List<NodeGene> nodesInLayer = new ArrayList<NodeGene>();
      for (NodeGene node : nodes.values()) {
        if (node.getLayer() == i) {
          nodesInLayer.add(node);
        }
      }
      // Loop the created list and add the ids and coordinates to the lists.
      int x = ox + ((i+1) * w) / (layers+1);
      for (int j = 0; j < nodesInLayer.size(); j++) {
        int y = oy + ((j+1)*h) / (nodesInLayer.size()+1);
        nodeCoords.add(new PVector(x, y));
        nodeIds.add(nodesInLayer.get(j).getId());
      }
    }
    
    // Draw the connections
    strokeWeight(2);
    for (ConnectionGene con : connections.values()) {
      PVector from = nodeCoords.get(nodeIds.indexOf(con.getInNode()));
      PVector to = nodeCoords.get(nodeIds.indexOf(con.getOutNode()));
      
      if (!con.isExpressed()) continue;
      else if (con.getWeight() >= 0) stroke(255, 0, 0);
      else stroke(0, 0, 255);
      strokeWeight(map(abs(con.getWeight()), 0, 1, 0, 3));
      line(from.x, from.y, to.x, to.y);
    }
    
    // Draw the nodes.
    for (int i = 0; i < nodeCoords.size(); i++) {
      fill(200);
      stroke(0);
      strokeWeight(2);
      ellipse(nodeCoords.get(i).x, nodeCoords.get(i).y, 20, 20);
      textSize(10);
      fill(0);
      textAlign(CENTER, CENTER);
      text(nodeIds.get(i), nodeCoords.get(i).x, nodeCoords.get(i).y);
    }

  }
}



/* Probability of disabling a connection if either parent has it disabled. */
private static final float DISABLE_CONNECTION_PROBABILITY = 0.75f;

/**
 * Performs crossover between two genomes.
 *
 * @param parent1 more fit parent;
 * @param parent2 other parent;
 * @param r Random;
 *
 * @return new genome;
 */
Genome crossover (Genome parent1, Genome parent2, Random r) {
  Genome child = new Genome(parent1.inputNumber, parent1.outputNumber, true);
  // Take all the nodes from the fittest parent.
  for (NodeGene p1Node : parent1.getNodes().values()) {
    child.addNodeGene(p1Node.copy());
  }

  child.layers = parent1.layers;
  child.biasNode = parent1.biasNode;

  // Add the connections to the child.
  for (ConnectionGene p1Con : parent1.connections.values()) {
    if (parent2.getConnections().containsKey(p1Con.getInnovationNumber())) { // Matching gene
      // Create the connection.
      ConnectionGene childConGene = new ConnectionGene(
        p1Con.getInNode(), p1Con.getOutNode(), 
        p1Con.getWeight(), true, p1Con.getInnovationNumber());

      // Disable the gene if either parent has it disabled.
      if (!p1Con.isExpressed() || !parent2.getConnections().get(p1Con.getInnovationNumber()).isExpressed()) {
        if (r.nextFloat() < DISABLE_CONNECTION_PROBABILITY) {
          childConGene.disable();
        }
      }

      child.addConnectionGene(childConGene);
    } else { // Disjoint gene
      // Add all disjoint genes from the fittest parent.
      ConnectionGene childConGene = p1Con.copy();
      child.addConnectionGene(childConGene);
    }
  }

  return child;
}
