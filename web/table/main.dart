import 'dart:async';
import 'dart:html';
import 'package:admin_client/admin_client.dart';

void main() {
  var tab = Table(
    spec: [
      ColumnSpec<String>('Name', width: FixedSize(200)),
      ColumnSpec<int>('Age', width: PercentageSize(30))
    ],
    rows: [
      /*
      {"Name": TextField('Messi'), "Age": IntField(30)},
      {"Name": TextField('Coutinho'), "Age": IntField(30)},
      */
    ],
  );

  Element b = tableRenderer(tab, defaultRenderers);
  querySelector('#admin-root').append(b);
}
