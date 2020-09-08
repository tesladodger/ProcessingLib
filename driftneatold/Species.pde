class Species {

  /* Threshold to accept a member to this species. */
  private static final float COMPATIBILITY_THRESHOLD = 1.0f;

  /* Coefficients to assert similarity between the rep and another genome. */
  private static final float COMPAT_COEF_1 = 1.0f;
  private static final float COMPAT_COEF_3 = .9f;

  /* Probability of a child being created without crossover. */
  private static final float MUTATION_WITHOUT_CROSSOVER_PROBABILITY = 0.25f;


  /* List of members of this species. */
  private List<Car> members;

  /* The representative genome for this species (which is the one with the highest fitness). */
  private Genome rep;

  /* Individual with the highest fitness ever for this species. */
  private Car best;

  /* How many generation without improvement a species is allowed to live. */
  private static final int STALENESS_THRESHOLD = 15;

  /* How many generations without improvement. */
  private int staleness;

  /* Average fitness of a generation. */
  private float averageFitness;


  Species (Car firstMember) {
    rep = firstMember.getBrain().copy();
    best = firstMember.copy();

    staleness = -1;

    members = new ArrayList<Car>();
    members.add(firstMember);
  }


  boolean canAccept (Genome candidate) {
    float excess_disjoint = (float) calculateExcessDisjointNumber(candidate);
    float average_weight_diff = calculateAverageWeightDiff(candidate);

    int normaliser = candidate.getConnectionKeys().size() - 20;
    if (normaliser < 1) {
      normaliser = 1;
    }

    float compatibility = (COMPAT_COEF_1 * excess_disjoint) / normaliser;
    compatibility += COMPAT_COEF_3 * average_weight_diff;

    return compatibility <= COMPATIBILITY_THRESHOLD;
  }


  private int calculateExcessDisjointNumber (Genome candidate) {
    // Loop through the keys of the rep and the candidate. If they match, increment the
    // matching number.
    int matching = 0;
    for (Integer gene1 : rep.getConnectionKeys()) {
      for (Integer gene2 : candidate.getConnectionKeys()) {
        if (gene1.equals(gene2)) {
          matching++;
        }
      }
    }
    return rep.getConnectionKeys().size() + candidate.getConnectionKeys().size() - 2 * matching;
  }


  private float calculateAverageWeightDiff (Genome candidate) {
    if (rep.getConnectionKeys().size() == 0 || candidate.getConnectionKeys().size() == 0) {
      return 0f;
    }

    // Loop through all the connections. If any match, add their difference to the sum and
    // increment the matching number. After that, divide the sum by the number of matching
    // connections.
    float matching = 0;
    float sum = 0;
    for (ConnectionGene con1 : rep.getConnections().values()) {
      for (ConnectionGene con2 : candidate.getConnections().values()) {
        if (con1.getInnovationNumber() == con2.getInnovationNumber()) {
          matching++;
          sum += Math.abs(con1.getWeight() - con2.getWeight());
          break;
        }
      }
    }
    // Don't divide by 0;
    if (matching == 0) {
      return 100f;
    }
    return sum / matching;
  }


  void addToSpecies (Car newMember) {
    members.add(newMember);
  }


  Car makeAChild (Random r, Innovation innovation) {
    Car child;

    if (r.nextFloat() < MUTATION_WITHOUT_CROSSOVER_PROBABILITY) {
      child = pickAMember(r).copy();
    } else {
      Car parent1 = pickAMember(r);
      Car parent2 = pickAMember(r);

      child = new Car((parent1.getFitness() > parent2.getFitness()) ?
        crossover(parent1.getBrain(), parent2.getBrain(), r) :
        crossover(parent2.getBrain(), parent1.getBrain(), r)
        );
    }

    child.getBrain().mutate(r, innovation);
    return child;
  }


  private Car pickAMember (Random r) {
    float fitnessSum = 0;
    for (Car ind : members) {
      fitnessSum += ind.getFitness();
    }

    float rand = r.nextFloat()*fitnessSum;
    float runningSum = 0;

    for (Car ind : members) {
      runningSum += ind.getFitness();
      if (runningSum > rand) {
        return ind;
      }
    }

    return members.get(0);
  }


  void calculateIndividualFitnesses () {
    for (Car ind : members) {
      ind.calculateFitness();
    }
  }


  void sort () {
    int i = 1;
    while (i < members.size()) {
      Car ind = members.get(i);
      int j = i - 1;
      while (j >= 0 && members.get(j).getFitness() < ind.getFitness()) {
        members.set(j+1, members.get(j));
        j--;
      }
      members.set(j+1, ind);
      i++;
    }

    if (members.size() == 0) {
      staleness = 20;
      return;
    }
    rep = members.get(0).getBrain().copy();
    if (members.get(0).getFitness() > best.getFitness()) {
      best = members.get(0).copy();
      staleness = 0;
    } else {
      staleness++;
    }
  }


  void thanos () {
    int size = members.size();
    if (size > 2) {
      members.subList(size/2, size).clear();
    }
  }


  void normalizeFitness () {
    for (Car i : members) {
      i.setFitness(i.getFitness() / members.size());
    }
  }


  void calculateAverageFitness () {
    float sum = 0;
    for (Car i : members) {
      sum += i.getFitness();
    }
    averageFitness = sum / members.size();
  }


  float getAverageFitness () {
    return averageFitness;
  }


  Car getCurrentBest () {
    if (members.size() == 0) return null;
    return members.get(0);
  }


  Car getBest () {
    return best;
  }


  float getCurrentBestScore () {
    return members.size() == 0 ? 0 : members.get(0).getFitness();
  }


  boolean isStale () {
    return staleness >= STALENESS_THRESHOLD;
  }


  int numberOfMembers () {
    return members.size();
  }


  void clear () {
    members.clear();
  }
}
