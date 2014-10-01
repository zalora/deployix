{
  build-support = {
    output-to-argument = import ./output-to-argument;

    compile-c = import ./compile-c;
  };

  wait-for-file = import ./wait-for-file;

  defnixos = import ./defnixos;
}
