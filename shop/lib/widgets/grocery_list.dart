import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop/widgets/new_item.dart';
import '../data/categories.dart';
import '../models/grocery_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  String? _error;
  bool _isLoading = true;
  List<GroceryItem> _groceryItems = [];

  void _loadData() async {
    final url = Uri.https(
        'grocery-test-6c213-default-rtdb.firebaseio.com', 'shopping-list.json');
    try {
      final http.Response res = await http.get(url);
      if (res.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fitch data. Please try again Later';
        });
        return;
      }
      if (res.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> loadedData = json.decode(res.body);
      final List<GroceryItem> loadedItems = [];

      if (_error == null) {
        for (var item in loadedData.entries) {
          final category = categories.entries
              .firstWhere(
                  (element) => element.value.title == item.value['Category'])
              .value;
          loadedItems.add(
            GroceryItem(
                id: item.key,
                name: item.value['name'],
                quantity: item.value['Quantity'],
                category: category),
          );
          setState(() {
            _groceryItems = loadedItems;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong! Please try again Later';
      });
      return;
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'No Items added yet.',
        style: TextStyle(color: Colors.black),
      ),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (_) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.black),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Grocery'),
          actions: [
            IconButton(
              onPressed: () async {
                final newAdd = await Navigator.of(context).push<GroceryItem>(
                  MaterialPageRoute(builder: (ctx) => const NewItem()),
                );
                if (newAdd == null) {
                  return;
                }
                setState(() {
                  _groceryItems.add(newAdd);
                });
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: content);
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('grocery-test-6c213-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
      Future.sync(() =>  ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('We could not delete the item.'))));
    }
  }
}
