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
  String? selectedType;
  String? selectedCategory;

  final Map<String, List<String>> categoryByType = {
    'Income': ['Wage', 'Allowance'],
    'Expense': ['Food', 'Transport', 'Entertainment'],
  };

  List<String> getCategories() {
    if (selectedType == null) {
      return [];
    }
    return categoryByType[selectedType] ?? [];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Form')
      ),
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
                  labelText: 'Date',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue,
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
                    firstDate: DateTime(2000), 
                    lastDate: DateTime(2100)
                  );
                  if (pickedDate != null) {
                    _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                  }
                },
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Type
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 10, right: 5),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue,
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
                      }
                    ),
                  ),
                  SizedBox(width: 20),
                  // Category
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 10, right: 5),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue,
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
                      items: getCategories().map((String category) =>
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        )).toList(),
                      onChanged: selectedType == null ? null : (String? value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Title
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue,
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
              ),
              SizedBox(height: 30),
              // Amount
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  suffixText: '฿',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue,
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
              ),
              SizedBox(height: 30),
              // Description
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue,
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
                  backgroundColor: Colors.white,
                ),
                onPressed: () {

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