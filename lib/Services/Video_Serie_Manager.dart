import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Services/Interface/ILoad_Manager_Database.dart';

class VideoSerieManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) {
    // TODO: implement GetGen
    throw UnimplementedError();
  }

  @override
  Future<List<BaseModel>> getList(Map<String, Object> fields) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<bool> insert(BaseModel model) {
    // TODO: implement insert
    throw UnimplementedError();
  }
}
