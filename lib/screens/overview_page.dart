import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:income_expense_tracker/screens/form_page.dart';
import 'package:income_expense_tracker/screens/categories_page.dart';
import 'package:intl/intl.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  int selectedIndex = 1;
  List<IconData> navIcons = [
    Icons.insert_comment_rounded,
    Icons.home_rounded,
    Icons.category_rounded
  ];
  List<String> navTitles = [
    'Form',
    'Overview',
    'Categories'
  ];

  String? selectedMonth;
  String? selectedYear;

  double totalBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  Map<String, double> incomeCategory = {};
  Map<String, double> expenseCategory = {};
  Map<String, double> allCategory = {};

  final CollectionReference transactions = FirebaseFirestore.instance.collection('Transaction');

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedMonth = DateFormat('MMMM').format(now);
    selectedYear = DateFormat('yyyy').format(now);
    calculateTotals();
  }

  // Convert month name to month number
  int getMonthNumber(String monthNow) {
    const months = {'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5, 'June': 6, 'July': 7, 'August': 8, 'September': 9, 'October': 10, 'November': 11, 'December': 12};
    return months[monthNow] ?? 1;
  }

  // Read data from firebase and calculate things
  Future<void> calculateTotals() async {
    if (selectedMonth == null || selectedYear == null) {
      return;
    }
    int month = getMonthNumber(selectedMonth!);
    int year = int.parse(selectedYear!);
    DateTime start = DateTime(year, month, 1, 0, 0 ,0 ,0);
    DateTime end = DateTime(year, month+1, 0, 23, 59, 59, 999);

    try {
      QuerySnapshot snapshot = await transactions
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

      double income = 0.0;
      double expense = 0.0;
      Map<String, double> incomeCategoryData = {};
      Map<String, double> expenseCategoryData = {};

      for (var doc in snapshot.docs) {
        double amount = (doc['amount'] as num).toDouble();
        String type = doc['type'];
        String category = doc['category'];

        if (type == 'Income') {
          income += amount;
          incomeCategoryData[category] = (incomeCategoryData[category] ?? 0) + amount;
        } else if (type == 'Expense') {
          expense += amount;
          expenseCategoryData[category] = (expenseCategoryData[category] ?? 0) + amount;
        }
      }
      setState(() {
        totalIncome = income;
        totalExpense = expense;
        totalBalance = income - expense;
        incomeCategory = incomeCategoryData;
        expenseCategory = expenseCategoryData;
        allCategory = {...incomeCategory, ...expenseCategory};
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      FormPage(),
      _buildOverview(),
      CategoriesPage(),
    ];
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 244, 1),
      bottomNavigationBar: _navBar(),
      body: pages[selectedIndex]
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 20, right: 20, top: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Label month
              SizedBox(
                width: 120,
                child: Text(
                  selectedMonth ?? 'Month',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontStyle: FontStyle.italic,
                    fontSize: 26,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Month
              Expanded(
                child: DropdownButtonFormField(
                  value: selectedMonth,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Month',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                  items: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
                    .map((String month) => DropdownMenuItem(
                      value: month, 
                      child: Text(month)
                    )).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedMonth = value;
                    });
                    calculateTotals();
                  },
                ),
              ),
              SizedBox(width: 10),
              // Year
              Expanded(
                child: DropdownButtonFormField(
                  value: selectedYear,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Year',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                  items: ['2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030']
                    .map((String year) => DropdownMenuItem(
                      value: year, 
                      child: Text(year)
                    )).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedYear = value;
                    });
                    calculateTotals();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Summary amount
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Balance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '฿ ${totalBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Color.fromRGBO(241, 203, 69, 1)
                      )
                    )
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Income',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '฿ ${totalIncome.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Color.fromRGBO(148, 213, 95, 1)
                      )
                    )
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Expense',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '฿ ${totalExpense.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Color.fromRGBO(253, 77, 90, 1)
                      )
                    )
                  ],
                )
                
              ],
            )
          ),
          SizedBox(height: 15),
          // Pie chart
          SizedBox(
            height: 200,
            child: Row(
              children: [
                _buildPieChart(incomeCategory, totalIncome, 'Income'),
                SizedBox(width: 15),
                _buildPieChart(expenseCategory, totalExpense, 'Expense'),
              ]
            ),
          ),
          SizedBox(height: 15),
          // Category list
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allCategory.length,
              itemBuilder: (context, index) {
                var sortAmount = allCategory.entries.toList();
                sortAmount.sort((a, b) => b.value.compareTo(a.value)); // desc
                String category = sortAmount[index].key;
                double amount = sortAmount[index].value;
                bool isIncome = incomeCategory.containsKey(category);
                return Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category),
                      Text(
                        '฿ ${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isIncome ? Color.fromRGBO(148, 213, 95, 1) : Color.fromRGBO(253, 77, 90, 1)
                        ),
                      ),
                    ],
                  )
                );
              } 
            ),
          ),
          SizedBox(height: 15),
          // Transaction list
          Text(
            'Transactions History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 5),
          StreamBuilder<QuerySnapshot>(
            stream: transactions
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(int.parse(selectedYear!), getMonthNumber(selectedMonth!), 1, 0, 0 ,0 ,0)))
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(int.parse(selectedYear!), getMonthNumber(selectedMonth!)+1, 0, 23, 59, 59)))
              .snapshots(),
            builder:(context, snapshot) {
              if (snapshot.hasData) {
                List transactionsList = snapshot.data!.docs;
                List<String> titles = [];
                List<Timestamp> date = [];
                List<double> amount = [];
                List<String> type = [];
                for (var doc in transactionsList) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  titles.add(data['title']);
                  date.add(data['date']);
                  amount.add((data['amount'] as num).toDouble());
                  type.add(data['type']);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: transactionsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity(vertical: -4),
                      contentPadding: EdgeInsets.zero,
                      leading: Text((index+1).toString()),
                      title: Text(
                        titles[index],
                        style: TextStyle(
                          fontSize: 15
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy · HH:mm').format(date[index].toDate()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      ),
                      trailing: Text(
                        '${type[index] == 'Income' ? '+' : '−'}${amount[index].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          color: type[index] == 'Income' ? Color.fromRGBO(148, 213, 95, 1) : Color.fromRGBO(253, 77, 90, 1)
                        ),
                      ),
                    );
                  },
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      )
    );
  }

  // Custom bottom navigation bar
  Widget _navBar() {
    return Container(
      width: 320,
      height: 75,
      margin: EdgeInsets.only(right: 24, left: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 2,
            offset: Offset(3, 3),
            spreadRadius: 3
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: navIcons.map((icon) {
          int index = navIcons.indexOf(icon);
          bool isSelected = selectedIndex == index;
          return Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 8, bottom: 0, left: 25, right: 25),
                    padding: EdgeInsets.all(8),
                    decoration: isSelected 
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(255, 222, 91, 1),
                          border: Border.all(color: Colors.black)
                        )
                      : null,
                    child: Icon(icon, color: isSelected ? Colors.black : Colors.grey),
                  ),
                  Text(
                    navTitles[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontSize: 12
                    ),
                  ),
                ],
              )
            )
          );
        }).toList(),
      )
    );
  }

  // Pie chart
  Widget _buildPieChart(Map<String, double> data, double total, String label) {
    final incomeColors = [
      Color.fromRGBO(126, 238, 226, 1),
      Color.fromRGBO(174, 238, 121, 1),
      Color.fromRGBO(117, 237, 194, 1),
      Color.fromRGBO(157, 210, 243, 1),
      Color.fromRGBO(216, 244, 171, 1),
    ];
    final expenseColors = [
      Color.fromRGBO(253, 77, 90, 1),
      Color.fromRGBO(254, 138, 185, 1),
      Color.fromRGBO(254, 160, 127, 1),
      Color.fromRGBO(255, 188, 194, 1),
      Color.fromRGBO(253, 77, 193, 1),
      Color.fromRGBO(254, 130, 87, 1),
    ];

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold
              ),
            ),
            // Pie chart
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: data.entries.map((entry) {
                          int index = data.keys.toList().indexOf(entry.key);
                          double percentage = (entry.value / total) * 100;
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(0)}%',
                            color: label == 'Income' ? incomeColors[index % incomeColors.length] : expenseColors[index % expenseColors.length],
                            radius: 25,
                            titleStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                            ),
                            borderSide: BorderSide(color: Colors.black),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                      ),
                    )
                  ),
                  SizedBox(width: 5),
                  // Label category
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.entries.map((entry) {
                          int index = data.keys.toList().indexOf(entry.key);
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: label == 'Income' ? incomeColors[index % incomeColors.length] : expenseColors[index % expenseColors.length],
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              )
            )
          ],
        )
      )
    );
  }
}