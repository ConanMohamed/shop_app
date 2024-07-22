import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop/models/grocery_item.dart';
import '../data/categories.dart';
import '../models/category.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  int _enteredquantity = 0;
  Category _selectedCategory = categories[Categories.vegetables]!;
  void _saveItem() {
    final url = Uri.https(
        'grocery-test-6c213-default-rtdb.firebaseio.com', 'shopping-list.json');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _enteredName,
          'Quantity': _enteredquantity,
          'Category': _selectedCategory.title
        }),
      )
          .then((res) {
        final Map<String, dynamic> resData = json.decode(res.body);
        if (res.statusCode == 200) {
          Navigator.of(context).pop(GroceryItem(
              id: resData['name'],
              name: _enteredName,
              quantity: _enteredquantity,
              category: _selectedCategory));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: const TextStyle(color: Colors.black),
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      onSaved: (newValue) {
                        _enteredquantity = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: (String? value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Wrong Number!';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        dropdownColor: const Color.fromARGB(255, 193, 187, 187),
                        style: const TextStyle(color: Colors.black),
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      category.value.title,
                                    ),
                                  ],
                                ))
                        ],
                        value: _selectedCategory,
                        onChanged: (value) {
                          _selectedCategory = value!;
                        }),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset')),
                  ElevatedButton(
                      onPressed: _isLoading ? null : _saveItem,
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Loading'),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                      backgroundColor: Colors.blue,
                                      strokeWidth: 3,
                                    ),
                                  )
                                ],
                              ),
                            )
                          : const Text('Add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
