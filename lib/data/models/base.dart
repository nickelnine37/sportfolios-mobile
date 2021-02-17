
/// A data model models any document coming from firebase. This is the base class that all
/// others shoudl inherit from. 
class BaseDataModel {

  final String id;
  BaseDataModel(this.id);

  @override
  String toString() {
    return 'BaseDataModel($id)';
  }
}