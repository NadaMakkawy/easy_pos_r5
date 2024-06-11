// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/sql_helper.dart';
import '../models/products.dart';
import '../widgets/app_elevated_button.dart';
import '../widgets/app_text_form_field.dart';
import '../widgets/categories_drop_down.dart';

import 'package:get_it/get_it.dart';

class ProductOpsPage extends StatefulWidget {
  final Product? product;
  const ProductOpsPage({this.product, super.key});

  @override
  State<ProductOpsPage> createState() => _ProductOpsPageState();
}

class _ProductOpsPageState extends State<ProductOpsPage> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;
  TextEditingController? priceController;
  TextEditingController? stockController;
  TextEditingController? imageController;
  bool isAvailable = false;

  int? selectedCategoryId;

  @override
  void initState() {
    setInitialData();

    super.initState();
  }

  void setInitialData() {
    nameController = TextEditingController(text: widget.product?.name);
    descriptionController =
        TextEditingController(text: widget.product?.description);

    imageController = TextEditingController(text: widget.product?.image);

    priceController =
        TextEditingController(text: '${widget.product?.price ?? ''}');
    stockController =
        TextEditingController(text: '${widget.product?.stock ?? ''}');

    isAvailable = widget.product?.isAvailable ?? false;
    selectedCategoryId = widget.product?.categoryId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppTextFormField(
                  controller: nameController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  label: 'Name',
                  hint: 'Product Name',
                ),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                  controller: descriptionController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                  label: 'Description',
                  hint: 'Product Description',
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        controller: priceController!,
                        textInputType: TextInputType.number,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Price is required';
                          }
                          return null;
                        },
                        label: 'Price',
                        hint: '99.0',
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: AppTextFormField(
                        textInputType: TextInputType.number,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                        controller: stockController!,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Stock is required';
                          }
                          return null;
                        },
                        label: 'Stock',
                        hint: '5',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                  controller: imageController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Image Url is required';
                    }
                    return null;
                  },
                  label: 'Image Url',
                  hint: 'https://www.image_url.com/',
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Switch(
                        value: isAvailable,
                        onChanged: (value) {
                          setState(() {
                            isAvailable = value;
                          });
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Is Avaliable')
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                CategoriesDropDown(
                  selectedValue: selectedCategoryId,
                  onChanged: (categoryId) {
                    setState(
                      () {
                        selectedCategoryId = categoryId;
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                AppElevatedButton(
                  label: 'Submit',
                  onPressed: () async {
                    await onSubmit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.product != null) {
          await sqlHelper.db!.update(
              'products',
              {
                'name': nameController?.text,
                'description': descriptionController?.text,
                'price': priceController?.text,
                'stock': stockController?.text,
                'image': imageController?.text,
                'isAvailable': isAvailable,
                'categoryId': selectedCategoryId,
              },
              where: 'id =?',
              whereArgs: [widget.product?.id]);
        } else {
          await sqlHelper.db!.insert('products', {
            'name': nameController?.text,
            'description': descriptionController?.text,
            'price': priceController?.text,
            'stock': stockController?.text,
            'image': imageController?.text,
            'isAvailable': isAvailable,
            'categoryId': selectedCategoryId,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Product Saved Successfully'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Creating Product : $e'),
        ),
      );
    }
  }
}
