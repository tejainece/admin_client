import 'dart:async';
import 'package:jaguar_resty/jaguar_resty.dart';

abstract class Fetcher {
  FutureOr<M> create<M>(String resName, M model);

  FutureOr<M> read<M>(String resName, String id);

  // TODO add pagination
  FutureOr<List<M>> readList<M>(String resName);

  FutureOr<M> update<M>(String resName, M model);

  FutureOr remove(String resName, String id);
}

class SimpleFetcher implements Fetcher {
  dynamic serializer;

  String baseUrl;

  Future<M> create<M>(String resName, M model) =>
      post(baseUrl + '/$resName').one(serializer.fromMap);

  Future<M> read<M>(String resName, String id) =>
      get(baseUrl + '/$resName/$id').one<M>(serializer.fromMap);

  // TODO add pagination
  Future<List<M>> readList<M>(String resName) =>
      get(baseUrl + '/$resName').list<M>(serializer.fromMap);

  Future<M> update<M>(String resName, M model) => put(baseUrl + '/$resName')
      .json(serializer.toMap(model))
      .one<M>(serializer.fromMap);

  Future remove(String resName, String id) =>
      delete(baseUrl + '/$resName/$id').go();
}
