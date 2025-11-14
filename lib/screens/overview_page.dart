import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:income_expense_tracker/screens/form_page.dart';
import 'package:income_expense_tracker/screens/exchange_page.dart';
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
    Icons.currency_exchange_rounded
  ];
  List<String> navTitles = [
    'Form',
    'Overview',
    'Exchange'
  ];

  final _monthController = TextEditingController();
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
        allCategory = {...incomeCategoryData, ...expenseCategoryData};
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
      ExchangePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _navBar(),
      body: pages[selectedIndex]
    );
  }

  Widget _buildOverview() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label month
              Text(
                selectedMonth ?? 'Month',
                style: TextStyle(
                  fontFamily: 'Animal Chariot',
                  fontSize: 32,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(width: 30),
              // Month
              Expanded(
                child: DropdownButtonFormField(
                  value: selectedMonth,
                  decoration: InputDecoration(
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
                  items: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'].map((String month) =>
                    DropdownMenuItem(
                      value: month,
                      child: Text(month),
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
                  decoration: InputDecoration(
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
                  items: ['2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030'].map((String year) =>
                    DropdownMenuItem(
                      value: year,
                      child: Text(year),
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
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Total
                Text('Balance\n฿ ${totalBalance.toStringAsFixed(2)}'),
                // Income
                Text('Income\n฿ ${totalIncome.toStringAsFixed(2)}'),
                // Expense
                Text('Expense\n฿ ${totalExpense.toStringAsFixed(2)}')
              ],
            )
          ),
          SizedBox(height: 15),
          // Pie chart
          Row(
            children: [
              _buildPieChart(incomeCategory, totalIncome),
              SizedBox(width: 15),
              _buildPieChart(expenseCategory, totalExpense),
            ]
          ),
          SizedBox(height: 15),
          // Category list
          Container(
            height: 100,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allCategory.length,
                    itemBuilder: (context, index) {
                      return Text(allCategory.keys.elementAt(index) + ' ');
                    } 
                  ),
                )
              ],
            )
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
  Widget _buildPieChart(Map<String, double> data, double total) {
    final incomeColors = [
      Color.fromRGBO(91, 124, 255, 1),
      Color.fromRGBO(171, 244, 236, 1),
      Color.fromRGBO(117, 237, 194, 1),
      Color.fromRGBO(142, 165, 255, 1),
      Color.fromRGBO(255, 222, 91, 1),
    ];
    final expenseColors = [
      Color.fromRGBO(253, 77, 90, 1),
      Color.fromRGBO(254, 138, 185, 1),
      Color.fromRGBO(254, 160, 127, 1),
      Color.fromRGBO(255, 222, 91, 1),
      Color.fromRGBO(253, 77, 193, 1),
      Color.fromRGBO(223, 127, 254, 1),
    ];

    return Expanded(
      child: Container(
        height: 200,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              total == totalIncome ? 'Income' : 'Expense',
              style: TextStyle(
                fontSize: 14,
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
                            color: total == totalIncome ? incomeColors[index % incomeColors.length] : expenseColors[index % expenseColors.length],
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
                                    color: total == totalIncome ? incomeColors[index % incomeColors.length] : expenseColors[index % expenseColors.length],
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    '${entry.key}',
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