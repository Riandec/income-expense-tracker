import 'package:flutter/material.dart';
import 'package:income_expense_tracker/screens/form_page.dart';
import 'package:income_expense_tracker/screens/exchange_page.dart';

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
                  },
                ),
              ),
              SizedBox(width: 10),
              // Year
              Expanded(
                child: DropdownButtonFormField(
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
                Text('Balance\n฿ 0.00'),
                // Income
                Text('Income\n฿ 0.00'),
                // Expense
                Text('Expense\n฿ 0.00')
              ],
            )
          ),
          SizedBox(height: 15),
          // Pie chart
          Container(
            height: 200,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 15),
          
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
}