import 'package:araneta_HBA_it14/pages/transactions_page.dart';
import 'package:araneta_HBA_it14/pages/create_budget_page.dart';
import 'package:araneta_HBA_it14/pages/home_page.dart';
import 'package:araneta_HBA_it14/pages/profile_page.dart';
import 'package:araneta_HBA_it14/pages/stats_page.dart';
import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animations/animations.dart';

class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;
  List<Widget> pages = [
    HomePage(),
    StatsPage(),
    TransactionsPage(),
    ProfilePage(),
    CreateBudgetPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(pageIndex),
          index: pageIndex,
          children: [
            HomePage(),
            StatsPage(),
            TransactionsPage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: getFooter(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateBudgetPage()),
              );

              // Refresh HomePage if budget was added successfully
              if (result == true && mounted) {
                setState(() {
                  // Rebuild the IndexedStack with a new HomePage instance
                  pages[0] = HomePage();
                });
                // Force rebuild of the current page
                if (pageIndex == 0) {
                  setState(() {});
                }
              }
            },
            child: Icon(Icons.attach_money_rounded, size: 30),
            backgroundColor: secondary1,
            foregroundColor: white,
            elevation: 6,
            shape: CircleBorder(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget getFooter() {
    List<Widget> items = [
      Icon(Ionicons.md_home, color: Colors.white),
      Icon(Ionicons.md_stats, color: Colors.white),
      Container(
        width: 30,
        height: 0,
        color: Colors.transparent,
      ),
      Icon(Ionicons.md_cash, color: Colors.white),
      Icon(Ionicons.ios_person, color: Colors.white),
    ];

    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: secondary1,
      buttonBackgroundColor: secondary1,
      height: 65,
      items: items,
      index: pageIndex < 2 ? pageIndex : pageIndex + 1,
      onTap: (index) {
        if (index != 2) {
          setState(() {
            pageIndex = index > 2 ? index - 1 : index;
          });
        }
      },
      letIndexChange: (index) =>
          index != 2, // Add this line to prevent center item selection
    );
  }

  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
