import 'dart:async';
import 'package:jaguar_resty/jaguar_resty.dart';

abstract class Fetcher<M> {
  FutureOr<M> create(String resName, M model);

  FutureOr<M> read(String resName, String id);

  // TODO add pagination
  FutureOr<List<M>> readList(String resName);

  FutureOr<M> update(String resName, M model);

  FutureOr remove(String resName, String id);
}

class WrapFetcher<M> implements Fetcher<M> {
  GenericFetcher _inner;

  FutureOr<M> create(String resName, M model) =>
      _inner.create<M>(resName, model);

  FutureOr<M> read(String resName, String id) => _inner.read<M>(resName, id);

  // TODO add pagination
  FutureOr<List<M>> readList(String resName) => _inner.readList<M>(resName);

  FutureOr<M> update(String resName, M model) =>
      _inner.update<M>(resName, model);

  FutureOr remove(String resName, String id) => _inner.remove(resName, id);
}

abstract class GenericFetcher {
  FutureOr<M> create<M>(String resName, M model);

  FutureOr<M> read<M>(String resName, String id);

  // TODO add pagination
  FutureOr<List<M>> readList<M>(String resName);

  FutureOr<M> update<M>(String resName, M model);

  FutureOr remove(String resName, String id);
}

class SimpleGenericFetcher implements GenericFetcher {
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
