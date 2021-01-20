import 'package:flutter/foundation.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';



class Portfolio extends Instrument {

  String name;
  List<Contract> contracts;
  List<int> amounts;
  bool public;

  Portfolio({@required portfolioId, @required this.name, @required this.contracts, @required this.amounts, @required this.public}) {

    id = portfolioId;
    pH = matrixMultiply(this.contracts.map((contract) => contract.pH).toList(), this.amounts);
    pD = matrixMultiply(this.contracts.map((contract) => contract.pD).toList(), this.amounts);
    pW = matrixMultiply(this.contracts.map((contract) => contract.pW).toList(), this.amounts);
    pM = matrixMultiply(this.contracts.map((contract) => contract.pM).toList(), this.amounts);
    pMax = matrixMultiply(this.contracts.map((contract) => contract.pMax).toList(), this.amounts);

    super.computeValues();
  }

  @override
  String toString() {
  return 'Portfolio(${this.name})';
   }
  
}