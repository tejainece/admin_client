import 'dart:async';
import 'dart:html';
import 'package:admin_client/admin_client.dart';

typedef Element AdminPartBuilder(BuildInfo info);

class BuildInfo {
  final navigator = StreamController<Route>();

  final Router router;

  final Renderers renderers;

  final Admin admin;

  Stream<Route> get onRoute => navigator.stream;

  BuildInfo({this.router, this.renderers, this.admin});
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

  BuildInfo info = BuildInfo(router: rou, renderers: rens, admin: admin);

  Element h = (header ?? buildHeader)(info);
  Element m = (main ?? buildMain)(info);
  Element f = (footer ?? buildFooter)(info);

  var ret = new DivElement();
  if (h != null) ret.append(h);
  if (m != null) ret.append(m);
  if (f != null) ret.append(f);
  return ret;
}

Element buildHeader(BuildInfo info) => new DivElement()
  ..classes.add('admin-header')
  ..append(new SpanElement()
    ..classes.add('admin-title')
    ..text = info.admin.title);

Element buildMain(BuildInfo info) {
  return new DivElement()..append(buildMenu(info))..append(buildContent(info));
}

Element buildMenu(BuildInfo info) {
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

Element buildContent(BuildInfo info) {
  final ret = new DivElement();

  final builder = (Route route) async {
    ContentMaker maker = info.router[route.path];
    if (maker == null) {
      ret.children = [new DivElement()..text = "Route not found!"];
      return;
    }

    dynamic content = maker(route, info.admin);

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

Element buildFooter(BuildInfo info) => new DivElement();

final Renderers defaultRenderers = new Renderers()
  ..register<TextField>(textFieldRenderer)
  ..register<Box>(boxRenderer)
  ..register<Button>(buttonRenderer);

Element textFieldRenderer(final field, _) {
  if (field is TextField) {
    return new DivElement()
      ..classes.add('field-text')
      ..text = field.text;
  }
  throw new Exception();
}

Element boxRenderer(final field, Renderers renderers) {
  if (field is Box) {
    var ret = new DivElement()..classes.add('box');
    for (View child in field.children) {
      ViewRenderer rend = renderers.getFor(child);
      if (rend == null)
        throw new Exception("Renderer for ${child.runtimeType} not found!");
      ret.append(rend(child, renderers));
    }
    return ret;
  }
  throw new Exception();
}

Element buttonRenderer(final field, Renderers renderers) {
  if (field is Button) {
    var ret = new DivElement()..classes.add('jaguar-admin-button');
    if (field.icon != null) ret.append(new DivElement()); // TODO set icon
    if (field.text != null) ret.append(new Text(field.text));
    if (field.tip != null) ret.title = field.tip;
    if (field.callback != null) ret.onClick.listen((_) => field.callback());
    return ret;
  }
  throw new Exception();
}

typedef Element ViewRenderer<T>(T view, Renderers renderers);

class Renderers {
  final _renderers = <Type, ViewRenderer>{};

  void register<T>(ViewRenderer<T> renderer) {
    _renderers[T] = renderer;
  }

  ViewRenderer<T> get<T>() => _renderers[T];

  ViewRenderer getFor(View view) => _renderers[view.runtimeType];

  void merge(Renderers other) {
    _renderers.addAll(other._renderers);
  }

  Renderers clone() {
    var ret = new Renderers();
    ret.merge(this);
    return ret;
  }
}
