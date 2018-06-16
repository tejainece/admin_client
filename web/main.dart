import 'dart:async';
import 'dart:html';
import 'package:admin_client/admin_client.dart';
import 'package:admin_client/controls/fa_solid.dart';

class Player {
  String name;
  int age;
  Player({this.name, this.age});
  Player.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        age = map['age'];

  String toString() => 'Player(name: ${name}, age: ${age})';
}

class PlayerRes implements AllPages<Player> {
  @override
  Future<View> composeReadList(
      List<Player> model, Resource<Player> r, Context ctx) {
    return simpleListPage({
      'Name': (Player p) => TextField(p.name),
      'Age': (Player p) => IntField(p.age),
    }).makeView(model, r, ctx);
  }

  @override
  View composeRead(Player model, Resource<Player> res, Context ctx) {
    var ret = Box(classes: ['admin-content-body'], children: [
      LabeledTextField(text: model.name, label: 'Name'),
      LabeledIntField(text: model.age, label: 'Age')
    ]);
    return new Box(children: [
      TitleBar(res.label, icon: FASolid.edit, actions: [
        Button(
            text: '${FASolid.edit} Edit',
            color: Button.green,
            fontSize: 12,
            onClick: () async {
              ctx.navigator.add(Route(res.updateUrl));
            }),
        Button(
            text: '${FASolid.trash_alt} Delete',
            color: Button.red,
            fontSize: 12,
            onClick: () async {
              // TODO delete
            }),
      ]).makeView(),
      ret,
    ]);
  }

  @override
  View composeUpdate(Player model, Resource<Player> res, Context ctx) {
    var ret = Box(classes: ['admin-content-body']);
    ret.addChildren([
      Form(children: [
        LabeledTextEdit(label: 'Name', initial: model.name, key: 'name'),
        LabeledIntEdit(label: 'Age', initial: model.age, key: 'age'),
      ], key: 'update-form'),
    ]);
    return new Box(children: [
      TitleBar(res.label, icon: FASolid.edit, actions: [
        Button(
            text: '${FASolid.recycle} Reset',
            color: Button.blue,
            fontSize: 12,
            onClick: () async {
              Form form = ret.getByKey<Form>('update-form');
              form.setValue({
                'name': model.name,
                'age': model.age,
              });
            }),
        Button(
            text: '${FASolid.check} Submit',
            color: Button.green,
            fontSize: 12,
            onClick: () async {
              Form form = ret.getByKey<Form>('update-form');
              await res.fetcher
                  .update(res.name, Player.fromMap(form.readValue()));
            }),
      ]).makeView(),
      ret,
    ]);
  }

  @override
  FutureOr<View> composeCreate(Resource<Player> res, Context ctx) {
    var ret = Box(classes: ['admin-content-body']);
    ret.addChildren([
      Form(children: [
        LabeledTextEdit(label: 'Name', key: 'name'),
        LabeledIntEdit(label: 'Age', key: 'age'),
      ], key: 'create-form'),
    ]);
    return new Box(children: [
      TitleBar(res.label, icon: FASolid.plus, actions: [
        Button(
            text: '${FASolid.check} Submit',
            color: Button.green,
            fontSize: 12,
            onClick: () async {
              Form form = ret.getByKey<Form>('create-form');
              await res.fetcher
                  .create(res.name, Player.fromMap(form.readValue()));
            }),
      ]).makeView(),
      ret,
    ]);
  }
}

typedef View SimpleListPageCell<T>(T model);

ListPageMaker simpleListPage<T>(Map<String, SimpleListPageCell<T>> columns) {
  final colSpec =
      new List<ColumnSpec>.filled(columns.length, null, growable: true);
  for (int i = 0; i < columns.keys.length; i++) {
    String key = columns.keys.elementAt(i);
    colSpec[i] = new ColumnSpec(key);
  }
  return ListPageMaker<T>(
      colSpec: colSpec,
      rowMaker: (T model) {
        final cells = <String, View>{};
        for (String key in columns.keys) {
          cells[key] = columns[key](model);
        }
        return new TableRow(cells);
      });
}

void main() {
  var playerRes = PlayerRes();
  var admin = Admin([
    new Resource<Player>(
        read: playerRes,
        readList: playerRes,
        update: playerRes,
        create: playerRes),
  ], fetcher: new DummyPlayerFetcher());

  Element b = build(admin);
  querySelector('#admin-root').append(b);
}

class DummyPlayerFetcher implements GenericFetcher {
  @override
  M create<M>(String resName, M model) {
    print(model);
  }

  @override
  dynamic remove(String resName, String id) {}

  @override
  M update<M>(String resName, M model) {
    print(model);
  }

  @override
  List<M> readList<M>(String resName) =>
      <Player>[Player(name: 'Messi', age: 30)] as List<M>;

  @override
  M read<M>(String resName, String id) => Player(name: 'Messi', age: 30) as M;
}
