import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CollectionReference categories = FirebaseFirestore.instance.collection('Categories');
  final _nameController = TextEditingController();

  // Create
  Future<void> addCategory(String name, String type) async {
    await categories.add({
      'name': name,
      'type': type,
    });
  }
  // Read
  Stream<QuerySnapshot> getCategories(String type) {
    return categories
    .where('type', isEqualTo: type)
    .snapshots();
  }
  // Edit
  Future<void> updateCategory(String docId, String newName, String newType) async {
    await categories.doc(docId).update({
    'name': newName,
    'type': newType,
  });
  }
  // Delete
  Future<void> deleteCategory(String docId) async {
    await categories.doc(docId).delete();
  }
  // Dialog
  void showAddDialog (BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Add $type Category'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Enter a category name',
            floatingLabelStyle: TextStyle(
              color: Colors.black
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(30)
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(30)
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.redAccent
              )
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              side: BorderSide(color: Colors.black),
              backgroundColor: Colors.white
            ),
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                addCategory(_nameController.text.trim(), type);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
          ),
        ],
      )
    );
  }

  void showDeleteDialog(BuildContext context, String docId, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.redAccent
              )
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              side: BorderSide(color: Colors.black),
              backgroundColor: Colors.white
            ),
            onPressed: () {
              deleteCategory(docId);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories Management'),
        backgroundColor: Color.fromRGBO(255, 252, 244, 1),
      ),
      backgroundColor: Color.fromRGBO(255, 252, 244, 1),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  children: [
                    Container(
                      height: 35,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(148, 213, 95, 1),
                        border: Border(
                          bottom: BorderSide(color: Colors.black)
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(9),
                          topRight: Radius.circular(9)
                        )
                      ),
                      child: Center(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      )
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: getCategories('Income'), 
                      builder:(context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final data = snapshot.data!.docs;
                        if (data.isEmpty) {
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity(vertical: -4),
                            title: Text(
                              'No category',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: data.length, 
                          separatorBuilder:(context, index) => Divider(), 
                          itemBuilder:(context, index) {
                            final categories = data[index];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.only(left: 10),
                              title: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  categories['name'],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                onPressed: (){
                                  showDeleteDialog(context, categories.id, categories['name']);
                                }
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: (){
                        showAddDialog(context, 'Income');
                      }, 
                    )
                  ],
                )
              )
            ),
            SizedBox(width: 20),
            // Expense list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  children: [
                    Container(
                      height: 35,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(253, 77, 90, 1),
                        border: Border(
                          bottom: BorderSide(color: Colors.black)
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(9),
                          topRight: Radius.circular(9)
                        )
                      ),
                      child: Center(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      )
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: getCategories('Expense'), 
                      builder:(context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final data = snapshot.data!.docs;
                        if (data.isEmpty) {
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity(vertical: -4),
                            title: Text(
                              'No category',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: data.length, 
                          separatorBuilder:(context, index) => Divider(), 
                          itemBuilder:(context, index) {
                            final categories = data[index];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.only(left: 10),
                              title: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  categories['name'],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                onPressed: (){
                                  showDeleteDialog(context, categories.id, categories['name']);
                                }
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: (){
                        showAddDialog(context, 'Expense');
                      }, 
                    )
                  ],
                )
              )
            ),
          ],
        ),
      )
    );
  }
}