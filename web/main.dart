import 'dart:async';
import 'dart:html';
import 'package:admin_client/admin_client.dart';

class Player {
  String name;
  int age;
  Player({this.name, this.age});
}

class ReadPlayer implements ReadView<Player> {
  @override
  View renderRead(Player model, Resource<Player> r, Context ctx) {
    return Box(children: [TextField(model.name), IntField(model.age)]);
  }
}

class ReadListPlayer implements ReadListView<Player> {
  forEach(Player model, Resource<Player> r, Context ctx) {
    return TableRow({
      'name': TextField(model.name),
      'age': IntField(model.age),
    });
  }

  @override
  Future<View> renderReadList(
      List<Player> model, Resource<Player> r, Context ctx) {
    return simpleListPage({
      'name': (Player p) => TextField(p.name),
      'age': (Player p) => IntField(p.age),
    }).makeView(model);
    /*
    return Box(
        children: model
            .map((model) => Box(children: [
                  TextField(model.name),
                  IntField(model.age),
                  Button(
                      text: 'Edit',
                      callback: () {
                        print('Edit');
                        ctx.navigator.add(Route(r.readUrl));
                      }),
                ]))
            .toList());
            */
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
  var admin = Admin([
    new Resource<Player>(
        read: new ReadPlayer(), readList: new ReadListPlayer()),
  ], fetcher: new DummyPlayerFetcher());

  Element b = build(admin);
  querySelector('#admin-root').append(b);
}

class DummyPlayerFetcher implements GenericFetcher {
  @override
  M create<M>(String resName, M model) {}

  @override
  dynamic remove(String resName, String id) {}

  @override
  M update<M>(String resName, M model) {}

  @override
  List<M> readList<M>(String resName) =>
      <Player>[Player(name: 'Messi', age: 31)] as List<M>;

  @override
  M read<M>(String resName, String id) => Player(name: 'Messi', age: 31) as M;
}
