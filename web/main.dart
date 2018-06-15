import 'dart:async';
import 'dart:html';
import 'package:admin_client/admin_client.dart';
import 'package:admin_client/controls/fa_solid.dart';

class Player {
  String name;
  int age;
  Player({this.name, this.age});

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
  View composeRead(Player model, Resource<Player> r, Context ctx) {
    return Box(children: [
      LabeledTextField(model.name, 'Name'),
      LabeledIntField(model.age, 'Age')
    ]);
  }

  @override
  View composeUpdate(Player model, Resource<Player> res, Context ctx) {
    var ret = Box(classes: ['admin-content-body']);
    ret.addChildren([
      LabeledTextEdit(label: 'Name', initial: model.name, key: 'Name'),
      LabeledIntEdit(label: 'Age', initial: model.age, key: 'Age'),
    ]);
    return new Box(children: [
      HBox(
          children: [
            HBox(
                children: [
                  TextField(FASolid.plus, fontFamily: 'fa5-free'),
                  TextField(res.label, classes: ['jaguar-admin-title'])
                ],
                width: FlexSize(1.0),
                height: PercentageSize(100),
                vAlign: VAlign.middle),
            HBox(children: [
              Button(
                  text: '${FASolid.recycle} Reset',
                  color: Button.blue,
                  fontSize: 12,
                  onClick: () async {
                    var nameV = ret.getByKey<LabeledTextEdit>('Name');
                    var ageV = ret.getByKey<LabeledIntEdit>('Age');
                    await res.fetcher.update(res.name,
                        Player(name: nameV.readValue(), age: ageV.readValue()));
                  }),
              Button(
                  text: '${FASolid.check} Submit',
                  color: Button.green,
                  fontSize: 12,
                  onClick: () async {
                    var nameV = ret.getByKey<LabeledTextEdit>('Name');
                    var ageV = ret.getByKey<LabeledIntEdit>('Age');
                    await res.fetcher.update(res.name,
                        Player(name: nameV.readValue(), age: ageV.readValue()));
                  }),
            ], height: PercentageSize(100), vAlign: VAlign.middle),
          ],
          width: PercentageSize(100),
          height: FixedSize(52),
          vAlign: VAlign.middle,
          classes: ['jaguar-admin-titlebar']),
      ret,
    ]);
  }

  @override
  FutureOr<View> composeCreate(Resource<Player> res, Context ctx) {
    var ret = Box(classes: ['admin-content-body']);
    ret.addChildren([
      LabeledTextEdit(label: 'Name', key: 'Name'),
      LabeledIntEdit(label: 'Age', key: 'Age'),
    ]);
    return new Box(children: [
      HBox(
          children: [
            HBox(
                children: [
                  TextField(FASolid.plus, fontFamily: 'fa5-free'),
                  TextField(res.label, classes: ['jaguar-admin-title'])
                ],
                width: FlexSize(1.0),
                height: PercentageSize(100),
                vAlign: VAlign.middle),
            HBox(
                children: [
                  Button(
                      text: '${FASolid.check} Submit',
                      color: Button.green,
                      fontSize: 12,
                      onClick: () async {
                        var nameV = ret.getByKey<LabeledTextEdit>('Name');
                        var ageV = ret.getByKey<LabeledIntEdit>('Age');
                        await res.fetcher.create(res.name,
                            Player(name: nameV.readValue(), age: ageV.readValue()));
                      }),
                ],
                height: PercentageSize(100),
                vAlign: VAlign.middle),
          ],
          width: PercentageSize(100),
          height: FixedSize(52),
          vAlign: VAlign.middle,
          classes: ['jaguar-admin-titlebar']),
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
  M create<M>(String resName, M model) {}

  @override
  dynamic remove(String resName, String id) {}

  @override
  M update<M>(String resName, M model) {
    print(model);
  }

  @override
  List<M> readList<M>(String resName) =>
      <Player>[Player(name: 'Messi', age: 31)] as List<M>;

  @override
  M read<M>(String resName, String id) => Player(name: 'Messi', age: 31) as M;
}
