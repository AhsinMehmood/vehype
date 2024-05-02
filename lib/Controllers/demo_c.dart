class DemoClass {
  //int
  int number1 = 7;
  int number2 = 3;

  int calculation() {
    int result = number1 + number2;

    return result;
  }

  ///String
  String name = 'ahsin';
  //boolean
  bool iseven = false;
//list
  List animal = [
    'cat',
    'snack',
    'cow',
  ];
  //map
  Map personality = {'name': 'ahsin', 'work': 'develpor'};
  //String
  String getAhsinWork() {
    return personality['name'];
  }
}
