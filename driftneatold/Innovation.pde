class Innovation {

  /**
   * Class to hold the simple values of a connection:
   * c -> innovation number;
   * i -> in node;
   * o -> out node;
   */
  private class CIO {
    int c;
    int i;
    int o;
    CIO (int c, int i, int o) {
      this.c = c;
      this.i = i;
      this.o = o;
    }
  }

  private List<CIO> history;

  Innovation () {
    history = new ArrayList<CIO>();
  }

  /**
   * Method to get the innovation number of a new connection. If the connection exists, that
   * number is returned, otherwise a new connection is added to the history and the next value
   * is returned.
   *
   * @param i id of the input node;
   * @param o id of the output node;
   *
   * @return the innovation number of the connection;
   */
  int getInnovationNumber (int i, int o) {
    for (CIO cio : history) {
      // If a match is found, return the innovation number of that match.
      if (cio.i == i && cio.o == o) {
        return cio.c;
      }
    }

    // No match found, create a new number and add it to the history.
    int number = history.size();
    history.add(new CIO(number, i, o));
    return number;
  }
}
