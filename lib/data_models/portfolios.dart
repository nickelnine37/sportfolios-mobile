import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';

class Portfolio {

  String name;
  List<Contract> contracts;
  List<int> amounts;
  bool public;

  List<double> pH;
  List<double> pD;
  List<double> pW;
  List<double> pM;
  List<double> pMax;

  double hourReturn;
  double dayReturn;
  double weekReturn;
  double monthReturn;
  double totalReturn;

  double hourValueChange;
  double dayValueChange;
  double weekValueChange;
  double monthValueChange;
  double totalValueChange;
  double value;
  
  Portfolio({this.name, this.contracts, this.amounts, this.public}) {

    pH = matrixMultiply(this.contracts.map((contract) => contract.pH).toList(), this.amounts);
    pD = matrixMultiply(this.contracts.map((contract) => contract.pD).toList(), this.amounts);
    pW = matrixMultiply(this.contracts.map((contract) => contract.pW).toList(), this.amounts);
    pM = matrixMultiply(this.contracts.map((contract) => contract.pM).toList(), this.amounts);
    pMax = matrixMultiply(this.contracts.map((contract) => contract.pMax).toList(), this.amounts);


    value = dotProduct(this.amounts, this.contracts.map((contract) => contract.price).toList());
    double value1HAgo = dotProduct(this.amounts, this.contracts.map((contract) => contract.pH.first).toList());
    double value1DAgo = dotProduct(this.amounts, this.contracts.map((contract) => contract.pD.first).toList());
    double value1WAgo = dotProduct(this.amounts, this.contracts.map((contract) => contract.pW.first).toList());
    double value1MAgo = dotProduct(this.amounts, this.contracts.map((contract) => contract.pM.first).toList());
    double valueMaxAgo = dotProduct(this.amounts, this.contracts.map((contract) => contract.pMax.first).toList());

    hourValueChange = value - value1HAgo;
    dayValueChange = value - value1DAgo;
    weekValueChange = value - value1WAgo ;
    monthValueChange = value - value1MAgo ;
    totalValueChange = value - valueMaxAgo;

    hourReturn = hourValueChange / value1HAgo;
    dayReturn = dayValueChange / value1DAgo;
    weekReturn = weekValueChange / value1WAgo;
    monthReturn = monthValueChange / value1MAgo;
    totalReturn = totalValueChange / valueMaxAgo;

  }

  @override
  String toString() {
  return 'Portfolio(${this.name})';
   }
  
}