import 'package:flutter/material.dart';
import 'package:sqlite_crud/database_helper.dart';
import 'dart:math' as math;
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// all data.
  List<Map<String, dynamic>> myData = [];

  bool _isLoading = true;             // if this is false you can use myData value.
  // if this is true it is not yet update.

  /// fetch all. and injection data in myData value.
  void _refreshData() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
      print('##### data = $data');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshData();             // loading the data when the app starts
  }


  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void showMyForm(int? id) async {
    _titleController.clear();
    _descriptionController.clear();
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingData =
      myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Colors.amberAccent)
                ),
                onPressed: () async {
                  // Save new data
                  if (id == null) {
                    await addItem();
                  }
                  else {
                    await updateItem(id);
                  }

                  // Clear the text fields
                  _titleController.clear();
                  _descriptionController.clear();

                  // Close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

  // Insert a new data to the database
  Future<void> addItem() async {
    await DatabaseHelper.createItem(
        _titleController.text, _descriptionController.text);
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Successfully added item!'),
          backgroundColor:Colors.green,
        duration:  Duration(seconds: 2),
      ),
    );
    _refreshData();
  }

  // Update an existing data
  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Successfully updated item!'),
          backgroundColor:Colors.green,
        duration:  Duration(seconds: 2),
      ),
    );
    _refreshData();
  }

  // Delete an item
  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
          content: Text('Successfully deleted item!'),
          backgroundColor:Colors.yellow,
         duration:  Duration(seconds: 2),
      ),
    );
    print(' >>> home_screen => before execute _refreshData ');
    _refreshData();
    print(' >>> home_screen => after execute _refreshData ');
  }
  static Color? getPaletteColor(int idx) {
    return idx%2==0?Colors.amberAccent[100]: Colors.amberAccent[200];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPAD - Assignment - SQLite CRUD'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : myData.isEmpty? const Center(
          child:  Text("No Data Available!")): Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [
                0.1,
                0.4,
                0.6,
                0.9,
              ],
              colors: [
                Colors.yellow,
                Colors.red,
                Colors.indigo,
                Colors.teal,
              ],
            )
        ),
        child:  ListView.builder(
          itemCount: myData.length,
          itemBuilder: (context, index) => Card(
            color: getPaletteColor(index),
            margin: const EdgeInsets.all(15),
            child:ListTile(
                iconColor: Colors.white,
                title: Text(myData[index]['title']),
                subtitle: Text(myData[index]['description']),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showMyForm(myData[index]['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            deleteItem(myData[index]['id']),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      )
      ,floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}