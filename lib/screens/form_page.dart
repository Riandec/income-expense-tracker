import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? selectedType;
  String? selectedCategory;
  final CollectionReference transactions = FirebaseFirestore.instance.collection('Transaction');
  final CollectionReference categories = FirebaseFirestore.instance.collection('Categories');

  Stream<QuerySnapshot> getCategories() {
    if (selectedType == null) {
      return Stream.empty();
    }
    return categories
      .where('type', isEqualTo: selectedType)
      .snapshots();
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await transactions.add({
          'date': Timestamp.now(),
          'type': selectedType,
          'category': selectedCategory,
          'title': _titleController.text,
          'amount': double.parse(_amountController.text),
          'description': _descriptionController.text,
        });
        // clear form text
        _formKey.currentState!.reset();
        _dateController.clear();
        _titleController.clear();
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          selectedType = null;
          selectedCategory = null;
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Form'),
        backgroundColor: Color.fromRGBO(255, 252, 244, 1),
      ),
      backgroundColor: Color.fromRGBO(255, 252, 244, 1),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Date',
                  floatingLabelStyle: TextStyle(
                    color: Colors.black
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(171, 244, 236, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.calendar_today, color: Colors.black, size: 20),
                    )
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(30)
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context, 
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020), 
                    lastDate: DateTime(2030)
                  );
                  if (pickedDate != null) {
                    _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                  }
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Type
                  Expanded(
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Type',
                        floatingLabelStyle: TextStyle(
                          color: Colors.black
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 10, right: 5),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(171, 244, 236, 1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.swap_vert_rounded, color: Colors.black, size: 25),
                          )
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(30)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(30)
                        ),
                      ),
                      items: ['Income', 'Expense'].map((String type) =>
                        DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedType = value;
                          selectedCategory = null;
                        });
                      },
                      value: selectedType,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a type';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  // Category
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: getCategories(), 
                      builder:(context, snapshot) {
                        if (!snapshot.hasData) {
                          return DropdownButtonFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Category',
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 10, right: 5),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(171, 244, 236, 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.category_rounded, color: Colors.black, size: 20),
                                )
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(30)
                              ),
                            ),
                            items: [],
                            onChanged: null,
                            value: selectedCategory,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          );
                        }
                        final data = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Category',
                            floatingLabelStyle: TextStyle(
                              color: Colors.black
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 10, right: 5),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(171, 244, 236, 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.category_rounded, color: Colors.black, size: 20),
                              )
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(30)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(30)
                            ),
                          ),
                          items: data.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc['name'],
                              child: Text(doc['name']),
                            );
                          }).toList(),
                          onChanged: selectedType == null ? null : (String? value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                          value: selectedCategory,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        );
                      },
                    )
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Title',
                  floatingLabelStyle: TextStyle(
                    color: Colors.black
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(171, 244, 236, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, color: Colors.black, size: 20),
                    )
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(30)
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Amount',
                  floatingLabelStyle: TextStyle(
                    color: Colors.black
                  ),
                  suffixText: '฿',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(171, 244, 236, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.money_rounded, color: Colors.black, size: 20),
                    )
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(30)
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Description',
                  floatingLabelStyle: TextStyle(
                    color: Colors.black
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(171, 244, 236, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.description_rounded, color: Colors.black, size: 20),
                    )
                  ),
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
              SizedBox(height: 30),
              // Submit button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(212, 240, 87, 1)
                ),
                onPressed: () {
                  submitForm();
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
            ],
          )
        )
      )
    );
  }
}