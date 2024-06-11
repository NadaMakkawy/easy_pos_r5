import 'package:flutter/material.dart';

import '../helpers/sql_helper.dart';
import '../pages/categories.dart';
import '../widgets/grid_view_item.dart';
import '../pages/clients.dart';
import '../pages/products.dart';

import 'package:get_it/get_it.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isTableInitialized = false;
  @override
  void initState() {
    intilizeTables();
    super.initState();
  }

  void intilizeTables() async {
    var sqlHelper = GetIt.I.get<SqlHelper>();
    isTableInitialized = await sqlHelper.createTables();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //   return Scaffold(
    //     drawer: Container(),
    //     appBar: AppBar(),
    //     body: Column(
    //       children: [
    //         Expanded(
    //           child: Container(
    //             height:
    //                 MediaQuery.of(context).size.height / 3 + (kIsWeb ? 40 : 0),
    //             color: Theme.of(context).primaryColor,
    //             child: Padding(
    //               padding:
    //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Row(
    //                     children: [
    //                       const Text(
    //                         'Easy Pos',
    //                         style: TextStyle(
    //                           color: Colors.white,
    //                           fontWeight: FontWeight.w800,
    //                           fontSize: 24,
    //                         ),
    //                       ),
    //                       Padding(
    //                         padding: const EdgeInsets.symmetric(horizontal: 10),
    //                         child: isLoading
    //                             ? Transform.scale(
    //                                 scale: .5,
    //                                 child: const CircularProgressIndicator(
    //                                   color: Colors.white,
    //                                 ),
    //                               )
    //                             : CircleAvatar(
    //                                 backgroundColor: isTableInitialized
    //                                     ? Colors.green
    //                                     : Colors.red,
    //                                 radius: 10,
    //                               ),
    //                       )
    //                     ],
    //                   ),
    //                   const SizedBox(
    //                     height: 20,
    //                   ),
    //                   headerItem('Exchange Rate', '1USD = 50 EGP'),
    //                   headerItem('Today\'s Sales', '1000 EGP'),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //         Expanded(
    //           child: Container(
    //             color: const Color(0xfffbfafb),
    //             padding: const EdgeInsets.all(20),
    //             child: GridView.count(
    //               crossAxisCount: 2,
    //               mainAxisSpacing: 20,
    //               crossAxisSpacing: 20,
    //               children: [
    //                 GridViewItem(
    //                   color: Colors.orange,
    //                   iconData: Icons.calculate,
    //                   label: 'All Sales',
    //                   onPressed: () {},
    //                 ),
    //                 GridViewItem(
    //                   color: Colors.pink,
    //                   iconData: Icons.inventory_2,
    //                   label: 'Products',
    //                   onPressed: () {},
    //                 ),
    //                 GridViewItem(
    //                   color: Colors.lightBlue,
    //                   iconData: Icons.groups,
    //                   label: 'Clients',
    //                   onPressed: () {},
    //                 ),
    //                 GridViewItem(
    //                   color: Colors.green,
    //                   iconData: Icons.point_of_sale,
    //                   label: 'New Sale',
    //                   onPressed: () {},
    //                 ),
    //                 GridViewItem(
    //                   color: Colors.yellow,
    //                   iconData: Icons.category,
    //                   label: 'Categories',
    //                   onPressed: () {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (_) => const CategoriesPage(),
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               ],
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //   );
    // }

// another approach
    return Scaffold(
      drawer: Container(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            pinned: false,
            bottom: PreferredSize(
              preferredSize: Size(10.h, 80.w),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Easy Pos',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: isLoading
                              ? Transform.scale(
                                  scale: .5,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: isTableInitialized
                                      ? Colors.green
                                      : Colors.red,
                                  radius: 10,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    headerItem('Exchange Rate', '1USD = 50 EGP'),
                    headerItem('Today\'s Sales', '1000 EGP'),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                GridViewItem(
                  color: Colors.orange,
                  iconData: Icons.calculate,
                  label: 'All Sales',
                  onPressed: () {},
                ),
                GridViewItem(
                  color: Colors.pink,
                  iconData: Icons.inventory_2,
                  label: 'Products',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductsPage(),
                      ),
                    );
                  },
                ),
                GridViewItem(
                  color: Colors.lightBlue,
                  iconData: Icons.groups,
                  label: 'Clients',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientsPage(),
                      ),
                    );
                  },
                ),
                GridViewItem(
                  color: Colors.green,
                  iconData: Icons.point_of_sale,
                  label: 'New Sale',
                  onPressed: () {},
                ),
                GridViewItem(
                  color: Colors.yellow,
                  iconData: Icons.category,
                  label: 'Categories',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoriesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget headerItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        color: const Color(0xff206ce1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
