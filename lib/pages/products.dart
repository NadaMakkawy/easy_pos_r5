import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/sql_helper.dart';
import '../models/products.dart';
import '../pages/products_ops.dart';
import '../widgets/app_table.dart';

import 'package:get_it/get_it.dart';
import 'package:data_table_2/data_table_2.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product>? products;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  //
  // void _sortName<T>(Function(Product d) getField, int columnIndex,
  //     {bool ascending = true}) {
  //   products!.sort((a, b) {
  //     final aValue = getField(a);
  //     final bValue = getField(b);
  //     if (aValue == null || bValue == null) {
  //       return 0;
  //     }
  //     return ascending
  //         ? Comparable.compare(aValue, bValue)
  //         : Comparable.compare(bValue, aValue);
  //   });
  // }

  //
  // void _sortName<T>(Function(Product d) getField, int columnIndex,
  //     {bool ascending = true}) {
  //   ascending
  //       ? products!.sort((a, b) => a.name!.compareTo(b.name!))
  //       : products!.sort((a, b) => b.name!.compareTo(a.name!));
  // }
  //

  void _sort<T>(
    Function(Product d) getField,
    int columnIndex, {
    bool ascending = true,
  }) {
    products!.sort(
      (a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? aValue!.compareTo(bValue)
            : bValue!.compareTo(aValue);
      },
    );
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select P.* ,C.name as categoryName,C.description as categoryDesc 
      from products P
      inner join categories C
      where P.categoryId = C.id
      """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products!.add(Product.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error In get data $e');
      }
      products = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const ProductOpsPage(),
                  ),
                );
                if (result ?? false) {
                  getProducts();
                }
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.db!.rawQuery("""
        SELECT * FROM products
        WHERE name LIKE '%$value%' OR description LIKE '%$value% OR price LIKE '%$value%';
          """);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                labelText: 'Search',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: AppTable(
                minWidth: 1300,
                columns: [
                  const DataColumn(label: Text('Id')),
                  DataColumn(
                    label: const Text('Name'),
                    onSort: (columnIndex, ascending) {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                      _sort<String>(
                        (d) => d.name!,
                        columnIndex,
                        ascending: ascending,
                      );
                      setState(() {});
                    },
                  ),
                  const DataColumn(label: Text('Description')),
                  DataColumn(
                    label: const Text('Price'),
                    onSort: (columnIndex, ascending) {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                      _sort<double>(
                        (d) => d.price!,
                        columnIndex,
                        ascending: ascending,
                      );
                      setState(() {});
                    },
                  ),
                  const DataColumn(label: Text('Stock')),
                  const DataColumn(label: Text('isAvailable')),
                  const DataColumn(label: Center(child: Text('image'))),
                  const DataColumn(label: Text('categoryId')),
                  const DataColumn(label: Text('categoryName')),
                  const DataColumn(label: Text('categoryDesc')),
                  const DataColumn(label: Center(child: Text('Actions'))),
                ],
                source: ProductsSource(
                  productsEx: products,
                  onUpdate: (productData) async {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => ProductOpsPage(
                                  product: productData,
                                )));
                    if (result ?? false) {
                      getProducts();
                    }
                  },
                  onDelete: (productData) {
                    onDeleteRow(productData.id!);
                  },
                ),
                sortAscending: _sortAscending,
                sortColumnIndex: _sortColumnIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Product'),
              content:
                  const Text('Are you sure you want to delete this product?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          'products',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getProducts();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error In delete data $e');
      }
    }
  }
}

class ProductsSource extends DataTableSource {
  List<Product>? productsEx;

  void Function(Product) onUpdate;
  void Function(Product) onDelete;
  ProductsSource(
      {required this.productsEx,
      required this.onUpdate,
      required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${productsEx?[index].id}')),
      DataCell(Text('${productsEx?[index].name}')),
      DataCell(Text('${productsEx?[index].description}')),
      DataCell(Text('${productsEx?[index].price}')),
      DataCell(Text('${productsEx?[index].stock}')),
      DataCell(Text('${productsEx?[index].isAvailable}')),
      DataCell(Center(
        child: Image.network(
          '${productsEx?[index].image}',
          fit: BoxFit.contain,
        ),
      )),
      DataCell(Text('${productsEx?[index].categoryId}')),
      DataCell(Text('${productsEx?[index].categoryName}')),
      DataCell(Text('${productsEx?[index].categoryDesc}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                onUpdate(productsEx![index]);
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                onDelete(productsEx![index]);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => productsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
