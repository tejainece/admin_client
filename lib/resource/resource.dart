import 'dart:async';
import 'package:admin_client/controls/controls.dart';
import 'package:admin_client/fetcher/fetcher.dart';

abstract class CreateView<R> {
  FutureOr<View> renderCreate(String resName, Fetcher f);
}

abstract class UpdateView<R> {
  FutureOr<View> renderUpdate(String resName, Fetcher f, R model);
}

abstract class ReadView<R> {
  FutureOr<View> renderRead(String resName, Fetcher f, R model);
}

abstract class ReadListView<R> {
  FutureOr<View> renderReadList(String resName, Fetcher f, List<R> model);
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
  final Fetcher fetcher;
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
      router['@$name/create'] = (Route route, Admin admin) async {
        Fetcher f = fetcher ?? admin.fetcher;
        return create.renderCreate(name, f);
      };
    }
    if (update != null) {
      router['@$name/edit/:id'] = (Route route, Admin admin) async {
        Fetcher f = fetcher ?? admin.fetcher;
        return update.renderUpdate(
            name, f, await f.read(name, route[2]));
      };
    }
    if (read != null) {
      router['@$name/:id'] = (Route route, Admin admin) async {
        Fetcher f = fetcher ?? admin.fetcher;
        return read.renderRead(name, f, await f.read(name, route[1]));
      };
    }
    if (readList != null) {
      router['@$name'] = (Route route, Admin admin) async {
        // TODO implement pagination
        Fetcher f = fetcher ?? admin.fetcher;
        return readList.renderReadList(name, f, await f.readList(name));
      };
    }
  }
}

class Admin {
  final Iterable<Resource> resources;

  final String title;

  final String logo;

  // TODO auth

  final Fetcher fetcher;

  Admin(this.resources,
      {this.title: 'Jaguar admin',
      this.fetcher,
      this.logo: '/admin/static/images/logo.png'});

  void makeRoutes(Router router) {
    for (Resource r in resources) r.makeRoutes(router);
  }
}

typedef FutureOr<dynamic /* Element | View */ > ContentMaker(
    Route route, Admin admin);

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
