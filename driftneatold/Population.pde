class Population {
  /* Array of all the individuals in a generation. */
  private Car[] individuals;

  /* Number of individuals. */
  private int popSize;

  /* List of species. */
  private List<Species> species;

  /* Counter for number of generations. */
  private int generation;

  /* Best individual of all generations. */
  private Car bestEver;

  /* Best individual of the previous generation. */
  private Car previousBest;


  public Population (int numberSensors, int numberControls, int popSize, Random r, Innovation innovation) {
    this.popSize = popSize;

    individuals = new Car[popSize];
    for (int i = 0; i < popSize; i++) {
      individuals[i] = new Car(new Genome(numberSensors, numberControls, false));
      individuals[i].getBrain().mutate(r, innovation);
    }

    species = new ArrayList<Species>();
    generation = 0;
  }


  public void updateAliveIndividuals (int[][][] track) {
    if (generation > 0) {
      previousBest.getBrain().drawGenome();
    }
    for (Car individual : individuals) {
      if (!individual.alive) continue;
      individual.see(track);
      individual.think();
      individual.move();
      individual.render();
    }
  }


  public boolean areAllDead () {
    for (Car i : individuals) {
      if (i.isAlive()) {
        return false;
      }
    }
    return true;
  }


  public void naturalSelection (Random r, Innovation innovation) {
    speciate();
    for (Species s : species) {
      s.calculateIndividualFitnesses();  // Calculate the fitness of all individuals.
      s.sort();  // Sort the members by their fitness.
    }
    sortSpecies();  // Sort the species by their fitness.

    previousBest = species.get(0).getCurrentBest().copy();
    if (bestEver == null) bestEver = species.get(0).getCurrentBest().copy();
    if (species.get(0).getCurrentBest().getFitness() > bestEver.getFitness()) {
      bestEver = species.get(0).getCurrentBest().copy();
    }

    for (Species s : species) {
      s.normalizeFitness();  // Divide fitness by number of members (fitness sharing).
      s.calculateAverageFitness();  // Average fitness of the members of a species.
      s.thanos();  // Kill half the population.
    }
    killStaleSpecies();
    float aveSum = calculateAverageFitnessSum();
    killUnreproducibleSpecies(aveSum);

    // Build the next generation.
    Car[] nextGen = new Car[popSize];
    int index = 0;  // Current index to add to nextGen.

    for (Species s : species) {
      // Add the best of every species without any mutation.
      if (index < nextGen.length-1) continue;
      nextGen[index++] = s.getBest().copy();

      int allowedChildren = (int) Math.floor(((s.getAverageFitness() / aveSum) * popSize) - 1);
      for (int i = 0; i < allowedChildren; i++) {
        if (index == nextGen.length) continue;
        nextGen[index++] = s.makeAChild(r, innovation);
      }
    }

    // Add a copy of the best for good luck.
    if (index < nextGen.length-1) {
      nextGen[index++] = previousBest.copy();
    }

    // If the next generation is still not full, keep adding children from the best species.
    while (index < nextGen.length) {
      nextGen[index++] = species.get(0).makeAChild(r, innovation);
    }

    arrayCopy(nextGen, individuals);
    
    generation++;
    printStats();
  }


  private void speciate () {
    // Clear the members of every species.
    for (Species s : species) {
      s.clear();
    }

    // Go through all the individuals.
    for (Car individual : individuals) {
      boolean speciesFound = false;
      for (Species s : species) {
        // When a species can accept this individual, add it.
        if (s.canAccept(individual.getBrain())) {
          s.addToSpecies(individual);
          speciesFound = true;
          break;
        }
      }
      // If no species is found, create a new one.
      if (!speciesFound) {
        species.add(new Species(individual));
      }
    }
  }


  private void sortSpecies () {
    int i = 1;
    while (i < species.size()) {
      Species si = species.get(i);
      int j = i - 1;
      while (j >= 0 && species.get(j).getCurrentBestScore() < si.getCurrentBestScore()) {
        species.set(j+1, species.get(j));
        j--;
      }
      species.set(j+1, si);
      i++;
    }
  }


  private void killStaleSpecies () {
    for (int i = species.size()-1; i > 2; i--) {
      if (species.get(i).isStale()) {
        species.remove(i);
      }
    }
  }


  private void killUnreproducibleSpecies (float aveSum) {
    for (int i = species.size()-1; i > 0; i--) {
      if ((species.get(i).getAverageFitness() / aveSum) * individuals.length < 1) {
        species.remove(i);
      }
    }
  }


  private float calculateAverageFitnessSum () {
    float sum = 0;
    for (Species s : species) {
      sum += s.getAverageFitness();
    }
    return sum;
  }


  void printStats () {
    System.out.println();
    System.out.println("Generation: " + generation +
      "  | Number of species: " + species.size() +
      "  | Best score : "       + bestEver.getFitness());
    System.out.println();
  }
  
}
