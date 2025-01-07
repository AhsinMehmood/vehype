enum Flavor {
  prod,
  beta,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.prod:
        return 'VEHYPE';
      case Flavor.beta:
        return 'VEHYPE Beta';
      default:
        return 'title';
    }
  }

}
