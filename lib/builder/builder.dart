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
    {AdminPartBuilder header,
    AdminPartBuilder main,
    AdminPartBuilder footer,
    Renderers renderers,
    Router router}) {
  Renderers rens = defaultRenderers.clone();
  if (renderers != null) rens.merge(renderers);

  Router rou = new Router();
  admin.makeRoutes(rou);
  if (router != null) rou.merge(router);

  BuildContext info = BuildContext(router: rou, renderers: rens, admin: admin);

  Element h = (header ?? buildHeader)(info);
  Element m = (main ?? buildMain)(info);
  Element f = (footer ?? buildFooter)(info);

  var ret = new DivElement();
  if (h != null) ret.append(h);
  if (m != null) ret.append(m);
  if (f != null) ret.append(f);
  return ret;
}

Element buildHeader(BuildContext info) => new DivElement()
  ..classes.add('admin-header')
  ..append(new SpanElement()
    ..classes.add('admin-title')
    ..text = info.admin.title);

Element buildMain(BuildContext info) {
  return new DivElement()..append(buildMenu(info))..append(buildContent(info));
}

Element buildMenu(BuildContext info) {
  var ret = DivElement();
  for (Resource r in info.admin.resources) {
    ret.append(new DivElement()
      ..append(new SpanElement()..text = r.label)
      ..onClick.listen((_) {
        print(r.name);
        info.navigator.add(Route('@${r.name}'));
      }));
  }
  return ret;
}

Element buildContent(BuildContext info) {
  final ret = new DivElement();

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

Element buildFooter(BuildContext info) => new DivElement();