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
  View renderRead(String resName, Fetcher f, Player model) {
    return Box(
        children: [TextField(model.name, 'Name'), TextField(model.age, 'Age')]);
  }
}

class ReadListPlayer implements ReadListView<Player> {
  @override
  View renderReadList(String resName, Fetcher f, List<Player> model) {
    return Box(
        children: model
            .map((model) => Box(children: [
                  TextField(model.name, 'Name'),
                  TextField(model.age, 'Age'),
                  Button(
                      text: 'Edit',
                      callback: () {
                        print('Edit');
                        // TODO
                      }),
                ]))
            .toList());
  }
}

void main() {
  var admin = Admin([
    new Resource<Player>(
        read: new ReadPlayer(), readList: new ReadListPlayer()),
  ], fetcher: new DummyPlayerFetcher());

  Element b = build(admin);
  querySelector('#admin-root').append(b);
}

class DummyPlayerFetcher implements Fetcher {
  @override
  M create<M>(String resName, M model) {}

  @override
  dynamic remove(String resName, String id) {}

  @override
  M update<M>(String resName, M model) {}

  @override
  List<M> readList<M>(String resName) =>
      <Player>[new Player(name: 'Messi', age: 31)] as List<M>;

  @override
  M read<M>(String resName, String id) {}
}
