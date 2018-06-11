import 'dart:async';
import 'package:admin_client/controls/controls.dart';
import 'package:admin_client/fetcher/fetcher.dart';

abstract class CreateView<R> {
  FutureOr<View> renderCreate(Resource<R> res, Context ctx);
}

abstract class UpdateView<R> {
  FutureOr<View> renderUpdate(R model, Resource<R> res, Context ctx);
}

abstract class ReadView<R> {
  FutureOr<View> renderRead(R model, Resource<R> res, Context ctx);
}

abstract class ReadListView<R> {
  FutureOr<View> renderReadList(List<R> model, Resource<R> res, Context ctx);
}

class Route {
  final String path;

  final List<String> segments;

  final Map<String, dynamic> params;

  Route._(this.path, this.segments, this.params);

  factory Route(String url, {Map<String, dynamic> params}) {
    List<String> parts = url.split('/')..removeWhere((s) => s.isEmpty);
    return new Route._(parts.join('/'), parts, params ?? <String, dynamic>{});
  }

  /* TODO
  factory Route.fromParts(Iterable<String> parts) {
    // TODO
  }
  */

  String operator [](int index) => segments[index];
}

class Resource<R> {
  final CreateView<R> create;
  final UpdateView<R> update;
  final ReadView<R> read;
  final ReadListView<R> readList;
  final String name;
  final String label;
  GenericFetcher fetcher;
  final String icon;

  Resource(
      {this.create,
      this.update,
      this.read,
      this.readList,
      String label,
      String name,
      String icon,
      this.fetcher})
      : label = label ?? R.toString(),
        name = name ?? R.toString(),
        icon = icon ?? '/admin/static/icons/${name ?? R.toString()}.png';

  void makeRoutes(Router router) {
    if (create != null) {
      router[createUrl] = (Route route, Context ctx) async {
        return create.renderCreate(this, ctx);
      };
    }
    if (update != null) {
      router[updateUrl] = (Route route, Context ctx) async {
        return update.renderUpdate(
            await fetcher.read(name, route[2]), this, ctx);
      };
    }
    if (read != null) {
      router[readUrl] = (Route route, Context ctx) async {
        return read.renderRead(await fetcher.read(name, route[1]), this, ctx);
      };
    }
    if (readList != null) {
      router[readListUrl] = (Route route, Context ctx) async {
        // TODO implement pagination
        return readList.renderReadList(await fetcher.readList(name), this, ctx);
      };
    }
  }

  String get createUrl => '@$name/create';

  String get updateUrl => '@$name/edit/:id';

  String get readUrl => '@$name/:id';

  String get readListUrl => '@$name';
}

class Admin {
  final Iterable<Resource> resources;

  final String title;

  final String logo;

  // TODO auth

  final GenericFetcher fetcher;

  Admin(this.resources,
      {this.title: 'Jaguar admin',
      this.fetcher,
      this.logo: '/admin/static/images/logo.png'}) {
    for (Resource r in resources) r.fetcher ??= fetcher;
  }

  void makeRoutes(Router router) {
    for (Resource r in resources) r.makeRoutes(router);
  }
}

typedef FutureOr<dynamic /* Element | View */ > ContentMaker(
    Route route, Context ctx);

class Router {
  final Map<String, ContentMaker> _static = {};

  // Map<String, ContentMaker> _dynamic;

  final List<MapEntry<List<String>, ContentMaker>> _dynamic = [];

  operator []=(String route, ContentMaker handler) {
    List<String> parts = route.split('/')..removeWhere((s) => s.isEmpty);
    bool dynamic = parts.any((s) => s.startsWith(':'));
    if (!dynamic) {
      _static[parts.join('/')] = handler;
      return;
    }
    _dynamic.add(new MapEntry<List<String>, ContentMaker>(parts, handler));
  }

  ContentMaker operator [](String route) {
    List<String> parts = route.split('/')..removeWhere((s) => s.isEmpty);
    bool dynamic = parts.any((s) => s.startsWith(':'));
    if (!dynamic) return _static[parts.join('/')];

    // TODO search reverse
    for (MapEntry<List<String>, ContentMaker> r in _dynamic) {
      if (r.key.length == 0) {
        if (parts.length == 0) return r.value;
        continue;
      }
      if (r.key.length > parts.length) continue;
      if (r.key.length < parts.length && !r.key.last.endsWith('*')) continue;
      bool isMatch = true;
      for (int i = 0; i < r.key.length; i++) {
        String p = r.key[i];
        String p1 = parts[i];
        if (p.startsWith(':')) continue;
        if (p.endsWith('*')) break;
        if (p != p1) {
          isMatch = false;
          break;
        }
      }
      if (!isMatch) continue;
      return r.value;
    }
    return null;
  }

  void addHandler(String route, ContentMaker handler) {
    this[route] = handler;
  }

  ContentMaker getHandler(String route) => this[route];

  void merge(Router other) {
    _static.addAll(other._static);
    _dynamic.addAll(other._dynamic);
  }
}

abstract class Context {
  StreamController<Route> get navigator;

  Router get router;

  Admin get admin;
}
