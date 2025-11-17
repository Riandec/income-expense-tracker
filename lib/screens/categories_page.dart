import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CollectionReference categories = FirebaseFirestore.instance.collection('Categories');

  // create
  Future<void> addCategory(String name, String type) async {
    await categories.add({
      'name': name,
      'type': type,
    });
  }
  // read
  Stream<QuerySnapshot> getCategories(String type) {
    return categories
    .where('type', isEqualTo: type)
    .snapshots();
  }
  // edit
  Future<void> updateCategory(String docId, String newName, String newType) async {
    await categories.doc(docId).update({
    'name': newName,
    'type': newType,
  });
  }
  // delete
  Future<void> deleteCategory(String docId) async {
    await categories.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories Management'),
        backgroundColor: Color.fromRGBO(255, 252, 244, 1),
      ),
      backgroundColor: Color.fromRGBO(255, 252, 244, 1),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                        borderRadius: BorderRadiusGeometry.only(
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
                        if (snapshot.hasData) {
                          List categoriesList = snapshot.data!.docs;
                          List<String> names = [];
                          for (var doc in categoriesList) {
                            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                            names.add(data['name']);
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
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
                  borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadiusGeometry.only(
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
                    )
                  ],
                )
              )
            )
          ],
        ),
      )
    );
  }
}