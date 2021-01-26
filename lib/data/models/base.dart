import 'package:cloud_firestore/cloud_firestore.dart';

/// A data model models any document coming from firebase. This is the base class that all
/// others shoudl inherit from. 
class BaseDataModel {

  String id;

  // BaseDataModel(this.id);

  BaseDataModel populate(DocumentSnapshot snapshot){
    id = snapshot.id;
    return this;
  }

}