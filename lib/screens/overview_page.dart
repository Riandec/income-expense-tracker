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

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      FormPage(),
      _buildOverview(),
      ExchangePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _navBar(),
      body: _pages[selectedIndex]
    );
  }

  Widget _buildOverview() {
    return Center(
      child: Text('Overview Page')
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