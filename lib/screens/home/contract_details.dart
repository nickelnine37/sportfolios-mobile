

import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';

class ContractDetails extends StatelessWidget {

  final Contract contract;

  const ContractDetails(this.contract);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contract.name)),
      body: Center(child: Text(contract.name)),
    );
  }
}