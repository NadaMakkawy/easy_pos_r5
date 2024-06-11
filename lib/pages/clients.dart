import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/client.dart';
import '../pages/clients_ops.dart';
import '../helpers/sql_helper.dart';

import 'package:get_it/get_it.dart';
import 'package:data_table_2/data_table_2.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<ClientData>? clients;
  @override
  void initState() {
    getclients();
    super.initState();
  }

  void getclients() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('clients');

      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients!.add(
            ClientData.fromJson(item),
          );
        }
      } else {
        clients = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error In get data $e');
      }
      clients = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const ClientsOpsPage(),
                ),
              );
              if (result ?? false) {
                getclients();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                var result = await sqlHelper.db!.rawQuery(
                  """
        SELECT * FROM clients
        WHERE name LIKE '%$value%';
          """,
                );

                if (kDebugMode) {
                  print('values:$result');
                }
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                labelText: 'Search',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: PaginatedDataTable2(
                empty: const Center(
                  child: Text('No Data Found'),
                ),
                renderEmptyRowsInTheEnd: false,
                isHorizontalScrollBarVisible: true,
                minWidth: 700,
                wrapInCard: false,
                rowsPerPage: 15,
                headingTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 18),
                headingRowColor:
                    WidgetStatePropertyAll(Theme.of(context).primaryColor),
                border: TableBorder.all(),
                columnSpacing: 20,
                horizontalMargin: 20,
                columns: const [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Address')),
                  DataColumn(
                    label: Center(
                      child: Text('Actions'),
                    ),
                  ),
                ],
                source: MyDataTableSource(clients, getclients),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDataTableSource extends DataTableSource {
  List<ClientData>? clientsEx;

  void Function() getClients;

  MyDataTableSource(
    this.clientsEx,
    this.getClients,
  );

  @override
  DataRow? getRow(int index) {
    return DataRow2(
      cells: [
        DataCell(Text('${clientsEx?[index].id}')),
        DataCell(Text('${clientsEx?[index].name}')),
        DataCell(Text('${clientsEx?[index].email}')),
        DataCell(Text('${clientsEx?[index].phone}')),
        DataCell(Text('${clientsEx?[index].address}')),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {},
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  await onDeleteRow(clientsEx?[index].id ?? 0);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var result = await sqlHelper.db!.delete(
        'clients',
        where: 'id =?',
        whereArgs: [id],
      );
      if (result > 0) {
        getClients();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error In delete data $e');
      }
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => clientsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
