import 'package:sportfolios_alpha/data_models/contracts.dart';

class Portfolio {

  String name;
  List<Contract> contracts;
  List<int> amounts;
  bool public;

  Portfolio({this.name, this.contracts, this.amounts, this.public});

  @override
  String toString() {
  return 'Portfolio(${this.name})';
   }
  
}