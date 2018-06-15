import 'dart:async';
import 'dart:html';
import 'package:admin_client/admin_client.dart';

typedef Element AdminPartBuilder(BuildContext info);

class BuildContext implements Context {
  final navigator = StreamController<Route>();

  final Router router;

  final Renderers renderers;

  final Admin admin;

  Stream<Route> get onRoute => navigator.stream;

  BuildContext({this.router, this.renderers, this.admin});
}

Element build(Admin admin,
    {AdminPartBuilder menu, Renderers renderers, Router router}) {
  Renderers rens = defaultRenderers.clone();
  if (renderers != null) rens.merge(renderers);

  Router rou = new Router();
  admin.makeRoutes(rou);
  if (router != null) rou.merge(router);

  BuildContext info = BuildContext(router: rou, renderers: rens, admin: admin);

  Element h = buildSidebar(info, menu: menu);
  Element m = buildContent(info);

  return new DivElement()
    ..classes.add('admin')
    ..append(h)
    ..append(m);
}

Element buildSidebar(BuildContext info, {AdminPartBuilder menu}) =>
    new DivElement()
      ..classes.add('admin-sidebar')
      ..append(new DivElement()
        ..classes.add('admin-header')
        ..append(new DivElement()
          ..classes.add('admin-title')
          ..text = info.admin.title)
        ..append(new DivElement()
          ..classes.add('admin-header-actions')
          ..append(new DivElement()..text = "Logout")))
      ..append(new DivElement()
        ..classes.add('admin-menu')
        ..append((menu ?? buildMenu)(info)));

Element buildMenu(BuildContext info) {
  var ret = DivElement()..classes.add('admin-menu-holder');
  for (Resource r in info.admin.resources) {
    ret.append(new DivElement()
      ..classes.add('admin-menu-item')
      ..append(new SpanElement()
        ..classes.add('admin-menu-item-title')
        ..text = r.label
        ..onClick.listen((_) {
          info.navigator.add(Route('@${r.name}'));
        })));
  }
  return ret;
}

Element buildContent(BuildContext info) {
  final ret = new DivElement()..classes.add('admin-content');

  final builder = (Route route) async {
    ContentMaker maker = info.router[route.path];
    if (maker == null) {
      ret.children = [new DivElement()..text = "Route not found!"];
      return;
    }

    dynamic content = maker(route, info);

    if (content is Future) content = await content;

    if (content is View) {
      ViewRenderer rend = info.renderers.getFor(content);
      content = rend(content, info.renderers);
    }

    if (content is Element) {
      ret.children = [content];
      return;
    }

    ret.children = [
      new DivElement()..text = "Invalid view returned by builder!"
    ];
  };

  info.onRoute.listen(builder);

  builder(Route(''));

  return ret;
}
