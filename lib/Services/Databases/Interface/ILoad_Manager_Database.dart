import 'package:unistream/Models/Templates/Base_Model.dart';

abstract class IloadManagerDatabase {
  Future<void> insert(BaseModel model);
  Future<BaseModel> getOne(Map<String, Object> fields);
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields);
  Iterable GetGen(item);
}
